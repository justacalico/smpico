import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;

import '../settings.dart';
import 'adb.dart';
import 'catalog.dart';
import 'devices.dart';
import 'downloads.dart';
import 'installer.dart';
import 'log.dart';
import 'packages.dart';
import 'paths.dart';
import 'remote_files.dart';

/// Embedded MCP server so AI agents can drive the app. Streamable HTTP
/// transport on 127.0.0.1 — every tool calls the same singletons the UI
/// uses, so an agent can never do anything the user can't.
class McpServer extends ChangeNotifier {
  McpServer._();
  static final McpServer instance = McpServer._();

  static const _preferredPort = 7850;
  static const _protocol = '2025-03-26';

  HttpServer? _http;
  int port = 0;
  String? _sessionId;
  String _version = '0.0.0';

  bool get running => _http != null;
  String get url => 'http://127.0.0.1:$port/mcp';

  Future<void> init() async {
    try {
      _version = (await PackageInfo.fromPlatform()).version;
    } catch (_) {}
    if (Settings.instance.get<bool>('mcp_enabled', false)) {
      await start();
    }
  }

  Future<void> setEnabled(bool enabled) =>
      enabled ? start() : stop();

  Future<void> start() async {
    if (_http != null) return;
    for (var cand = _preferredPort; cand < _preferredPort + 20; cand++) {
      try {
        _http = await HttpServer.bind(InternetAddress.loopbackIPv4, cand);
        port = cand;
        break;
      } catch (_) {}
    }
    if (_http == null) {
      dlog('mcp: no free port to bind');
      return;
    }
    _http!.listen(_handle);
    dlog('mcp: listening on $url');
    notifyListeners();
  }

  Future<void> stop() async {
    await _http?.close(force: true);
    _http = null;
    _sessionId = null;
    dlog('mcp: stopped');
    notifyListeners();
  }

  // ---------- transport ----------

  Future<void> _handle(HttpRequest req) async {
    try {
      await _route(req);
    } catch (e, st) {
      dlog('mcp handler error: $e\n$st');
      try {
        req.response.statusCode = 500;
        await req.response.close();
      } catch (_) {}
    }
  }

  Future<void> _route(HttpRequest req) async {
    if (req.uri.path != '/mcp') {
      req.response.statusCode = 404;
      await req.response.close();
      return;
    }
    if (req.method == 'GET') {
      // clients may open the SSE stream for server-initiated traffic;
      // we never send any, so just keep it open
      req.response
        ..statusCode = 200
        ..headers.set('content-type', 'text/event-stream')
        ..headers.set('cache-control', 'no-cache')
        ..write(': ok\n\n');
      await req.response.flush();
      unawaited(req.response.done.catchError((_) {}));
      return;
    }
    if (req.method != 'POST') {
      req.response.statusCode = 405;
      await req.response.close();
      return;
    }
    Object? body;
    try {
      body = jsonDecode(await utf8.decoder.bind(req).join());
    } catch (e) {
      await _sendJson(req, _err(null, -32700, 'parse error: $e'));
      return;
    }
    final isBatch = body is List;
    final msgs = isBatch ? body : [body];
    final out = <Object?>[];
    var newSession = false;
    for (final m in msgs.whereType<Map>()) {
      final res = await _dispatch(
        m.cast<String, dynamic>(),
        (v) => newSession = newSession || v,
      );
      if (res != null) out.add(res);
    }
    if (out.isEmpty) {
      // all notifications
      req.response.statusCode = 202;
      await req.response.close();
      return;
    }
    await _sendJson(
      req,
      isBatch ? out : out.first,
      sessionId: newSession ? _sessionId : null,
    );
  }

  Future<void> _sendJson(
    HttpRequest req,
    Object? payload, {
    String? sessionId,
  }) async {
    req.response
      ..statusCode = 200
      ..headers.contentType = ContentType.json;
    if (sessionId != null) {
      req.response.headers.set('mcp-session-id', sessionId);
    }
    // write bytes — response.write() encodes latin1 and blows up on
    // non-ascii payloads (game titles, instructions)
    req.response.add(utf8.encode(jsonEncode(payload)));
    await req.response.close();
  }

  Future<Map<String, dynamic>?> _dispatch(
    Map<String, dynamic> msg,
    void Function(bool) markSession,
  ) async {
    final id = msg['id'];
    final method = '${msg['method']}';
    final params = msg['params'];
    try {
      switch (method) {
        case 'initialize':
          _sessionId = _newSessionId();
          markSession(true);
          dlog('mcp: client initialized (${params is Map ? params['clientInfo'] : '?'})');
          return _ok(id, {
            'protocolVersion': _protocol,
            'capabilities': {
              'tools': {'listChanged': false},
            },
            'serverInfo': {'name': 'smpico', 'version': _version},
            'instructions':
                'SMPico — PICO VR sideloader. Tools drive the same queues and '
                'device operations the app UI uses.',
          });
        case 'ping':
          return _ok(id, const {});
        case 'tools/list':
          return _ok(id, {'tools': _tools()});
        case 'tools/call':
          final p = params is Map ? params.cast<String, dynamic>() : {};
          final name = '${p['name']}';
          final args = p['arguments'] is Map
              ? (p['arguments'] as Map).cast<String, dynamic>()
              : <String, dynamic>{};
          return _ok(id, await _call(name, args));
        default:
          if (method.startsWith('notifications/') || id == null) {
            return null;
          }
          return _err(id, -32601, 'unknown method: $method');
      }
    } catch (e, st) {
      dlog('mcp: $method failed: $e\n$st');
      return _err(id, -32603, '$e');
    }
  }

  String _newSessionId() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}-'
      '${identityHashCode(this).toRadixString(16)}-'
      '${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';

  Map<String, dynamic> _ok(Object? id, Object? result) =>
      {'jsonrpc': '2.0', 'id': id, 'result': result};

  Map<String, dynamic> _err(Object? id, int code, String message) => {
    'jsonrpc': '2.0',
    'id': id,
    'error': {'code': code, 'message': message},
  };

  Map<String, dynamic> _toolResult(Object? data, {bool isError = false}) => {
    'content': [
      {'type': 'text', 'text': const JsonEncoder.withIndent('  ').convert(data)},
    ],
    'isError': isError,
  };

  // ---------- tools ----------

  List<Map<String, dynamic>> _tools() => [
    _tool(
      'device_status',
      'Connected PICO headset: model, serial, battery, storage, firmware.',
    ),
    _tool('apps_list', 'Installed packages on the headset.', props: {
      'refresh': {
        'type': 'boolean',
        'description': 'Force a refresh from the device first',
      },
    }),
    _tool('app_launch', 'Launch an app on the headset.', props: {
      'package': {'type': 'string', 'description': 'Package name'},
    }, required: ['package']),
    _tool('app_uninstall', 'Uninstall an app from the headset.', props: {
      'package': {'type': 'string', 'description': 'Package name'},
    }, required: ['package']),
    _tool(
      'app_grant_permissions',
      'Grant all runtime permissions to an installed app.',
      props: {
        'package': {'type': 'string', 'description': 'Package name'},
      },
      required: ['package'],
    ),
    _tool(
      'catalog_search',
      'Search the PicoLand game catalog.',
      props: {
        'query': {'type': 'string', 'description': 'Title search, empty for all'},
        'genre': {'type': 'string', 'description': 'Genre filter'},
        'limit': {'type': 'integer', 'description': 'Max results, default 20'},
      },
    ),
    _tool(
      'catalog_game',
      'Full catalog entry with download links for a game.',
      props: {
        'id': {'type': 'integer', 'description': 'Game id from catalog_search'},
      },
      required: ['id'],
    ),
    _tool(
      'catalog_refresh',
      'Check the catalog feed for updates and reload if newer.',
    ),
    _tool(
      'game_download',
      'Queue a catalog game for download, optionally installing it on '
          'the headset afterwards — same path as the Download and install '
          'button.',
      props: {
        'id': {'type': 'integer', 'description': 'Game id from catalog_search'},
        'install': {
          'type': 'boolean',
          'description': 'Install on the headset after download, default true',
        },
        'method': {
          'type': 'string',
          'enum': ['auto', 'direct', 'overport', 'repack'],
          'description': 'Install method, default auto',
        },
      },
      required: ['id'],
    ),
    _tool('downloads_list', 'Download queue: state, progress, errors.'),
    _tool(
      'download_cancel',
      'Cancel an active download.',
      props: {
        'id': {'type': 'string', 'description': 'Job id from downloads_list'},
      },
      required: ['id'],
    ),
    _tool(
      'install_local',
      'Queue a local file or folder for install on the headset — same as '
          'dropping it on the Install page.',
      props: {
        'path': {'type': 'string', 'description': 'Local file or folder path'},
        'name': {'type': 'string', 'description': 'Display name, optional'},
        'method': {
          'type': 'string',
          'enum': ['auto', 'direct', 'overport', 'repack'],
        },
        'packageSuffix': {
          'type': 'string',
          'description': 'Package id suffix for repack/overport',
        },
        'newKey': {'type': 'boolean'},
        'keepSdkMeta': {'type': 'boolean'},
        'storeInstaller': {'type': 'boolean'},
      },
      required: ['path'],
    ),
    _tool('installs_list', 'Install queue: state, stage, errors.'),
    _tool(
      'install_cancel',
      'Cancel a queued or running install.',
      props: {
        'index': {
          'type': 'integer',
          'description': 'Job index from installs_list',
        },
      },
      required: ['index'],
    ),
    _tool(
      'files_list',
      'List a directory on the headset filesystem.',
      props: {
        'path': {'type': 'string', 'description': 'Default /sdcard'},
        'showHidden': {'type': 'boolean'},
      },
    ),
    _tool(
      'files_pull',
      'Pull a file or folder from the headset into the downloads folder.',
      props: {
        'path': {'type': 'string', 'description': 'Remote path'},
      },
      required: ['path'],
    ),
    _tool(
      'files_push',
      'Push a local file or folder to the headset.',
      props: {
        'localPath': {'type': 'string'},
        'remoteDir': {'type': 'string', 'description': 'Default /sdcard'},
      },
      required: ['localPath'],
    ),
    _tool(
      'adb_shell',
      'Run a shell command on the headset over adb — the same call every '
          'feature in the app uses.',
      props: {
        'command': {'type': 'string'},
      },
      required: ['command'],
    ),
  ];

  Map<String, dynamic> _tool(
    String name,
    String description, {
    Map<String, dynamic> props = const {},
    List<String> required = const [],
  }) => {
    'name': name,
    'description': description,
    'inputSchema': {
      'type': 'object',
      'properties': props,
      if (required.isNotEmpty) 'required': required,
    },
  };

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> a,
  ) async {
    try {
      return _toolResult(await _runTool(name, a));
    } catch (e) {
      return _toolResult({'error': '$e'}, isError: true);
    }
  }

  Future<Object?> _runTool(String name, Map<String, dynamic> a) async {
    switch (name) {
      case 'device_status':
        await Devices.instance.updateDevices();
        final d = Devices.instance.info;
        return {
          'connected': d != null,
          'serials': Devices.instance.serials,
          if (d != null)
            'device': {
              'model': d.model,
              'serial': d.serial,
              'product': d.product,
              'firmware': d.firmware,
              'batteryPct': d.batteryPct,
              'charging': d.charging,
              'freeBytes': d.freeBytes,
              'totalBytes': d.totalBytes,
              'wifi': d.wifi,
              'addr': d.addr,
            },
        };
      case 'apps_list':
        final pkgs = Packages.instance;
        if (a['refresh'] == true || pkgs.items.isEmpty) {
          await pkgs.refresh(thirdPartyOnly: false);
        }
        return {
          'count': pkgs.items.length,
          'apps': [
            for (final e in pkgs.items)
              {
                'package': e.name,
                'label': e.label,
                'sizeBytes': e.sizeBytes,
                'system': e.system,
              },
          ],
        };
      case 'app_launch':
        return {
          'result': await Packages.instance.launch('${a['package']}'),
        };
      case 'app_uninstall':
        return {
          'result': await Packages.instance.uninstall('${a['package']}'),
        };
      case 'app_grant_permissions':
        final pkg = '${a['package']}';
        await Packages.instance.grantAll(pkg);
        return {'granted': await Packages.instance.permissions(pkg)};
      case 'catalog_search':
        final cat = Catalog.instance;
        final q = '${a['query'] ?? ''}'.trim().toLowerCase();
        final genre = '${a['genre'] ?? ''}'.trim();
        final limit = a['limit'] is int ? a['limit'] as int : 20;
        final out = <Map<String, dynamic>>[];
        for (final g in cat.games) {
          if (out.length >= limit) break;
          if (genre.isNotEmpty && !g.genres.contains(genre)) continue;
          if (q.isNotEmpty &&
              !g.title.toLowerCase().contains(q) &&
              !g.sheetTitle.toLowerCase().contains(q)) {
            continue;
          }
          out.add(_gameSummary(g));
        }
        return {
          'catalogVersion': cat.version,
          'totalGames': cat.games.length,
          'genres': cat.genres,
          'results': out,
        };
      case 'catalog_game':
        final g = _findGame(a['id']);
        return _gameDetail(g);
      case 'catalog_refresh':
        await Catalog.instance.checkUpdates();
        return {'version': Catalog.instance.version};
      case 'game_download':
        final g = _findGame(a['id']);
        final link = g.bestDownloadLink;
        if (link == null) {
          throw StateError('no usable download link for ${g.title}');
        }
        final install = a['install'] != false;
        final job = await Downloads.instance.enqueue(
          title: g.title,
          url: link.url,
          kind: link.kind,
          installAfter: install ? _options(a) : null,
        );
        return {
          'queued': true,
          'jobId': job.id,
          'title': g.title,
          'via': link.kind,
          'installAfter': install,
        };
      case 'downloads_list':
        return {
          'jobs': [
            for (final j in Downloads.instance.jobs)
              {
                'id': j.id,
                'title': j.title,
                'state': j.state,
                'progress': j.progress,
                'fileName': j.fileName,
                'receivedBytes': j.received,
                'totalBytes': j.total,
                'error': j.error,
              },
          ],
        };
      case 'download_cancel':
        final id = '${a['id']}';
        final j = Downloads.instance.jobs
            .where((j) => j.id == id)
            .firstOrNull;
        if (j == null) throw StateError('no such download: $id');
        Downloads.instance.cancel(j);
        return {'cancelled': j.title};
      case 'install_local':
        final path = '${a['path']}';
        if (!await FileSystemEntity.isFile(path) &&
            !await FileSystemEntity.isDirectory(path)) {
          throw StateError('not found: $path');
        }
        final job = Installer.instance.enqueue(
          path,
          a['name'] is String && (a['name'] as String).isNotEmpty
              ? a['name'] as String
              : p.basename(path),
          _options(a),
        );
        return {'queued': true, 'job': job.displayName};
      case 'installs_list':
        return {
          'jobs': [
            for (var i = 0; i < Installer.instance.jobs.length; i++)
              () {
                final j = Installer.instance.jobs[i];
                return {
                  'index': i,
                  'name': j.displayName,
                  'state': j.state.name,
                  'stage': j.stage,
                  'progress': j.progress,
                  'error': j.error,
                };
              }(),
          ],
        };
      case 'install_cancel':
        final i = a['index'] is int ? a['index'] as int : -1;
        if (i < 0 || i >= Installer.instance.jobs.length) {
          throw StateError('no such install: $i');
        }
        Installer.instance.cancel(Installer.instance.jobs[i]);
        return {'cancelled': Installer.instance.jobs[i].displayName};
      case 'files_list':
        final entries = await RemoteFiles.instance.entriesAt(
          '${a['path'] ?? '/sdcard'}',
          showHidden: a['showHidden'] == true,
        );
        return {
          'entries': [
            for (final e in entries)
              {
                'name': e.name,
                'path': e.path,
                'isDir': e.isDir,
                'size': e.size,
                'modified': e.modified,
              },
          ],
        };
      case 'files_pull':
        final path = '${a['path']}';
        final target = await AppPaths.downloads();
        final stat = await RemoteFiles.instance.entriesAt(
          p.posix.dirname(path),
          showHidden: true,
        );
        final entry = stat
            .where((e) => e.path == path)
            .firstOrNull;
        await Transfers.instance.download(
          [
            entry ??
                RemoteEntry(p.posix.basename(path), path, false, 0, ''),
          ],
          target,
        );
        return {'pulling': path, 'into': target.path};
      case 'files_push':
        await Transfers.instance.upload(
          ['${a['localPath']}'],
          '${a['remoteDir'] ?? '/sdcard'}',
        );
        return {'pushed': a['localPath']};
      case 'adb_shell':
        return {'output': await Adb.instance.shell('${a['command']}')};
      default:
        throw StateError('unknown tool: $name');
    }
  }

  Game _findGame(Object? id) {
    final n = id is int ? id : int.tryParse('$id');
    final g = Catalog.instance.games.where((g) => g.id == n).firstOrNull;
    if (g == null) throw StateError('no such game id: $id');
    return g;
  }

  Map<String, dynamic> _gameSummary(Game g) => {
    'id': g.id,
    'title': g.title,
    'sheetTitle': g.sheetTitle,
    'version': g.version,
    'genres': g.genres,
    'ovrport': g.ovrport,
    'links': g.links.length,
    'installed': _isInstalled(g),
  };

  Map<String, dynamic> _gameDetail(Game g) => {
    ..._gameSummary(g),
    'slug': g.slug,
    'description': g.description,
    'language': g.language,
    'multiplayer': g.multiplayer,
    'postUrl': g.postUrl,
    'installNotes': g.installNotes,
    'downloadNotes': g.downloadNotes,
    'downloadLinks': [
      for (final l in g.links)
        {
          'kind': l.kind,
          'label': l.label,
          'url': l.url,
          'status': l.status,
          'sizeBytes': l.size,
          'fileName': l.fileName,
        },
    ],
  };

  bool _isInstalled(Game g) {
    final k = Packages.instance.installedKeys;
    return k.contains(Packages.norm(g.title)) ||
        k.contains(Packages.norm(g.sheetTitle));
  }

  InstallOptions _options(Map<String, dynamic> a) {
    final m = '${a['method'] ?? 'auto'}';
    return InstallOptions(
      method: InstallMethod.values.firstWhere(
        (v) => v.name == m,
        orElse: () => InstallMethod.auto,
      ),
      packageSuffix: '${a['packageSuffix'] ?? ''}',
      newKey: a['newKey'] == true,
      keepSdkMeta: a['keepSdkMeta'] == true,
      storeInstaller: a['storeInstaller'] == true,
    );
  }
}
