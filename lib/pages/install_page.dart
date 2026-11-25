import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../core/devices.dart';
import '../core/downloads.dart';
import '../core/installer.dart';
import '../i18n.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/install_options.dart';

class InstallPage extends StatefulWidget {
  const InstallPage({super.key});

  @override
  State<InstallPage> createState() => _InstallPageState();
}

class _InstallPageState extends State<InstallPage> {
  InstallOptions _options = InstallOptions();
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    Installer.instance.addListener(_r);
    Downloads.instance.addListener(_r);
    Devices.instance.addListener(_r);
  }

  void _r() => setState(() {});
  @override
  void dispose() {
    Installer.instance.removeListener(_r);
    Downloads.instance.removeListener(_r);
    Devices.instance.removeListener(_r);
    super.dispose();
  }

  Future<void> _pickFiles() async {
    const group = XTypeGroup(
      label: 'Installers',
      extensions: ['apk', 'zip', '7z', 'rar', '001'],
    );
    final files = await openFiles(acceptedTypeGroups: [group]);
    for (final f in files) {
      Installer.instance.enqueue(f.path, p.basename(f.path), _options.copy());
    }
  }

  Future<void> _pickFolder() async {
    final dir = await getDirectoryPath();
    if (dir != null) {
      Installer.instance.enqueue(dir, p.basename(dir), _options.copy());
    }
  }

  Future<void> _openOptions() async {
    final o = await showInstallOptionsDialog(context, _options.copy());
    if (o != null) setState(() => _options = o);
  }

  @override
  Widget build(BuildContext context) {
    final connected = Devices.instance.connected;
    final jobs = Installer.instance.jobs;
    final dlJobs = Downloads.instance.jobs;
    return Container(
      color: EZColors.page,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // left: settings panel
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
                  Text(tr('Installation'), style: EZText.section),
                  const SizedBox(height: 4),
                  Text(
                    tr(
                      'APK, ZIP, 7z, RAR, multi-part .001 or a folder with them',
                    ),
                    style: EZText.hint,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: EZButton(
                          tr('Choose files…'),
                          onPressed: connected ? _pickFiles : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: EZButton(
                          tr('Choose folder…'),
                          onPressed: connected ? _pickFolder : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(tr('Mode').toUpperCase(), style: EZText.group),
                  const SizedBox(height: 6),
                  _ModeSegment(
                    auto: _options.method == InstallMethod.auto,
                    onChanged: (a) => setState(
                      () => _options.method = a
                          ? InstallMethod.auto
                          : InstallMethod.repack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _options.method == InstallMethod.auto
                        ? tr(
                            'SMPico picks the method itself (Matrix 9.9.9 — clean install, OVRport — direct, otherwise repack)',
                          )
                        : tr('Each option is chosen by hand'),
                    style: EZText.hint,
                  ),
                  if (Devices.instance.info?.matrixCracked == true ||
                      Devices.instance.info?.isPhoenixOvs == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        tr(
                          'On this headset (Matrix 9.9.9) Auto installs the APK directly: repack and signing are not used',
                        ),
                        style: EZText.hint.copyWith(color: EZColors.accent),
                      ),
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(tr('Install settings'), style: EZText.section),
                      const Spacer(),
                      EZButton(
                        _options.method == InstallMethod.auto
                            ? tr('auto')
                            : tr('manual options'),
                        height: 28,
                        fontSize: 11,
                        icon: Icons.settings,
                        tooltip: tr(
                          'Download with install settings… (method, cache, signing, or download only)',
                        ),
                        onPressed: _openOptions,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr('Applies to the next files you add, then resets'),
                    style: EZText.hint,
                  ),
                  if (!connected) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: EZColors.banner,
                        border: Border.all(color: EZColors.bannerBorder),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tr('Files can be added once the headset is connected'),
                        style: const TextStyle(
                          color: EZColors.warn,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(tr('Queue').toUpperCase(), style: EZText.group),
                  const SizedBox(height: 6),
                  Text(tr('{} item(s)', [jobs.length]), style: EZText.hint),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // right: drop zone + cards
          Expanded(
            child: DropTarget(
              onDragEntered: (_) => setState(() => _dragging = true),
              onDragExited: (_) => setState(() => _dragging = false),
              onDragDone: (d) {
                setState(() => _dragging = false);
                if (!connected) return;
                for (final f in d.files) {
                  Installer.instance.enqueue(
                    f.path,
                    p.basename(f.path),
                    _options.copy(),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  border: Border.all(
                    color: _dragging
                        ? EZColors.accent
                        : connected
                        ? const Color(0xFF3A3A3A)
                        : const Color(0xFF4A3D22),
                    style: _dragging ? BorderStyle.solid : BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: dlJobs.isEmpty && jobs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF26301A),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Icon(
                                Icons.download,
                                color: EZColors.accent,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              connected
                                  ? tr('Drop an APK, archive or folder here')
                                  : tr('Connect a headset to install'),
                              style: const TextStyle(
                                color: Color(0xFFECECEC),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr('Drop files anywhere on this page'),
                              style: EZText.hint,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: dlJobs.length + jobs.length,
                        itemBuilder: (_, i) => i < dlJobs.length
                            ? _DownloadCard(dlJobs[i])
                            : _JobCard(jobs[i - dlJobs.length]),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  final bool auto;
  final ValueChanged<bool> onChanged;
  const _ModeSegment({required this.auto, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2E2E2E)),
      ),
      child: Row(
        children: [
          _seg(tr('Auto'), auto, () => onChanged(true)),
          _seg(tr('Manual'), !auto, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _seg(String t, bool sel, VoidCallback tap) {
    return Expanded(
      child: GestureDetector(
        onTap: tap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFF333333) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            t,
            style: TextStyle(
              color: sel ? EZColors.textBright : EZColors.textDim,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _JobCard extends StatefulWidget {
  final InstallJob job;
  const _JobCard(this.job);

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    widget.job.addListener(_r);
  }

  void _r() => setState(() {});
  @override
  void dispose() {
    widget.job.removeListener(_r);
    super.dispose();
  }

  Color _stateColor(JobState s) => switch (s) {
    JobState.waiting => EZColors.textDim,
    JobState.running => EZColors.warn,
    JobState.done => EZColors.ok,
    JobState.failed => EZColors.bad,
    JobState.cancelled => const Color(0xFF8A8A8A),
  };

  String _stateText(JobState s) => switch (s) {
    JobState.waiting => 'Waiting',
    JobState.running => 'In progress',
    JobState.done => 'Successful',
    JobState.failed => 'Error',
    JobState.cancelled => 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    final j = widget.job;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: cardDecoration(),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          j.displayName,
                          style: EZText.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          j.error ?? j.stage,
                          style: EZText.hint.copyWith(
                            color: j.state == JobState.failed
                                ? EZColors.bad
                                : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    tr(_stateText(j.state)),
                    style: TextStyle(
                      color: _stateColor(j.state),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (j.state == JobState.running ||
                      j.state == JobState.waiting)
                    EZIconButton(
                      Icons.close,
                      tooltip: tr('Cancel'),
                      size: 26,
                      onPressed: () => Installer.instance.cancel(j),
                    ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: EZColors.textDim,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (j.state == JobState.running)
            LinearProgressIndicator(
              value: j.progress > 0 ? j.progress : null,
              minHeight: 3,
              backgroundColor: const Color(0xFF2C2C2C),
              valueColor: const AlwaysStoppedAnimation(EZColors.warn),
            ),
          if (_expanded)
            Container(
              height: 160,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: EZColors.consoleBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2C2C2C)),
              ),
              child: ListView.builder(
                itemCount: j.log.length,
                itemBuilder: (_, i) => SelectableText(
                  j.log[i],
                  style: EZText.console.copyWith(fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DownloadCard extends StatefulWidget {
  final DownloadJob job;
  const _DownloadCard(this.job);

  @override
  State<_DownloadCard> createState() => _DownloadCardState();
}

class _DownloadCardState extends State<_DownloadCard> {
  @override
  void initState() {
    super.initState();
    widget.job.addListener(_r);
  }

  void _r() => setState(() {});
  @override
  void dispose() {
    widget.job.removeListener(_r);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.job;
    final active =
        j.state == 'waiting' ||
        j.state == 'downloading' ||
        j.state == 'unpacking';
    final stateText = switch (j.state) {
      'downloading' => tr('Downloading… {} of {}', [
        fmtBytes(j.received),
        j.total > 0 ? fmtBytes(j.total) : '?',
      ]),
      'unpacking' => tr('Unpacking…'),
      'done' => tr('Successful'),
      'failed' => tr('Error'),
      _ => tr('Waiting'),
    };
    final stateColor = switch (j.state) {
      'done' => EZColors.ok,
      'failed' => EZColors.bad,
      'waiting' => EZColors.textDim,
      _ => EZColors.warn,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: cardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_download,
                  size: 18,
                  color: EZColors.textDim,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        j.title,
                        style: EZText.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        j.error ?? j.outPath ?? j.url,
                        style: EZText.hint.copyWith(
                          color: j.state == 'failed' ? EZColors.bad : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  stateText,
                  style: TextStyle(
                    color: stateColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                if (active)
                  EZIconButton(
                    Icons.close,
                    tooltip: tr('Cancel'),
                    size: 26,
                    onPressed: () => Downloads.instance.cancel(j),
                  )
                else
                  EZIconButton(
                    Icons.close,
                    tooltip: tr('Remove'),
                    size: 26,
                    onPressed: () => Downloads.instance.remove(j),
                  ),
              ],
            ),
          ),
          if (active)
            LinearProgressIndicator(
              value: j.progress > 0 ? j.progress : null,
              minHeight: 3,
              backgroundColor: const Color(0xFF2C2C2C),
              valueColor: const AlwaysStoppedAnimation(EZColors.accent),
            ),
        ],
      ),
    );
  }
}
