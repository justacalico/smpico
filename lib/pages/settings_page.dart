import 'dart:io';

import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Container(
      color: EZColors.page,
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          _section(t.interface),
          _row(t.language, t.interfaceLanguageAppliedInstantly, _langPicker()),
          _row(
            t.accentColour,
            t.buttonsHighlightsAndSelectionBatteryAndStatus,
            _accentPicker(),
          ),
          _switch(
            t.keepTheHeadsetAwake,
            t.theHeadsetDoesNotFallAsleepWhile,
            'keep_awake',
            true,
          ),
          _switch(
            t.windowsNotifications,
            t.showPopUpNotificationsAboutInstallsBackups,
            'notifications',
            true,
          ),
          _section(t.files),
          _row(
            t.downloadsFolder,
            t.archivesAndUnpackedFoldersDownloadedBySMPico,
            EZButton(
              t.openFolder,
              height: 30,
              onPressed: () async {
                final d = await AppPaths.downloads();
                if (context.mounted) {
                  openExternalUrl(context, Uri.file(d.path).toString());
                }
              },
            ),
          ),
          _row(
            t.appIconsCache,
            t.namesAndIconsOfHeadsetAppsClear,
            EZButton(
              t.clear,
              height: 30,
              onPressed: () => Packages.instance.clearIconCache(),
            ),
          ),
          _row(
            t.toolsFolder,
            '',
            EZButton(
              t.openFolder,
              height: 30,
              onPressed: () async {
                final d = await AppPaths.tools();
                if (context.mounted) {
                  openExternalUrl(context, Uri.file(d.path).toString());
                }
              },
            ),
          ),
          _section(t.picolandCatalog),
          _switch(
            t.showGamesWithoutDownloadLinks,
            t.offByDefaultMostEntriesCanOnly,
            'catalog_show_undownloadable',
            false,
          ),
          _row(
            t.catalogAddress,
            t.folderWithManifestJsonCatalogDbAnd,
            _catalogAddress(),
          ),
          _row(
            t.catalogVersion,
            Catalog.instance.version.isEmpty
                ? t.versionIsUnknown
                : Catalog.instance.version,
            EZButton(
              t.checkNow,
              height: 30,
              onPressed: () => Catalog.instance.checkUpdates(),
            ),
          ),
          _row(
            t.downloadedGames,
            t.deleteDownloadedArchivesAndUnpackedGameFolders,
            EZButton(t.clear, height: 30, onPressed: _clearDownloads),
          ),
          _section(t.updates),
          _switch(
            t.checkForUpdatesOnStartup,
            t.newVersionsAreDownloadedAndInstalledWithout,
            'check_updates',
            true,
          ),
          _row(
            t.version,
            Updater.appVersion,
            EZButton(
              t.checkNow,
              height: 30,
              onPressed: () async {
                await Updater.instance.check();
                if (!mounted) return;
                final u = Updater.instance;
                toast(
                  context,
                  u.available != null
                      ? t.smpicoIsAvailable(arg1: u.available!.version)
                      : u.error != null
                      ? u.error!
                      : t.youHaveTheLatestVersion,
                );
              },
            ),
          ),
          _section(t.helpAndReset),
          _row(
            t.resetAllSettings,
            t.languageColourTogglesFoldersSavedCommandsEverything,
            EZButton(
              t.reset,
              color: EZColors.bad,
              textColor: Colors.white,
              height: 30,
              onPressed: _resetAll,
            ),
          ),
          _section(t.developer),
          _row(
            t.report,
            t.savesEverythingAboutThisSessionHeadsetInfo,
            EZButton(t.createReport, height: 30, onPressed: _report),
          ),
          const SizedBox(height: 24),
        ],
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
    return DropdownButton<String>(
      value: Settings.instance.get('language', 'system'),
      dropdownColor: const Color(0xFF242424),
      underline: const SizedBox(),
      style: const TextStyle(fontSize: 12, color: EZColors.text),
      items: [
        DropdownMenuItem(value: 'system', child: Text(t.systemLanguage)),
        const DropdownMenuItem(value: 'en', child: Text('English')),
        const DropdownMenuItem(value: 'ru', child: Text('Русский')),
        const DropdownMenuItem(value: 'zh-CN', child: Text('简体中文')),
      ],
      onChanged: (v) {
        if (v == null) return;
        I18n.instance.applySaved(v);
        Settings.instance.set('language', v);
        setState(() {});
      },
    );
  }

  String _colorName(String k) => switch (k) {
    'Green' => t.green,
    'Blue' => t.blue,
    'Purple' => t.purple,
    'Pink' => t.pink,
    'Orange' => t.orange,
    'Teal' => t.teal,
    'Yellow' => t.yellow,
    'Red' => t.red,
    _ => k,
  };

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
                  Text(_colorName(k)),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        EZColors.applyAccent(v);
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
      toast(context, t.freedFolders(arg1: _fmtBytes(freed), arg2: count));
    }
  }

  Future<void> _resetAll() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: EZColors.panel,
        title: Text(t.resetAllSettings, style: EZText.section),
        content: Text(
          t.allSMPicoSettingsWillReturnToDefaults,
          style: EZText.label,
        ),
        actions: [
          EZButton(t.cancel, onPressed: () => Navigator.pop(context, false)),
          EZButton(
            t.reset,
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
      toast(context, t.reportSaved(arg1: f.path));
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
