import 'dart:io';

import 'package:flutter/material.dart';

import '../core/adb.dart';
import '../core/devices.dart';
import '../core/log.dart';
import '../core/paths.dart';
import '../core/tools.dart';
import '../i18n.dart';
import '../settings.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Stream tab — launches scrcpy in a separate window with the same
/// option set the original exposes: eye, max size, fps, bitrate,
/// codec, audio, recording, crop.
class StreamPage extends StatefulWidget {
  const StreamPage({super.key});

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  Process? _proc;
  String _eye = 'both'; // both | left | right
  int _maxSize = 0; // 0 = native
  int _fps = 0;
  double _bitrate = 16; // Mbit/s
  String _codec = 'h264'; // h264 | h265
  bool _audio = true;
  bool _record = false;
  bool _fullscreen = false;
  bool _running = false;
  String? _error;
  String? _scrcpy;
  bool _checkingTool = true;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _eye = Settings.instance.get('stream_eye', 'both');
    _codec = Settings.instance.get('stream_codec', 'h264');
    _bitrate = Settings.instance.get('stream_bitrate', 16.0);
    _fps = Settings.instance.get('stream_fps', 0);
    _maxSize = Settings.instance.get('stream_max_size', 0);
    _audio = Settings.instance.get('stream_audio', true);
    _record = Settings.instance.get('stream_record', false);
    Devices.instance.addListener(_r);
    _checkTool();
  }

  void _r() {
    setState(() {});
    if (_scrcpy == null && !_checkingTool) _checkTool();
  }

  Future<void> _checkTool() async {
    setState(() => _checkingTool = true);
    // always take at least a second so the spinner doesn't flicker
    final s = await Future.wait([
      Tools.instance.scrcpy(),
      Future.delayed(const Duration(seconds: 1)),
    ]).then((r) => r.first as String?);
    if (!mounted) return;
    dlog("scrcpy check: ${s ?? 'not found'}");
    setState(() {
      _scrcpy = s;
      _checkingTool = false;
      _checked = true;
    });
  }

  @override
  void dispose() {
    Devices.instance.removeListener(_r);
    super.dispose();
  }

  Future<void> _start() async {
    final scrcpy = _scrcpy ?? await Tools.instance.scrcpy();
    if (scrcpy == null) {
      setState(() => _scrcpy = null);
      return;
    }
    final args = <String>[];
    if (Adb.instance.device != null) {
      args.addAll(['-s', Adb.instance.device!]);
    }
    if (_maxSize > 0) args.addAll(['-m', '$_maxSize']);
    if (_fps > 0) args.addAll(['--max-fps', '$_fps']);
    args.addAll(['-b', '${_bitrate.round()}M']);
    if (_codec == 'h265') args.addAll(['--video-codec', 'h265']);
    if (!_audio) args.add('--no-audio');
    if (_fullscreen) args.add('-f');
    if (_eye == 'left') args.addAll(['--crop', 'left']);
    if (_eye == 'right') args.addAll(['--crop', 'right']);
    if (_record) {
      final dir = await AppPaths.recordings();
      await dir.create(recursive: true);
      args.addAll([
        '-r',
        '${dir.path}/stream_${DateTime.now().millisecondsSinceEpoch}.mp4',
      ]);
    }
    dlog('scrcpy start: $scrcpy ${args.join(' ')}');
    try {
      _proc = await Process.start(scrcpy, args);
      setState(() {
        _running = true;
        _error = null;
      });
      _proc!.exitCode.then((code) {
        if (mounted) {
          setState(() {
            _running = false;
            dlog('scrcpy exited with code $code');
            if (code != 0) {
              _error = t.streamStoppedWithAnError(arg1: code);
            }
          });
        }
      });
    } catch (e) {
      dlog('scrcpy start failed: $e');
      setState(() => _error = '$e');
    }
  }

  Future<void> _stop() async {
    _proc?.kill();
    setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    final connected = Devices.instance.connected;
    final missing = _scrcpy == null && _checked;
    return Container(
      color: EZColors.page,
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: missing,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 340,
                    child: Container(
                      decoration: BoxDecoration(
                        color: EZColors.panel,
                        border: Border.all(color: const Color(0xFF2C2C2C)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: ListView(
                        children: [
                          Text(t.stream, style: EZText.section),
                          const SizedBox(height: 4),
                          Text(
                            t.showsTheHeadsetScreenInASeparate,
                            style: EZText.hint,
                          ),
                          const SizedBox(height: 14),
                          _group(t.picture),
                          _dropdown(
                            t.image,
                            _eye,
                            {
                              'both': t.bothEyes,
                              'left': t.leftEye,
                              'right': t.rightEye,
                            },
                            (v) {
                              setState(() => _eye = v);
                              Settings.instance.set('stream_eye', v);
                            },
                            hint: t.whichEyeImageToShowOneEye,
                          ),
                          _dropdown(
                            t.resolution,
                            '$_maxSize',
                            {
                              '0': t.nativePackage,
                              '1920': '1920',
                              '1280': '1280',
                              '1024': '1024',
                            },
                            (v) {
                              setState(() => _maxSize = int.parse(v));
                              Settings.instance.set(
                                'stream_max_size',
                                _maxSize,
                              );
                            },
                            hint: t.maximumSideOfThePictureInPixels,
                          ),
                          _dropdown(
                            t.frameRate,
                            '$_fps',
                            {
                              '0': t.nativePackage,
                              '72': '72',
                              '90': '90',
                              '60': '60',
                              '30': '30',
                            },
                            (v) {
                              setState(() => _fps = int.parse(v));
                              Settings.instance.set('stream_fps', _fps);
                            },
                            hint: t.framesPerSecond7290MatchesThe,
                          ),
                          _dropdown(
                            t.codec,
                            _codec,
                            {'h264': 'H.264', 'h265': 'H.265'},
                            (v) {
                              setState(() => _codec = v);
                              Settings.instance.set('stream_codec', v);
                            },
                            hint: t.h265IsSharperAtTheSame,
                          ),
                          _group(t.quality),
                          Text(
                            '${t.bitrateMbitS}: ${_bitrate.round()}',
                            style: EZText.label,
                          ),
                          Slider(
                            value: _bitrate,
                            min: 2,
                            max: 60,
                            divisions: 58,
                            activeColor: EZColors.accent,
                            onChanged: (v) => setState(() => _bitrate = v),
                            onChangeEnd: (v) =>
                                Settings.instance.set('stream_bitrate', v),
                          ),
                          Text(
                            t.imageQualityHigherSharperButNeedsA,
                            style: EZText.hint,
                          ),
                          _group(t.sound),
                          _switch(
                            t.audio,
                            t.playTheHeadsetSoundOnThePC,
                            _audio,
                            (v) {
                              setState(() => _audio = v);
                              Settings.instance.set('stream_audio', v);
                            },
                          ),
                          _switch(
                            t.recordToVideo,
                            t.saveTheStreamToAnMP4File,
                            _record,
                            (v) {
                              setState(() => _record = v);
                              Settings.instance.set('stream_record', v);
                            },
                          ),
                          _switch(
                            t.fullscreen,
                            t.openTheStreamWindowFullscreen,
                            _fullscreen,
                            (v) => setState(() => _fullscreen = v),
                          ),
                          const SizedBox(height: 16),
                          EZButton(
                            _running ? t.stopStream : t.startStream,
                            icon: _running ? Icons.stop : Icons.play_arrow,
                            color: _running ? EZColors.bad : EZColors.accent,
                            textColor: _running
                                ? Colors.white
                                : const Color(0xFF111111),
                            onPressed: connected
                                ? (_running ? _stop : _start)
                                : null,
                          ),
                          if (_running)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                t.streamingWindowIsOpen,
                                style: EZText.hint.copyWith(
                                  color: EZColors.accent,
                                ),
                              ),
                            ),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _error!,
                                style: EZText.hint.copyWith(
                                  color: EZColors.bad,
                                ),
                              ),
                            ),
                          if (Devices.instance.info != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                t.headsetIsAsleepThePictureWillBe,
                                style: EZText.hint,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: cardDecoration(),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/headset.png',
                              height: 140,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.cast,
                                size: 80,
                                color: EZColors.textDim,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(t.headsetScreenOnThePC, style: EZText.title),
                            const SizedBox(height: 6),
                            Text(
                              connected
                                  ? t.pressStartStreamASeparateScrcpyWindow
                                  : t.connectAHeadsetToInstall,
                              style: EZText.hint,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (missing)
            Positioned.fill(child: Container(color: const Color(0xC41F1F1F))),
          if (missing) Center(child: _missingCard()),
        ],
      ),
    );
  }

  Widget _missingCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.scrcpyNotFound, style: EZText.section),
          const SizedBox(height: 8),
          Text(t.theStreamTabNeedsScrcpyToShow, style: EZText.label),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              EZButton(
                t.getScrcpy,
                icon: Icons.download,
                color: EZColors.accent,
                textColor: const Color(0xFF111111),
                onPressed: () => openExternalUrl(
                  context,
                  'https://github.com/Genymobile/scrcpy/releases',
                ),
              ),
              const SizedBox(width: 8),
              _checkingTool
                  ? const SizedBox(
                      width: 86,
                      height: 34,
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: EZColors.textDim,
                          ),
                        ),
                      ),
                    )
                  : EZButton(t.checkAgain, onPressed: _checkTool),
            ],
          ),
        ],
      ),
    );
  }

  Widget _group(String t) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Text(t.toUpperCase(), style: EZText.group),
  );

  Widget _dropdown(
    String label,
    String value,
    Map<String, String> items,
    ValueChanged<String> onChanged, {
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFE4E4E4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: EZColors.consoleBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2C2C2C)),
                ),
                child: DropdownButton<String>(
                  value: value,
                  isDense: true,
                  underline: const SizedBox(),
                  dropdownColor: EZColors.card,
                  style: const TextStyle(
                    color: EZColors.textBright,
                    fontSize: 12,
                  ),
                  items: items.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => onChanged(v!),
                ),
              ),
            ],
          ),
          if (hint != null) Text(hint, style: EZText.hint),
        ],
      ),
    );
  }

  Widget _switch(
    String label,
    String hint,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFE4E4E4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(hint, style: EZText.hint),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: EZColors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
