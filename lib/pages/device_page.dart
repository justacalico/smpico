import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../core/adb.dart';
import '../core/devices.dart';
import '../core/paths.dart';
import '../i18n.dart';
import '../theme.dart';
import '../widgets/common.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  @override
  void initState() {
    super.initState();
    Devices.instance.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    Devices.instance.removeListener(_onChange);
    super.dispose();
  }

  String _headsetImage(DeviceInfo d) {
    final m = d.model.toLowerCase();
    if (m.contains('ultra')) return 'assets/icons/p4u.png';
    if (m.contains('4e') || m.contains('enterprise')) {
      return 'assets/icons/p4e.png';
    }
    if (m.contains('pico') || m.contains('p4') || m.contains('phoenix')) {
      return 'assets/icons/p4.png';
    }
    return 'assets/icons/unknown headset.png';
  }

  Future<void> _screenshot() async {
    final dir = await AppPaths.screenshots();
    await dir.create(recursive: true);
    final name = 'screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
    await Adb.instance.shell('screencap -p /sdcard/$name');
    await Adb.instance.pull('/sdcard/$name', p.join(dir.path, name));
    await Adb.instance.rm('/sdcard/$name');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Screenshot saved: {}', [name]))),
      );
      if (await File(p.join(dir.path, name)).exists()) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final devs = Devices.instance;
    final d = devs.info;
    return Container(
      color: EZColors.page,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _DeviceSelector(),
              const Spacer(),
              if (d != null)
                Text(
                  '${tr('Serial number: {}', [d.serial])}  ·  ${d.wifi ? 'Wi-Fi' : 'USB'}',
                  style: EZText.hint,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: d == null
                ? EmptyPlug(
                    Icons.usb_off,
                    tr('No Device Connected'),
                    subtitle: tr(
                      'Connect your PICO VR headset\nand PC with a USB cable.',
                    ),
                  )
                : LayoutBuilder(
                    builder: (_, c) {
                      final card = SizedBox(
                        width: 300,
                        child: Column(
                          children: [
                            Container(
                              decoration: cardDecoration(),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Image.asset(
                                    _headsetImage(d),
                                    height: 150,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.headset, size: 90),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    d.model.isEmpty
                                        ? tr('Unknown headset')
                                        : d.model,
                                    style: const TextStyle(
                                      color: Color(0xFFF0F0F0),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _chip(
                                        d.wifi ? 'Wi-Fi' : 'USB',
                                        wifi: d.wifi,
                                      ),
                                      const SizedBox(width: 6),
                                      _chip(
                                        d.matrixCracked
                                            ? 'Matrix ${d.matrixText}'
                                            : 'Matrix ${d.matrixVersion}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _action(
                                  Icons.camera_alt,
                                  tr('Screenshot'),
                                  tr(
                                    'Save a picture of what the headset shows to the PC',
                                  ),
                                  _screenshot,
                                ),
                                _action(
                                  Icons.wifi,
                                  tr('Wi-Fi mode'),
                                  tr(
                                    'Switch to Wi-Fi: then the cable can be unplugged. The PC and the headset must be on the same network',
                                  ),
                                  () => devs.switchToWifi(),
                                ),
                                _action(
                                  Icons.restart_alt,
                                  tr('Reboot'),
                                  tr('Restart the headset'),
                                  () => Adb.instance.reboot(),
                                ),
                                _action(
                                  Icons.power_settings_new,
                                  tr('Shutdown'),
                                  tr('Turn the headset off'),
                                  () => Adb.instance.shutdown(),
                                  danger: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                      final tiles = LayoutBuilder(
                        builder: (_, tc) {
                          final cols = tc.maxWidth >= 540 ? 4 : 2;
                          final tw = (tc.maxWidth - (cols - 1) * 8) / cols;
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _tile(
                                tr('Firmware'),
                                d.firmware.isEmpty ? '—' : d.firmware,
                                sub: d.displayId,
                                width: tw,
                              ),
                              _tile(
                                tr('Battery'),
                                d.batteryPct < 0 ? '—' : '${d.batteryPct}%',
                                sub: d.charging
                                    ? tr('charging')
                                    : tr('on battery'),
                                frac: d.batteryPct < 0 ? 0 : d.batteryPct / 100,
                                state: d.batteryPct < 20 ? 'warn' : 'ok',
                                width: tw,
                              ),
                              _tile(
                                tr('Storage'),
                                fmtBytes(d.totalBytes - d.freeBytes),
                                sub: tr('free of {}', [fmtBytes(d.freeBytes)]),
                                frac: d.totalBytes > 0
                                    ? 1 - d.freeBytes / d.totalBytes
                                    : 0,
                                state:
                                    d.totalBytes > 0 &&
                                        d.freeBytes / d.totalBytes < .1
                                    ? 'bad'
                                    : 'ok',
                                width: tw,
                              ),
                              _tile(
                                'PUI Matrix',
                                d.matrixText,
                                sub: d.matrixCracked
                                    ? tr(
                                        'Protection removed — games run without license checks',
                                      )
                                    : tr(
                                        'License check is on — use OVRport or repacked games',
                                      ),
                                state: d.matrixCracked ? 'ok' : 'warn',
                                width: tw,
                              ),
                            ],
                          );
                        },
                      );
                      if (c.maxWidth < 760) {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topCenter,
                                child: card,
                              ),
                              const SizedBox(height: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  tiles,
                                  const SizedBox(height: 10),
                                  SizedBox(height: 320, child: _AdbConsole()),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              card,
                              const SizedBox(width: 12),
                              Expanded(child: tiles),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(child: _AdbConsole()),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, {bool wifi = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: wifi ? const Color(0xFF24301A) : const Color(0xFF262626),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: wifi ? EZColors.accent : const Color(0xFFBDBDBD),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _action(
    IconData icon,
    String label,
    String tip,
    VoidCallback onTap, {
    bool danger = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Tooltip(
          message: tip,
          child: _DevAction(icon, label, onTap, danger: danger),
        ),
      ),
    );
  }

  Widget _tile(
    String title,
    String value, {
    String? sub,
    double? frac,
    String state = 'ok',
    required double width,
  }) {
    final color = state == 'ok'
        ? EZColors.accent
        : state == 'warn'
        ? EZColors.warn
        : EZColors.bad;
    return Container(
      width: width,
      height: 112,
      padding: const EdgeInsets.all(12),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: EZText.group,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            sub ?? '',
            style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: frac ?? 0,
              minHeight: 4,
              backgroundColor: const Color(0xFF2C2C2C),
              valueColor: AlwaysStoppedAnimation(
                frac != null ? color : Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DevAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _DevAction(this.icon, this.label, this.onTap, {this.danger = false});

  @override
  State<_DevAction> createState() => _DevActionState();
}

class _DevActionState extends State<_DevAction> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: _h ? const Color(0xFF292929) : const Color(0xFF1F1F1F),
            border: Border.all(
              color: _h
                  ? (widget.danger ? EZColors.bad : EZColors.accent)
                  : const Color(0xFF2A2A2A),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.danger ? EZColors.bad : EZColors.text,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.label,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFFD8D8D8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Device selector dropdown (#deviceSelector).
class _DeviceSelector extends StatefulWidget {
  @override
  State<_DeviceSelector> createState() => _DeviceSelectorState();
}

class _DeviceSelectorState extends State<_DeviceSelector> {
  bool _open = false;

  @override
  void initState() {
    super.initState();
    Devices.instance.addListener(_r);
  }

  void _r() => setState(() {});
  @override
  void dispose() {
    Devices.instance.removeListener(_r);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devs = Devices.instance;
    final current = Adb.instance.device ?? tr('Not selected');
    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 46),
      color: const Color(0xFF242424),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
      onOpened: () => setState(() => _open = true),
      onCanceled: () => setState(() => _open = false),
      onSelected: (s) {
        setState(() => _open = false);
        Devices.instance.selectDevice(s);
      },
      itemBuilder: (_) => devs.serials
          .map(
            (s) => PopupMenuItem<String>(
              value: s,
              child: Text(
                s,
                style: TextStyle(
                  color: s == Adb.instance.device
                      ? EZColors.accent
                      : const Color(0xFFD8D8D8),
                  fontSize: 12,
                  fontWeight: s == Adb.instance.device
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _open ? const Color(0xFF2F2F2F) : const Color(0xFF262626),
          border: Border.all(
            color: _open ? EZColors.accent : const Color(0xFF3A3A3A),
          ),
          borderRadius: BorderRadius.circular(19),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusDot(
              devs.connected ? EZColors.accent : EZColors.textDim,
              size: 8,
            ),
            const SizedBox(width: 8),
            Text(
              current,
              style: const TextStyle(
                color: Color(0xFFE6E6E6),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, color: EZColors.accent, size: 18),
          ],
        ),
      ),
    );
  }
}

/// ADB console with history + saved commands.
class _AdbConsole extends StatefulWidget {
  @override
  State<_AdbConsole> createState() => _AdbConsoleState();
}

class _AdbConsoleState extends State<_AdbConsole> {
  final _ctrl = TextEditingController();
  final _out = <String>[];
  final _history = <String>[];
  int _histPos = -1;
  List<String> _saved = [];
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final f = await AppPaths.savedCommandsFile();
    if (await f.exists()) {
      setState(
        () => _saved = List<String>.from(jsonDecode(f.readAsStringSync())),
      );
    }
  }

  Future<void> _saveCommands() async {
    final f = await AppPaths.savedCommandsFile();
    await f.writeAsString(jsonEncode(_saved));
  }

  Future<void> _run() async {
    final cmd = _ctrl.text.trim();
    if (cmd.isEmpty || _running) return;
    _ctrl.clear();
    _history.add(cmd);
    _histPos = _history.length;
    setState(() {
      _out.add('adb shell $cmd');
      _running = true;
    });
    try {
      final res = await Adb.instance.shell(cmd);
      setState(() => _out.add(res.isEmpty ? '(ok)' : res));
    } catch (e) {
      setState(() => _out.add('error: $e'));
    }
    setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(tr('ADB Command'), style: EZText.section),
            const Spacer(),
            if (_saved.isNotEmpty)
              PopupMenuButton<String>(
                tooltip: tr('Saved commands'),
                color: const Color(0xFF242424),
                onSelected: (c) {
                  _ctrl.text = c;
                  _run();
                },
                itemBuilder: (_) => _saved
                    .map(
                      (c) => PopupMenuItem(
                        value: c,
                        child: SizedBox(
                          width: 360,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _saved.remove(c);
                                  _saveCommands();
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                child: const Icon(Icons.close, size: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    '…',
                    style: TextStyle(color: EZColors.accent, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: EZColors.consoleBg,
              border: Border.all(color: const Color(0xFF2C2C2C)),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: _out.isEmpty
                ? Text(
                    tr(
                      'Output will appear here. Double-click a saved command to run it, ↑/↓ — history.',
                    ),
                    style: EZText.console.copyWith(color: EZColors.textDim),
                  )
                : ListView.builder(
                    itemCount: _out.length,
                    itemBuilder: (_, i) =>
                        SelectableText(_out[i], style: EZText.console),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'adb shell',
              style: TextStyle(
                color: EZColors.accent,
                fontFamily: 'Consolas',
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KeyboardListener(
                focusNode: FocusNode()..requestFocus(),
                onKeyEvent: (e) {
                  if (e is KeyDownEvent) {
                    if (e.logicalKey == LogicalKeyboardKey.arrowUp &&
                        _histPos > 0) {
                      _histPos--;
                      _ctrl.text = _history[_histPos];
                    } else if (e.logicalKey == LogicalKeyboardKey.arrowDown &&
                        _histPos < _history.length - 1) {
                      _histPos++;
                      _ctrl.text = _history[_histPos];
                    }
                  }
                },
                child: TextField(
                  controller: _ctrl,
                  style: EZText.console.copyWith(
                    color: const Color(0xFFE6E6E6),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: EZColors.consoleBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: EZColors.accent),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (_) => _run(),
                ),
              ),
            ),
            const SizedBox(width: 6),
            EZIconButton(
              Icons.save_outlined,
              tooltip: tr('Save'),
              onPressed: () {
                final c = _ctrl.text.trim();
                if (c.isNotEmpty && !_saved.contains(c)) {
                  setState(() => _saved.add(c));
                  _saveCommands();
                }
              },
            ),
            EZButton(
              tr('Run'),
              color: EZColors.accent,
              textColor: const Color(0xFF111111),
              height: 32,
              onPressed: _running ? null : _run,
            ),
          ],
        ),
      ],
    );
  }
}
