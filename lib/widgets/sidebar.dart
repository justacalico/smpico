import 'package:flutter/material.dart';
import '../app.dart';
import '../i18n.dart';
import '../theme.dart';

/// Left sidebar: transparent buttons, sliding indicator with a bright
/// bar on its left edge (#sidebarIndicator + #sidebarIndicatorBar).
class Sidebar extends StatelessWidget {
  final List<NavItem> items;
  final int selected;
  final ValueChanged<int> onSelect;
  const Sidebar(
      {super.key,
      required this.items,
      required this.selected,
      required this.onSelect});

  static const itemH = 52.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 208,
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
                  color: const Color(0xFF242424),
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
                    label: tr(items[i].labelKey),
                    selected: i == selected,
                    onTap: () => onSelect(i),
                  ),
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
  final VoidCallback onTap;
  const _SidebarButton(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  State<_SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<_SidebarButton> {
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
          height: Sidebar.itemH,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: _h && !widget.selected
                ? const Color(0xFF282828)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x00262626)),
          ),
          child: Row(
            children: [
              Icon(widget.icon,
                  size: 18,
                  color: widget.selected
                      ? EZColors.textBright
                      : const Color(0xFF5A5A5A)),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.selected
                      ? EZColors.textBright
                      : const Color(0xFF5A5A5A),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
