import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smpico/core/mcp_server.dart';
import 'package:smpico/settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HttpClient http;
  late String base;
  HttpOverrides? previousOverrides;

  Future<HttpClientResponse> post(Object? body) async {
    final req = await http.postUrl(Uri.parse(base));
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(body));
    return req.close();
  }

  setUpAll(() async {
    // flutter_test installs a mock HttpClient that 400s everything
    previousOverrides = HttpOverrides.current;
    HttpOverrides.global = null;
    SharedPreferences.setMockInitialValues({});
    await Settings.instance.init();
    await McpServer.instance.start();
    http = HttpClient();
    base = McpServer.instance.url;
  });

  tearDownAll(() async {
    http.close();
    await McpServer.instance.stop();
    HttpOverrides.global = previousOverrides;
  });

  test('initialize returns server info and a session id', () async {
    final res = await post({
      'jsonrpc': '2.0',
      'id': 1,
      'method': 'initialize',
      'params': {
        'protocolVersion': '2025-03-26',
        'capabilities': {},
        'clientInfo': {'name': 'test', 'version': '0'},
      },
    });
    expect(res.statusCode, 200);
    expect(res.headers.value('mcp-session-id'), isNotNull);
    final body = jsonDecode(await res.transform(utf8.decoder).join());
    expect(body['result']['serverInfo']['name'], 'smpico');
  });

  test('notifications get a bare 202', () async {
    final res = await post({
      'jsonrpc': '2.0',
      'method': 'notifications/initialized',
    });
    expect(res.statusCode, 202);
    await res.drain<void>();
  });

  test('tools/list exposes the tool set', () async {
    final res = await post({
      'jsonrpc': '2.0',
      'id': 2,
      'method': 'tools/list',
    });
    final body =
        jsonDecode(await res.transform(utf8.decoder).join()) as Map;
    final tools = body['result']['tools'] as List;
    final names = tools.map((t) => t['name']).toSet();
    for (final n in [
      'device_status',
      'catalog_search',
      'game_download',
      'install_local',
      'adb_shell',
    ]) {
      expect(names, contains(n));
    }
  });

  test('tools/call returns a content envelope, errors flagged', () async {
    final res = await post({
      'jsonrpc': '2.0',
      'id': 3,
      'method': 'tools/call',
      'params': {
        'name': 'no_such_tool',
        'arguments': {},
      },
    });
    final body =
        jsonDecode(await res.transform(utf8.decoder).join()) as Map;
    expect(body['result']['isError'], true);
    expect(body['result']['content'][0]['type'], 'text');
  });
}
