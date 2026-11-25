import 'package:flutter/material.dart';
import 'package:window_manager/legacy.dart';

import 'core/downloads.dart';
import 'core/installer.dart';
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
import 'pages/settings_page.dart';

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
  NavItem(Icons.settings, 'Settings', const SettingsPage()),
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
            child: LayoutBuilder(
              builder: (_, c) => Row(
                children: [
                  Sidebar(
                    items: navItems,
                    selected: _page,
                    compact: c.maxWidth < 900,
                    onSelect: (i) => setState(() => _page = i),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(10),
                      ),
                      child: IndexedStack(
                        index: _page,
                        children: navItems.map((n) => n.page).toList(),
                      ),
                    ),
                  ),
                ],
              ),
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
          Icon(Icons.headset, size: 16, color: EZColors.accent),
          const SizedBox(width: 8),
          const Text(
            'SMPico',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: EZColors.textBright,
              letterSpacing: 0.6,
            ),
          ),
          Expanded(child: DragToMoveArea(child: const SizedBox.expand())),
          _TitleBtn(
            icon: Icons.notifications_none,
            tooltip: tr('Notifications'),
            onTap: () => _showNotifications(context),
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
  const _TitleBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.hover,
    this.press,
  });

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

void _showNotifications(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF262626),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(
        tr('Notifications'),
        style: const TextStyle(
          color: EZColors.textBright,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: ListenableBuilder(
          listenable: Listenable.merge([
            Downloads.instance,
            Installer.instance,
          ]),
          builder: (ctx, _) {
            final rows = <Widget>[
              for (final j in Downloads.instance.jobs.where(
                (d) => d.chained == null,
              ))
                _notifRow(
                  Icons.cloud_download,
                  j.state == 'failed' ? EZColors.bad : EZColors.accent,
                  j.title,
                  j.error ?? j.state,
                ),
              for (final j in Installer.instance.jobs)
                _notifRow(
                  Icons.download,
                  j.state == JobState.failed
                      ? EZColors.bad
                      : j.state == JobState.done
                      ? EZColors.ok
                      : EZColors.accent,
                  j.displayName,
                  j.error ?? j.stage,
                ),
            ];
            if (rows.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(tr('No notifications'), style: EZText.hint),
                ),
              );
            }
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(child: Column(children: rows)),
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

Widget _notifRow(IconData icon, Color color, String title, String sub) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: EZColors.textBright,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(sub, style: EZText.hint, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    ),
  );
}
