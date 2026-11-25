import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/log.dart';
import '../i18n.dart';
import '../theme.dart';

/// Open a URL in the browser; shows a snackbar and logs when it fails.
Future<void> openExternalUrl(BuildContext context, String url) async {
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok) dlog('openExternalUrl: launcher refused $url');
  } catch (e) {
    dlog('openExternalUrl: $url -> $e');
  }
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr('Could not open the link')),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// QPushButton equivalent: 35px high, #383838, hover #404040.
class EZButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color? color;
  final Color? textColor;
  final double fontSize;
  final String? tooltip;
  const EZButton(
    this.text, {
    super.key,
    this.onPressed,
    this.icon,
    this.height = 35,
    this.color,
    this.textColor,
    this.fontSize = 14,
    this.tooltip,
  });

  @override
  State<EZButton> createState() => _EZButtonState();
}

class _EZButtonState extends State<EZButton> {
  bool _h = false, _p = false;
  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    var bg = widget.color ?? EZColors.button;
    if (!enabled) {
      bg = bg.withOpacity(.5);
    } else if (_p) {
      bg = EZColors.buttonPressed;
    } else if (_h) {
      bg = EZColors.buttonHover;
    }
    final btn = MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _p = true) : null,
        onTapUp: enabled ? (_) => setState(() => _p = false) : null,
        onTapCancel: enabled ? () => setState(() => _p = false) : null,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: widget.height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: _p ? Border.all(color: const Color(0xFF262626)) : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: widget.fontSize + 2,
                  color: widget.textColor ?? EZColors.text,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  widget.text,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: enabled
                        ? (widget.textColor ?? EZColors.text)
                        : const Color(0xFF5A5A5A),
                    fontWeight: FontWeight.w600,
                    fontSize: widget.fontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return widget.tooltip != null
        ? Tooltip(message: widget.tooltip!, child: btn)
        : btn;
  }
}

/// Icon button (40px default hit area).
class EZIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? color;
  const EZIconButton(
    this.icon, {
    super.key,
    this.onPressed,
    this.tooltip,
    this.size = 32,
    this.color,
  });

  @override
  State<EZIconButton> createState() => _EZIconButtonState();
}

class _EZIconButtonState extends State<EZIconButton> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final b = MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _h ? const Color(0xFF3B3B3B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            size: widget.size * .6,
            color:
                widget.color ??
                (widget.onPressed != null
                    ? EZColors.text
                    : const Color(0xFF5A5A5A)),
          ),
        ),
      ),
    );
    return widget.tooltip != null
        ? Tooltip(message: widget.tooltip!, child: b)
        : b;
  }
}

/// The big rounded container (#container, rgba(46,46,46,.6), radius 20)
/// with a label on top — mirrors Container + #containerLabel.
class EZPanel extends StatelessWidget {
  final String? label;
  final Widget child;
  final EdgeInsets padding;
  const EZPanel({
    super.key,
    this.label,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(label!, style: EZText.containerLabel),
          ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: EZColors.container,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ],
    );
  }
}

class HSeparator extends StatelessWidget {
  const HSeparator({super.key});
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: EZColors.separator);
}

class VSeparator extends StatelessWidget {
  const VSeparator({super.key});
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, color: EZColors.separator);
}

/// Empty-state plug (icon + title + subtitle centered).
class EmptyPlug extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const EmptyPlug(this.icon, this.title, {super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/sad.png',
            height: 72,
            errorBuilder: (_, __, ___) =>
                Icon(icon, size: 56, color: EZColors.textDim),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8A8A8A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: EZColors.textDim, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small dot (link status etc.)
class StatusDot extends StatelessWidget {
  final Color color;
  final double size;
  const StatusDot(this.color, {super.key, this.size = 8});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(size / 2),
    ),
  );
}

/// Green check circle for cracked matrix.
Widget sectionHeader(String text) => Padding(
  padding: const EdgeInsets.only(top: 14, bottom: 6),
  child: Text(text.toUpperCase(), style: EZText.group),
);
