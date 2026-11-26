import 'package:flutter/material.dart';

import '../app.dart';
import '../i18n.dart';
import '../theme.dart';
import 'download_queue.dart';

/// Left sidebar: transparent buttons, sliding indicator with a bright
/// bar on its left edge (#sidebarIndicator + #sidebarIndicatorBar).
/// [compact] collapses it to an icon rail for narrow windows.
class Sidebar extends StatelessWidget {
  final List<NavItem> items;
  final int selected;
  final ValueChanged<int> onSelect;
  final bool compact;
  const Sidebar({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
    this.compact = false,
  });

  static const itemH = 52.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: compact ? 60 : 208,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 4),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              top: selected * itemH,
              left: 0,
              right: 0,
              height: itemH,
              child: Container(
                decoration: BoxDecoration(
                  color: EZColors.card,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 3,
                    height: 26,
                    margin: const EdgeInsets.only(left: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E6E6),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                for (var i = 0; i < items.length; i++)
                  _SidebarButton(
                    icon: items[i].icon,
                    label: _navLabel(items[i].labelKey),
                    selected: i == selected,
                    compact: compact,
                    onTap: () => onSelect(i),
                  ),
                const Spacer(),
                DownloadQueueButton(compact: compact),
                const SizedBox(height: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;
  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  @override
  State<_SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<_SidebarButton> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: Sidebar.itemH,
          padding: EdgeInsets.symmetric(horizontal: widget.compact ? 0 : 15),
          decoration: BoxDecoration(
            color: _h && !widget.selected
                ? const Color(0xFF282828)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x00262626)),
          ),
          child: widget.compact
              ? Center(
                  child: Icon(
                    widget.icon,
                    size: 20,
                    color: widget.selected
                        ? EZColors.textBright
                        : const Color(0xFF5A5A5A),
                  ),
                )
              : ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: 180,
                    child: Row(
                      children: [
                        Icon(
                          widget.icon,
                          size: 18,
                          color: widget.selected
                              ? EZColors.textBright
                              : const Color(0xFF5A5A5A),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.selected
                                  ? EZColors.textBright
                                  : const Color(0xFF5A5A5A),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
    return widget.compact
        ? Tooltip(message: widget.label, child: button)
        : button;
  }
}

String _navLabel(String key) => switch (key) {
  'Device' => t.device,
  'Install' => t.install,
  'App Manager' => t.appManager,
  'File Manager' => t.fileManager,
  'Stream' => t.stream,
  'PicoLand Games' => t.picolandGames,
  'Settings' => t.settings,
  _ => key,
};
