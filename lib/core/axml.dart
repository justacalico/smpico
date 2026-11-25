import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Minimal binary AndroidManifest.xml reader — extracts package,
/// versionCode/versionName and label without a full apktool decode.
/// Same thing the original does via androguard.
class ApkInfo {
  String package = '';
  String versionName = '';
  int versionCode = 0;
  String label = '';
  int labelRes = 0;
  int minSdk = 0;
  int targetSdk = 0;
  List<String> permissions = [];
}

class _Reader {
  final ByteData d;
  int p = 0;
  _Reader(this.d);
  int u16() {
    final v = d.getUint16(p, Endian.little);
    p += 2;
    return v;
  }

  int u32() {
    final v = d.getUint32(p, Endian.little);
    p += 4;
    return v;
  }

  void skip(int n) => p += n;
}

Uint8List _apkEntry(File apk, String name) {
  // minimal ZIP reader: scan end-of-central-directory, walk entries
  final raf = apk.openSync();
  try {
    final size = raf.lengthSync();
    final tail = size > 66000 ? 66000 : size;
    raf.setPositionSync(size - tail);
    final buf = raf.readSync(tail);
    var eocd = -1;
    for (var i = tail - 22; i >= 0; i--) {
      if (buf[i] == 0x50 &&
          buf[i + 1] == 0x4b &&
          buf[i + 2] == 5 &&
          buf[i + 3] == 6) {
        eocd = i;
        break;
      }
    }
    if (eocd < 0) throw StateError('bad zip');
    final bd = ByteData.sublistView(buf);
    final count = bd.getUint16(eocd + 10, Endian.little);
    var off = bd.getUint32(eocd + 16, Endian.little);
    for (var i = 0; i < count; i++) {
      raf.setPositionSync(off);
      final h = raf.readSync(46);
      final hd = ByteData.sublistView(h);
      if (hd.getUint32(0, Endian.little) != 0x02014b50) break;
      final method = hd.getUint16(10, Endian.little);
      final csize = hd.getUint32(20, Endian.little);
      final nlen = hd.getUint16(28, Endian.little);
      final elen = hd.getUint16(30, Endian.little);
      final nameBytes = raf.readSync(nlen);
      final fname = utf8.decode(nameBytes);
      final localOff = hd.getUint32(42, Endian.little);
      off += 46 + nlen + elen;
      if (fname != name) continue;
      raf.setPositionSync(localOff);
      final lh = raf.readSync(30);
      final lhd = ByteData.sublistView(lh);
      final lnlen = lhd.getUint16(26, Endian.little);
      final lelen = lhd.getUint16(28, Endian.little);
      raf.setPositionSync(localOff + 30 + lnlen + lelen);
      final data = raf.readSync(csize);
      if (method == 0) return data;
      if (method == 8)
        return Uint8List.fromList(ZLibDecoder().decodeBytes(data, raw: true));
      throw StateError('unsupported zip method $method');
    }
    throw StateError('$name not in apk');
  } finally {
    raf.closeSync();
  }
}

ApkInfo parseApk(File apk) {
  final info = ApkInfo();
  try {
    final axml = _apkEntry(apk, 'AndroidManifest.xml');
    _parseManifest(axml, info);
  } catch (_) {}
  return info;
}

void _parseManifest(Uint8List data, ApkInfo info) {
  final r = _Reader(ByteData.sublistView(data));
  if (r.u32() != 0x00080003) return; // AXML magic
  r.u32(); // file size
  final strings = <String>[];
  final resIds = <int>[];

  while (r.p < data.length - 8) {
    final type = r.u16();
    r.u16(); // header size
    final chunkSize = r.u32();
    final chunkEnd = (r.p - 8) + chunkSize;
    switch (type) {
      case 0x0001: // string pool
        final count = r.u32();
        r.u32(); // style count
        final flags = r.u32();
        final isUtf8 = (flags & 0x100) != 0;
        final stringsStart = r.u32();
        r.u32();
        final offsets = List.generate(count, (_) => r.u32());
        for (final o in offsets) {
          final base = (r.p - 8) - count * 4 + stringsStart + o;
          if (isUtf8) {
            var q = base;
            var len = data[q++];
            if (len & 0x80 != 0) len = ((len & 0x7f) << 8) | data[q++];
            var ulen = data[q++];
            if (ulen & 0x80 != 0) ulen = ((ulen & 0x7f) << 8) | data[q++];
            strings.add(utf8.decode(data.sublist(q, q + ulen)));
          } else {
            var q = base;
            var len = data[q] | (data[q + 1] << 8);
            q += 2;
            if (len & 0x8000 != 0)
              len = ((len & 0x7fff) << 16) | (data[q] | (data[q + 1] << 8));
            final u16 = Uint16List(len);
            for (var i = 0; i < len; i++) {
              u16[i] = data[q + i * 2] | (data[q + i * 2 + 1] << 8);
            }
            strings.add(String.fromCharCodes(u16));
          }
        }
        break;
      case 0x0180: // resource map
        final n = (chunkSize - 8) ~/ 4;
        for (var i = 0; i < n; i++) {
          resIds.add(r.u32());
        }
        break;
      case 0x0102: // start element
        r.u32(); // line
        r.u32(); // comment
        r.u32(); // ns
        final nameIdx = r.u32();
        final name = nameIdx < strings.length ? strings[nameIdx] : '';
        r.u32(); // attr start/size
        final attrCount = r.u16();
        r.skip(6); // id/class/style idx
        final attrs = <String, (String, int, Uint8List)>{};
        for (var i = 0; i < attrCount; i++) {
          r.u32(); // ns
          final an = r.u32();
          final rv = r.u32();
          r.u16(); // raw value type marker
          final dataType = data[r.p - 1];
          final dv = r.u32();
          final aname = an < strings.length ? strings[an] : '';
          String sval = '';
          if (dataType == 3 && rv < strings.length) sval = strings[rv];
          attrs[aname] = (sval, dv, Uint8List(0));
        }
        if (name == 'manifest') {
          info.package = attrs['package']?.$1 ?? '';
          info.versionName = attrs['versionName']?.$1 ?? '';
          info.versionCode = attrs['versionCode']?.$2 ?? 0;
        } else if (name == 'application') {
          final l = attrs['label'];
          if (l != null) {
            if (l.$1.isNotEmpty) info.label = l.$1;
            info.labelRes = l.$2;
          }
        } else if (name == 'uses-sdk') {
          info.minSdk = attrs['minSdkVersion']?.$2 ?? 0;
          info.targetSdk = attrs['targetSdkVersion']?.$2 ?? 0;
        } else if (name == 'uses-permission') {
          final pn = attrs['name']?.$1 ?? '';
          if (pn.isNotEmpty) info.permissions.add(pn);
        }
        break;
    }
    if (chunkEnd > r.p) r.p = chunkEnd;
  }
}
