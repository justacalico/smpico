import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'log.dart';
import 'paths.dart';
import '../settings.dart';

class GameLink {
  final int pos;
  final String kind;
  final String label;
  final String url;
  final String? note;
  final String? via;
  final String status;
  final String? fileName;
  final int size;
  final bool isFolder;

  GameLink.fromRow(Map<String, Object?> r)
    : pos = r['pos'] as int,
      kind = '${r['kind']}',
      label = '${r['label']}',
      url = '${r['url']}',
      note = r['note'] as String?,
      via = r['via'] as String?,
      status = '${r['status']}',
      fileName = r['file_name'] as String?,
      size = (r['size'] as int?) ?? 0,
      isFolder = (r['is_folder'] as int?) == 1;
}

class Game {
  final int id;
  final String slug;
  final String title;
  final String sheetTitle;
  final bool ovrport;
  final int? postId;
  final String? postUrl;
  final String? postedAt;
  final String? description;
  final String? language;
  final String? multiplayer;
  final String? version;
  final String? updatedAt;
  final String? cover;
  final String? youtube;
  final String? trailer;
  final String? installNotes;
  final String? downloadNotes;
  final String hints;
  final bool special;
  List<String> genres;
  List<GameLink> links;

  Game.fromRow(Map<String, Object?> r)
    : id = r['id'] as int,
      slug = '${r['slug']}',
      title = '${r['title']}',
      sheetTitle = '${r['sheet_title']}',
      ovrport = (r['ovrport'] as int?) == 1,
      postId = r['post_id'] as int?,
      postUrl = r['post_url'] as String?,
      postedAt = r['posted_at'] as String?,
      description = r['description'] as String?,
      language = r['language'] as String?,
      multiplayer = r['multiplayer'] as String?,
      version = r['version'] as String?,
      updatedAt = r['updated_at'] as String?,
      cover = r['cover'] as String?,
      youtube = r['youtube'] as String?,
      trailer = r['trailer'] as String?,
      installNotes = r['install_notes'] as String?,
      downloadNotes = r['download_notes'] as String?,
      hints = '${r['hints']}',
      special = (r['special'] as int?) == 1,
      genres = [],
      links = [];

  Map<String, dynamic> get hintsMap {
    try {
      final m = jsonDecode(hints);
      return m is Map<String, dynamic> ? m : {};
    } catch (_) {
      return {};
    }
  }

  String get coverUrl => '${Catalog.instance.imagesBase}/images/$cover';

  /// Local cover file from the unpacked covers cache, when available.
  String? get coverPath => Catalog.instance.coverPath(cover);

  int get bestSize {
    var s = 0;
    for (final l in links) {
      if (l.size > s) s = l.size;
    }
    return s;
  }

  bool get downloadable => links.any(
    (l) =>
        l.status == 'ok' &&
        (l.kind == 'yandex' || l.kind == 'gdrive' || l.kind == 'sber'),
  );
}

class Catalog extends ChangeNotifier {
  Catalog._();
  static final Catalog instance = Catalog._();

  /// Original EZPico feed — always freshest, zero maintenance.
  static const upstreamBase =
      'https://raw.githubusercontent.com/Cka3ka1337/EZPico/main';

  Database? _db;
  List<Game> games = [];
  List<String> genres = [];
  String version = '';
  bool loading = false;
  bool available = false;
  String? error;

  String? _resolvedBase;
  String? _coversDir;

  String get customAddress => Settings.instance.get('catalog_address', '');

  /// Catalog sources in priority order. The custom address wins when set,
  /// then upstream.
  List<String> get sources => [
        if (customAddress.isNotEmpty) customAddress,
        upstreamBase,
      ];

  /// Source that last served the manifest (or the first choice before any
  /// fetch happened). Covers and loose images use the same base.
  String get base =>
      _resolvedBase ?? (customAddress.isEmpty ? upstreamBase : customAddress);

  String get imagesBase => base;

  String? coverPath(String? name) =>
      name == null || _coversDir == null ? null : p.join(_coversDir!, name);

  Future<void> init() async {
    await _open();
    await checkUpdates(silent: true);
  }

  Future<void> _open() async {
    sqfliteFfiInit();
    final dir = await AppPaths.catalogDir();
    await dir.create(recursive: true);
    final covers = Directory(p.join(dir.path, 'covers'));
    if (await File(p.join(covers.path, '.version')).exists()) {
      _coversDir = covers.path;
    }
    final dbFile = File(p.join(dir.path, 'catalog.db'));
    if (!await dbFile.exists()) return;
    _db = await databaseFactoryFfi.openDatabase(
      dbFile.path,
      options: OpenDatabaseOptions(readOnly: true),
    );
    await _load();
  }

  Future<void> _load() async {
    if (_db == null) return;
    final rows = await _db!.query('games');
    final genreRows = await _db!.query('game_genres');
    final linkRows = await _db!.query('links', orderBy: 'game_id, pos');
    final genreMap = <int, List<String>>{};
    for (final g in genreRows) {
      genreMap.putIfAbsent(g['game_id'] as int, () => []).add('${g['genre']}');
    }
    final linkMap = <int, List<GameLink>>{};
    for (final l in linkRows) {
      linkMap
          .putIfAbsent(l['game_id'] as int, () => [])
          .add(GameLink.fromRow(l));
    }
    games = rows.map((r) {
      final g = Game.fromRow(r);
      g.genres = genreMap[g.id] ?? [];
      g.links = linkMap[g.id] ?? [];
      return g;
    }).toList();
    genres = genreMap.values.expand((e) => e).toSet().toList()..sort();
    try {
      final meta = await _db!.query(
        'meta',
        where: 'key = ?',
        whereArgs: ['version'],
      );
      if (meta.isNotEmpty) version = '${meta.first['value']}';
    } catch (_) {}
    available = true;
    notifyListeners();
  }

  /// Fetch manifest.json, compare version, refresh db + covers if newer.
  /// Sources are tried in order (custom, upstream) until one
  /// serves a valid manifest.
  Future<bool> checkUpdates({bool silent = false}) async {
    if (loading) return false;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(minutes: 3),
        ),
      );
      Map<String, dynamic>? manifest;
      String? src;
      for (final s in sources) {
        try {
          final res = await dio.get('$s/manifest.json');
          manifest = res.data is String
              ? jsonDecode(res.data as String) as Map<String, dynamic>
              : res.data as Map<String, dynamic>;
          src = s;
          break;
        } catch (e) {
          dlog('catalog manifest failed from $s: $e');
        }
      }
      if (manifest == null || src == null) {
        throw StateError('all catalog sources unreachable');
      }
      _resolvedBase = src;
      final remoteVersion = '${manifest['version']}';
      dlog('catalog manifest: remote $remoteVersion, local $version ($src)');
      if (remoteVersion == version && _db != null) {
        await _syncCovers(dio, manifest, remoteVersion);
        loading = false;
        notifyListeners();
        return false;
      }
      final dir = await AppPaths.catalogDir();
      await dir.create(recursive: true);
      final dbFile = File(p.join(dir.path, 'catalog.db'));
      await dio.download('$src/${manifest['db']}', dbFile.path);
      final bytes = await dbFile.readAsBytes();
      final sum = sha256.convert(bytes).toString();
      if (sum != manifest['db_sha256']) {
        error = 'catalog checksum mismatch';
        dlog("catalog checksum mismatch: $sum != ${manifest['db_sha256']}");
        loading = false;
        notifyListeners();
        return false;
      }
      version = remoteVersion;
      await _db?.close();
      _db = null;
      await _open();
      await _syncCovers(dio, manifest, remoteVersion);
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = '$e';
      dlog('catalog update failed: $e');
      loading = false;
      available = _db != null;
      notifyListeners();
      return false;
    }
  }

  /// Download covers.zip once per catalog version into covers/ so covers
  /// work offline. Tries every source since not all of them host the zip.
  Future<void> _syncCovers(
    Dio dio,
    Map<String, dynamic> manifest,
    String ver,
  ) async {
    final zip = manifest['covers_zip'];
    if (zip == null) return;
    final dir = await AppPaths.catalogDir();
    final covers = Directory(p.join(dir.path, 'covers'));
    final marker = File(p.join(covers.path, '.version'));
    if (await marker.exists() && (await marker.readAsString()) == ver) {
      _coversDir = covers.path;
      return;
    }
    final tmp = File(p.join(dir.path, 'covers.zip'));
    var got = false;
    for (final s in sources) {
      try {
        await dio.download('$s/$zip', tmp.path);
        got = true;
        dlog('catalog covers.zip from $s');
        break;
      } catch (e) {
        dlog('covers.zip failed from $s: $e');
      }
    }
    if (!got) return;
    final wantSum = manifest['covers_zip_sha256'];
    if (wantSum != null &&
        sha256.convert(await tmp.readAsBytes()).toString() != wantSum) {
      dlog('covers.zip checksum mismatch');
      await tmp.delete().catchError((_) => tmp);
      return;
    }
    try {
      final archive = ZipDecoder().decodeBytes(await tmp.readAsBytes());
      if (await covers.exists()) await covers.delete(recursive: true);
      await covers.create(recursive: true);
      for (final e in archive.files) {
        final out = p.join(covers.path, e.name);
        if (!e.isFile || e.name.endsWith('/')) {
          await Directory(out).create(recursive: true);
        } else {
          final f = File(out);
          await f.create(recursive: true);
          await f.writeAsBytes(e.content as List<int>);
        }
      }
      await marker.writeAsString(ver);
      _coversDir = covers.path;
      dlog('catalog covers synced: $ver (${archive.files.length} files)');
    } catch (e) {
      dlog('covers unpack failed: $e');
    }
    await tmp.delete().catchError((_) => tmp);
  }

  List<Game> filter({
    String query = '',
    Set<String> genreFilter = const {},
    String? language,
    String? type, // 'ovrport' | 'fnal'
    int? minSize,
    int? maxSize,
    bool downloadableOnly = false,
  }) {
    final q = query.toLowerCase().trim();
    return games.where((g) {
      if (q.isNotEmpty &&
          !'${g.title} ${g.sheetTitle} ${g.genres.join(' ')}'
              .toLowerCase()
              .contains(q)) {
        return false;
      }
      if (genreFilter.isNotEmpty && !g.genres.any(genreFilter.contains)) {
        return false;
      }
      if (language != null && g.language != language) return false;
      if (type == 'ovrport' && !g.ovrport) return false;
      if (type == 'fnal' && g.ovrport) return false;
      if (minSize != null || maxSize != null) {
        final s = g.bestSize;
        if (s == 0) return false;
        if (minSize != null && s < minSize) return false;
        if (maxSize != null && s > maxSize) return false;
      }
      if (downloadableOnly && !g.downloadable) return false;
      return true;
    }).toList();
  }
}
