import 'package:flutter/material.dart';
import 'package:window_manager/legacy.dart';
import 'i18n.dart';
import 'settings.dart';
import 'theme.dart';
import 'widgets/sidebar.dart';
import 'widgets/welcome.dart';
import 'pages/device_page.dart';
import 'pages/install_page.dart';
import 'pages/app_manager_page.dart';
import 'pages/files_page.dart';
import 'pages/stream_page.dart';
import 'pages/picoland_page.dart';
import 'pages/community_page.dart';
import 'pages/settings_page.dart';
import 'pages/donate_page.dart';

class NavItem {
  final IconData icon;
  final String labelKey;
  final Widget page;
  const NavItem(this.icon, this.labelKey, this.page);
}

final navItems = <NavItem>[
  NavItem(Icons.headset, 'Device', const DevicePage()),
  NavItem(Icons.download, 'Install', const InstallPage()),
  NavItem(Icons.apps, 'App Manager', const AppManagerPage()),
  NavItem(Icons.folder, 'File Manager', const FilesPage()),
  NavItem(Icons.cast, 'Stream', const StreamPage()),
  NavItem(Icons.videogame_asset, 'PicoLand Games', const PicoLandPage()),
  NavItem(Icons.forum, 'Community', const CommunityPage()),
  NavItem(Icons.settings, 'Settings', const SettingsPage()),
  NavItem(Icons.volunteer_activism, 'Support', const DonatePage()),
];

class MainWindow extends StatefulWidget {
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow> {
  int _page = 0;
  bool _welcomeShown = false;

  @override
  void initState() {
    super.initState();
    I18n.instance.addListener(_rebuild);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Settings.instance.get('welcome_accepted', false)) {
        _showWelcome();
      }
    });
  }

  void _rebuild() => setState(() {});

  Future<void> _showWelcome() async {
    if (_welcomeShown) return;
    _welcomeShown = true;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const WelcomeDialog(),
    );
    if (accepted == true) {
      await Settings.instance.set('welcome_accepted', true);
    } else {
      _welcomeShown = false;
    }
  }

  @override
  void dispose() {
    I18n.instance.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EZColors.bg,
      body: Column(
        children: [
          const TitleBar(),
          Expanded(
            child: Row(
              children: [
                Sidebar(
                  items: navItems,
                  selected: _page,
                  onSelect: (i) => setState(() => _page = i),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.only(bottomRight: Radius.circular(10)),
                    child: IndexedStack(
                      index: _page,
                      children: navItems.map((n) => n.page).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: const BoxDecoration(
        color: EZColors.bg,
        borderRadius: BorderRadius.only(topRight: Radius.circular(10)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Image.asset('assets/icons/ezpico_white.png', height: 18,
              errorBuilder: (_, __, ___) => const SizedBox()),
          const SizedBox(width: 8),
          Image.asset('assets/icons/ezpico_word.png', height: 14,
              errorBuilder: (_, __, ___) =>
                  const Text('EZPico', style: TextStyle(fontSize: 12))),
          Expanded(child: DragToMoveArea(child: const SizedBox.expand())),
          _TitleBtn(
            icon: Icons.notifications_none,
            tooltip: tr('Notifications'),
            onTap: () {},
          ),
          _TitleBtn(
            icon: Icons.remove,
            tooltip: tr('Min'),
            onTap: () => windowManager.minimize(),
          ),
          _TitleBtn(
            icon: Icons.crop_square,
            tooltip: tr('Max'),
            onTap: () async {
              if (await windowManager.isMaximized()) {
                windowManager.unmaximize();
              } else {
                windowManager.maximize();
              }
            },
          ),
          _TitleBtn(
            icon: Icons.close,
            tooltip: tr('Exit'),
            hover: EZColors.exitHover,
            press: EZColors.exitPressed,
            onTap: () => windowManager.close(),
          ),
        ],
      ),
    );
  }
}

class _TitleBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? hover;
  final Color? press;
  const _TitleBtn(
      {required this.icon,
      required this.tooltip,
      required this.onTap,
      this.hover,
      this.press});

  @override
  State<_TitleBtn> createState() => _TitleBtnState();
}

class _TitleBtnState extends State<_TitleBtn> {
  bool _h = false, _p = false;
  @override
  Widget build(BuildContext context) {
    final bg = _p
        ? (widget.press ?? const Color(0xFF4C4C4C))
        : _h
            ? (widget.hover ?? const Color(0xFF363636))
            : Colors.transparent;
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _p = true),
          onTapUp: (_) => setState(() => _p = false),
          onTapCancel: () => setState(() => _p = false),
          onTap: widget.onTap,
          child: Container(
            width: 40,
            height: 38,
            color: bg,
            child: Icon(widget.icon, size: 16, color: EZColors.text),
          ),
        ),
      ),
    );
  }
}
