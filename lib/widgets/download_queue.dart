import 'package:flutter/material.dart';

import '../core/devices.dart';
import '../core/downloads.dart';
import '../i18n.dart';
import '../theme.dart';
import 'common.dart';

/// Sidebar button that opens the download queue popup from any page.
class DownloadQueueButton extends StatelessWidget {
  final bool compact;
  const DownloadQueueButton({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Downloads.instance,
      builder: (context, _) {
        final active = Downloads.instance.jobs
            .where(
              (j) =>
                  j.state == 'waiting' ||
                  j.state == 'downloading' ||
                  j.state == 'unpacking',
            )
            .length;
        final icon = Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.cloud_download,
              size: 20,
              color: Color(0xFF5A5A5A),
            ),
            if (active > 0)
              Positioned(
                right: -7,
                top: -5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: EZColors.accent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    '$active',
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        );
        final button = _QueueButtonBody(
          compact: compact,
          icon: icon,
          active: active,
          onTap: () => showDownloadQueue(context),
        );
        return compact
            ? Tooltip(message: tr('Downloads'), child: button)
            : button;
      },
    );
  }
}

class _QueueButtonBody extends StatefulWidget {
  final bool compact;
  final Widget icon;
  final int active;
  final VoidCallback onTap;
  const _QueueButtonBody({
    required this.compact,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  State<_QueueButtonBody> createState() => _QueueButtonBodyState();
}

class _QueueButtonBodyState extends State<_QueueButtonBody> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 52,
          padding: EdgeInsets.symmetric(horizontal: widget.compact ? 0 : 15),
          decoration: BoxDecoration(
            color: _h ? const Color(0xFF282828) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: widget.compact
              ? Center(child: widget.icon)
              : Row(
                  children: [
                    widget.icon,
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tr('Downloads'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF5A5A5A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.active > 0)
                      Text(
                        '${widget.active}',
                        style: const TextStyle(
                          color: EZColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

void showDownloadQueue(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF262626),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(
        tr('Downloads'),
        style: const TextStyle(
          color: EZColors.textBright,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 440,
        child: ListenableBuilder(
          listenable: Downloads.instance,
          builder: (ctx, _) {
            final jobs = Downloads.instance.jobs;
            if (jobs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(tr('No downloads'), style: EZText.hint),
                ),
              );
            }
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: SingleChildScrollView(
                child: Column(
                  children: [for (final j in jobs) _QueueJobRow(j)],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(tr('Close')),
        ),
      ],
    ),
  );
}

class _QueueJobRow extends StatefulWidget {
  final DownloadJob job;
  const _QueueJobRow(this.job);

  @override
  State<_QueueJobRow> createState() => _QueueJobRowState();
}

class _QueueJobRowState extends State<_QueueJobRow> {
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
      'downloading' => tr('Downloading…'),
      'unpacking' => tr('Unpacking…'),
      'done' => tr('Successful'),
      'failed' => tr('Error'),
      _ => tr('Waiting'),
    };
    final subtitle =
        j.error ??
        (j.state == 'downloading'
            ? tr('Downloading… {} of {}', [
                fmtBytes(j.received),
                j.total > 0 ? fmtBytes(j.total) : '?',
              ])
            : (j.outPath ?? j.url));
    final stateColor = switch (j.state) {
      'done' => EZColors.ok,
      'failed' => EZColors.bad,
      'waiting' => EZColors.textDim,
      _ => EZColors.accent,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: cardDecoration(radius: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      j.title,
                      style: const TextStyle(
                        color: EZColors.textBright,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: EZText.hint.copyWith(
                        color: j.state == 'failed' ? EZColors.bad : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  stateText,
                  style: TextStyle(
                    color: stateColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              if (active)
                EZIconButton(
                  Icons.close,
                  tooltip: tr('Cancel'),
                  size: 24,
                  onPressed: () => Downloads.instance.cancel(j),
                )
              else
                EZIconButton(
                  Icons.close,
                  tooltip: tr('Remove'),
                  size: 24,
                  onPressed: () => Downloads.instance.remove(j),
                ),
            ],
          ),
          if (active) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: j.progress > 0 ? j.progress : null,
                minHeight: 3,
                backgroundColor: const Color(0xFF2C2C2C),
                valueColor: const AlwaysStoppedAnimation(EZColors.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
