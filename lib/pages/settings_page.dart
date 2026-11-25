import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/catalog.dart';
import '../core/packages.dart';
import '../core/paths.dart';
import '../core/updater.dart';
import '../i18n.dart';
import '../settings.dart';
import '../theme.dart';
import '../widgets/common.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _guide = '';
  bool _showGuide = false;

  @override
  void initState() {
    super.initState();
    _loadGuide();
    I18n.instance.addListener(_loadGuide);
  }

  Future<void> _loadGuide() async {
    final lang = I18n.instance.lang == AppLang.ru ? 'ru' : 'en';
    final t = await rootBundle.loadString('assets/docs/guide_$lang.md');
    if (mounted) setState(() => _guide = t);
  }

  @override
  void dispose() {
    I18n.instance.removeListener(_loadGuide);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: EZColors.page,
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          if (_showGuide) _guidePanel(),
          _section(tr('Interface')),
          _row(
            tr('Language'),
            tr('Interface language, applied instantly'),
            _langPicker(),
          ),
          _row(
            tr('Accent color'),
            tr(
              'Buttons, highlights and selection. Battery and status indicators keep their colors',
            ),
            _accentPicker(),
          ),
          _switch(
            tr('Keep the headset awake'),
            tr(
              'The headset does not fall asleep while SMPico is running (installs, file transfers, stream). Normal sleep returns when SMPico is closed',
            ),
            'keep_awake',
            true,
          ),
          _switch(
            tr('Windows notifications'),
            tr(
              'Show pop-up notifications about installs, backups and screenshots',
            ),
            'notifications',
            true,
          ),
          _section(tr('Files')),
          _row(
            tr('Downloads folder'),
            tr(
              'Archives and unpacked folders downloaded by SMPico. Only its own folders are removed',
            ),
            EZButton(
              tr('Open folder'),
              height: 30,
              onPressed: () async {
                final d = await AppPaths.downloads();
                launchUrl(Uri.file(d.path));
              },
            ),
          ),
          _row(
            tr('App icons cache'),
            tr('Names and icons of headset apps. Clear it if icons look wrong'),
            EZButton(
              tr('Clear'),
              height: 30,
              onPressed: () => Packages.instance.clearIconCache(),
            ),
          ),
          _row(
            tr('Tools folder'),
            '',
            EZButton(
              tr('Open folder'),
              height: 30,
              onPressed: () async {
                final d = await AppPaths.tools();
                launchUrl(Uri.file(d.path));
              },
            ),
          ),
          _section(tr('PicoLand catalog')),
          _row(
            tr('Catalog address'),
            tr(
              'Folder with manifest.json, catalog.db and images/. Empty — the built-in address',
            ),
            _catalogAddress(),
          ),
          _row(
            tr('Catalog version'),
            Catalog.instance.version.isEmpty
                ? tr('Version is unknown')
                : Catalog.instance.version,
            EZButton(
              tr('Check now'),
              height: 30,
              onPressed: () => Catalog.instance.checkUpdates(),
            ),
          ),
          _row(
            tr('Downloaded games'),
            tr(
              'Delete downloaded archives and unpacked game folders? Games that are downloading or installing right now are kept.',
            ),
            EZButton(tr('Clear'), height: 30, onPressed: _clearDownloads),
          ),
          _section(tr('Updates')),
          _switch(
            tr('Check for updates on startup'),
            tr('New versions are downloaded and installed without the setup'),
            'check_updates',
            true,
          ),
          _row(
            tr('Version'),
            Updater.appVersion,
            EZButton(
              tr('Check now'),
              height: 30,
              onPressed: () async {
                await Updater.instance.check();
                if (!mounted) return;
                final u = Updater.instance;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      u.available != null
                          ? tr('SMPico {} is available', [u.available!.version])
                          : u.error != null
                          ? u.error!
                          : tr('You have the latest version'),
                    ),
                  ),
                );
              },
            ),
          ),
          _section(tr('Help and reset')),
          _row(
            tr('Guide'),
            tr(
              'How to connect the headset and what every tab, button and option does',
            ),
            EZButton(
              tr('Open guide'),
              icon: Icons.book,
              height: 30,
              onPressed: () => setState(() => _showGuide = !_showGuide),
            ),
          ),
          _row(
            tr('Welcome screen'),
            tr(
              'Which internet resources SMPico uses and what it stores on this PC',
            ),
            EZButton(
              tr('Show'),
              height: 30,
              onPressed: () => Settings.instance
                  .set('welcome_accepted', false)
                  .then(
                    (_) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr('Welcome to SMPico'))),
                    ),
                  ),
            ),
          ),
          _row(
            tr('Reset all settings'),
            tr(
              'Language, color, toggles, folders, saved commands — everything returns to defaults and SMPico restarts. Games, saves and screenshots are not touched',
            ),
            EZButton(
              tr('Reset'),
              color: EZColors.bad,
              textColor: Colors.white,
              height: 30,
              onPressed: _resetAll,
            ),
          ),
          _section(tr('Developer')),
          _row(
            tr('Report'),
            tr(
              'Saves everything about this session: headset info, installed packages, install history and logs. No passwords or personal data are included',
            ),
            EZButton(tr('Create report'), height: 30, onPressed: _report),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _guidePanel() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 320,
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Markdown(
        data: _guide,
        styleSheet: mdStyle,
        onTapLink: (_, href, __) {
          if (href != null) launchUrl(Uri.parse(href));
        },
      ),
    );
  }

  Widget _section(String t) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Text(t.toUpperCase(), style: EZText.group),
  );

  Widget _row(String label, String hint, Widget trailing) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: cardDecoration(),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hint.isNotEmpty) Text(hint, style: EZText.hint),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _switch(String label, String hint, String key, bool def) {
    final v = Settings.instance.get(key, def);
    return _row(
      label,
      hint,
      Switch(
        value: v,
        activeColor: EZColors.accent,
        onChanged: (nv) {
          Settings.instance.set(key, nv);
          setState(() {});
        },
      ),
    );
  }

  Widget _langPicker() {
    return SegmentedButton<AppLang>(
      segments: [
        ButtonSegment(value: AppLang.en, label: Text(tr('EN'))),
        ButtonSegment(value: AppLang.ru, label: Text(tr('RU'))),
      ],
      selected: {I18n.instance.lang},
      onSelectionChanged: (s) {
        I18n.instance.setLang(s.first);
        Settings.instance.set('language', s.first == AppLang.ru ? 'ru' : 'en');
        setState(() {});
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected)
              ? const Color(0xFF333333)
              : const Color(0xFF242424),
        ),
        foregroundColor: WidgetStateProperty.all(EZColors.text),
      ),
    );
  }

  Widget _accentPicker() {
    final cur = Settings.instance.get('accent', 'Green');
    return DropdownButton<String>(
      value: EZColors.accentChoices.containsKey(cur) ? cur : 'Green',
      dropdownColor: const Color(0xFF242424),
      underline: const SizedBox(),
      style: const TextStyle(fontSize: 12),
      items: EZColors.accentChoices.keys
          .map(
            (k) => DropdownMenuItem(
              value: k,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: EZColors.accentChoices[k],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(tr(k)),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (v) {
        Settings.instance.set('accent', v);
        setState(() {});
      },
    );
  }

  Widget _catalogAddress() {
    final cur = Settings.instance.get('catalog_address', '');
    return SizedBox(
      width: 240,
      child: TextFormField(
        initialValue: cur,
        style: const TextStyle(fontSize: 12, color: EZColors.textBright),
        decoration: InputDecoration(
          isDense: true,
          hintText: Catalog.repoBase,
          hintStyle: EZText.hint,
          filled: true,
          fillColor: EZColors.consoleBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
        ),
        onChanged: (v) => Settings.instance.set('catalog_address', v),
      ),
    );
  }

  Future<void> _clearDownloads() async {
    final d = await AppPaths.downloads();
    var freed = 0;
    var count = 0;
    if (await d.exists()) {
      await for (final e in d.list()) {
        try {
          if (e is File) freed += await e.length();
          await e.delete(recursive: true);
          count++;
        } catch (_) {}
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Freed {} ({} folders)', [_fmtBytes(freed), count])),
        ),
      );
    }
  }

  Future<void> _resetAll() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: EZColors.panel,
        title: Text(tr('Reset all settings'), style: EZText.section),
        content: Text(
          tr(
            'All SMPico settings will return to defaults, the welcome screen will be shown again and the program will restart. Continue?',
          ),
          style: EZText.label,
        ),
        actions: [
          EZButton(
            tr('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          EZButton(
            tr('Reset'),
            color: EZColors.bad,
            textColor: Colors.white,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (yes == true) {
      await Settings.instance.resetAll();
      if (mounted) setState(() {});
    }
  }

  Future<void> _report() async {
    final f = await Packages.instance.createReport();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('Report saved: {}', [f.path]))));
    }
  }

  String _fmtBytes(int b) {
    const u = ['B', 'KB', 'MB', 'GB'];
    var v = b.toDouble();
    var i = 0;
    while (v >= 1024 && i < u.length - 1) {
      v /= 1024;
      i++;
    }
    return '${v.toStringAsFixed(1)} ${u[i]}';
  }
}
