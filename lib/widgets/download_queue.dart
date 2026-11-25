import 'package:flutter/material.dart';

import '../core/devices.dart';
import '../core/downloads.dart';
import '../i18n.dart';
import '../theme.dart';
import 'common.dart';

/// Sidebar button that opens the download queue flyout beside it.
class DownloadQueueButton extends StatefulWidget {
  final bool compact;
  const DownloadQueueButton({super.key, this.compact = false});

  @override
  State<DownloadQueueButton> createState() => _DownloadQueueButtonState();
}

class _DownloadQueueButtonState extends State<DownloadQueueButton>
    with SingleTickerProviderStateMixin {
  final _link = LayerLink();
  OverlayEntry? _overlay;
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
    reverseDuration: const Duration(milliseconds: 120),
  );

  @override
  void dispose() {
    _close(immediate: true);
    _anim.dispose();
    super.dispose();
  }

  void _close({bool immediate = false}) {
    final e = _overlay;
    if (e == null) return;
    _overlay = null;
    if (immediate || !_anim.isAnimating && _anim.value == 0) {
      e.remove();
    } else {
      _anim.reverse().whenComplete(e.remove);
    }
  }

  void _toggle() {
    if (_overlay != null) {
      _close();
      return;
    }
    _overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.topRight,
            followerAnchor: Alignment.bottomLeft,
            offset: const Offset(8, 0),
            child: FadeTransition(
              opacity: _anim.drive(CurveTween(curve: Curves.easeOut)),
              child: ScaleTransition(
                alignment: Alignment.bottomLeft,
                scale: _anim.drive(
                  Tween<double>(
                    begin: .95,
                    end: 1,
                  ).chain(CurveTween(curve: Curves.easeOut)),
                ),
                child: const _QueueFlyout(),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlay!);
    _anim.forward(from: 0);
  }

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
        final button = CompositedTransformTarget(
          link: _link,
          child: _QueueButtonBody(
            compact: widget.compact,
            icon: icon,
            active: active,
            onTap: _toggle,
          ),
        );
        return widget.compact
            ? Tooltip(message: t.downloads, child: button)
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
              : ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: 180,
                    child: Row(
                      children: [
                        widget.icon,
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            t.downloads,
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
                            style: TextStyle(
                              color: EZColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _QueueFlyout extends StatelessWidget {
  const _QueueFlyout();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 380,
        constraints: const BoxConstraints(maxHeight: 400),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF3A3A3A)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 24,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ListenableBuilder(
          listenable: Downloads.instance,
          builder: (ctx, _) {
            final jobs = Downloads.instance.jobs;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: Text(
                    t.downloads,
                    style: const TextStyle(
                      color: EZColors.textBright,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (jobs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 26,
                      horizontal: 14,
                    ),
                    child: Center(
                      child: Text(t.noDownloads, style: EZText.hint),
                    ),
                  )
                else
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                      child: Column(
                        children: [for (final j in jobs) _QueueJobRow(j)],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
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
      'downloading' => t.downloading,
      'unpacking' => t.unpacking,
      'done' => t.successful,
      'failed' => t.error,
      _ => t.waiting,
    };
    final subtitle =
        j.error ??
        (j.state == 'downloading'
            ? '${fmtBytes(j.received)} / ${j.total > 0 ? fmtBytes(j.total) : '?'}'
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
              Text(
                stateText,
                style: TextStyle(
                  color: stateColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 6),
              if (active)
                EZIconButton(
                  Icons.close,
                  tooltip: t.cancel,
                  size: 24,
                  onPressed: () => Downloads.instance.cancel(j),
                )
              else
                EZIconButton(
                  Icons.close,
                  tooltip: t.remove,
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
                valueColor: AlwaysStoppedAnimation(EZColors.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
