import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../core/devices.dart';
import '../core/packages.dart';
import '../i18n.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AppManagerPage extends StatefulWidget {
  const AppManagerPage({super.key});

  @override
  State<AppManagerPage> createState() => _AppManagerPageState();
}

class _AppManagerPageState extends State<AppManagerPage> {
  String _query = '';
  bool _loaded = false;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    Packages.instance.addListener(_r);
    Devices.instance.addListener(_r);
    _maybeLoad();
  }

  void _r() {
    setState(() {});
    _maybeLoad();
  }

  void _maybeLoad() {
    if (!_loaded && Devices.instance.connected) {
      _loaded = true;
      Packages.instance.refresh();
    }
  }

  @override
  void dispose() {
    Packages.instance.removeListener(_r);
    Devices.instance.removeListener(_r);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pkgs = Packages.instance;
    final connected = Devices.instance.connected;
    final q = _query.toLowerCase();
    final list = pkgs.items
        .where(
          (e) =>
              q.isEmpty ||
              e.name.toLowerCase().contains(q) ||
              e.label.toLowerCase().contains(q),
        )
        .toList();

    return Container(
      color: EZColors.page,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: TextField(
                    controller: _search,
                    style: const TextStyle(
                      color: EZColors.textBright,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: tr('Search by name or package…'),
                      hintStyle: EZText.hint,
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 16,
                        color: EZColors.textDim,
                      ),
                      filled: true,
                      fillColor: EZColors.consoleBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              EZButton(
                tr('Refresh'),
                icon: Icons.refresh,
                height: 34,
                onPressed: connected ? () => pkgs.refresh() : null,
              ),
              const Spacer(),
              Text(tr('{} item(s)', [list.length]), style: EZText.hint),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: !connected
                ? EmptyPlug(
                    Icons.usb_off,
                    tr('No Device Connected'),
                    subtitle: tr(
                      'Connect your PICO VR headset\nand PC with a USB cable.',
                    ),
                  )
                : pkgs.loading && list.isEmpty
                ? Center(
                    child: Text(tr('Loading packages…'), style: EZText.hint),
                  )
                : pkgs.error != null
                ? EmptyPlug(
                    Icons.error_outline,
                    tr('Failed to load packages'),
                    subtitle: pkgs.error,
                  )
                : list.isEmpty
                ? EmptyPlug(
                    Icons.apps,
                    tr('Nothing installed yet'),
                    subtitle: tr(
                      'Apps installed through SMPico will appear here',
                    ),
                  )
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) => _PackageRow(list[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PackageRow extends StatefulWidget {
  final PackageEntry entry;
  const _PackageRow(this.entry);

  @override
  State<_PackageRow> createState() => _PackageRowState();
}

class _PackageRowState extends State<_PackageRow> {
  bool _busy = false;

  Future<void> _run(Future<String> Function() op, {String? okMsg}) async {
    setState(() => _busy = true);
    try {
      final msg = await op();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(okMsg ?? msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: cardDecoration(),
      child: ListTile(
        dense: true,
        leading: e.iconFile != null
            ? Image.file(
                e.iconFile!,
                width: 34,
                height: 34,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.android, color: EZColors.textDim),
              )
            : const Icon(Icons.android, size: 34, color: EZColors.textDim),
        title: Text(
          e.label.isNotEmpty ? e.label : e.name,
          style: EZText.title,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(e.name, style: EZText.hint),
        trailing: _busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EZIconButton(
                    Icons.play_arrow,
                    tooltip: tr('Launch'),
                    onPressed: () => _run(
                      () => Packages.instance.launch(e.name),
                      okMsg: tr('Launching…'),
                    ),
                  ),
                  EZIconButton(
                    Icons.save_alt,
                    tooltip: tr('Save APK to PC'),
                    onPressed: () async {
                      final dir = await getDirectoryPath(
                        confirmButtonText: tr('Save to folder'),
                      );
                      if (dir != null) {
                        _run(
                          () =>
                              Packages.instance.saveApk(e.name, Directory(dir)),
                        );
                      }
                    },
                  ),
                  EZIconButton(
                    Icons.backup,
                    tooltip: tr('Save game data'),
                    onPressed: () => _run(() async {
                      await Packages.instance.backupSaves(e.name);
                      return tr('Game data saved ({})', [e.name]);
                    }),
                  ),
                  EZIconButton(
                    Icons.lock_outline,
                    tooltip: tr('Permissions'),
                    onPressed: () => _showPerms(e),
                  ),
                  EZIconButton(
                    Icons.delete_outline,
                    tooltip: tr('Uninstall'),
                    onPressed: () => _confirmUninstall(e),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _showPerms(PackageEntry e) async {
    final perms = await Packages.instance.permissions(e.name);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: EZColors.panel,
        title: Text(tr('Permissions'), style: EZText.section),
        content: SizedBox(
          width: 420,
          height: 300,
          child: perms.isEmpty
              ? Text(
                  tr(
                    'The app does not request permissions that can be changed',
                  ),
                  style: EZText.hint,
                )
              : ListView(
                  children: perms
                      .map((p) => Text(p, style: EZText.console))
                      .toList(),
                ),
        ),
        actions: [
          EZButton(
            tr('Grant all'),
            onPressed: () {
              _run(() async {
                await Packages.instance.grantAll(e.name);
                return tr('Granted {} of {}', [perms.length, perms.length]);
              });
              Navigator.pop(context);
            },
          ),
          EZButton(tr('Close'), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Future<void> _confirmUninstall(PackageEntry e) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: EZColors.panel,
        title: Text(tr('Uninstall'), style: EZText.section),
        content: Text(
          tr(
            'Uninstall {}? Game data on the headset will be deleted. Save it first if you want to keep your progress.',
            [e.name],
          ),
          style: EZText.label,
        ),
        actions: [
          EZButton(
            tr('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          EZButton(
            tr('Uninstall'),
            color: EZColors.bad,
            textColor: Colors.white,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (yes == true) {
      _run(() => Packages.instance.uninstall(e.name), okMsg: tr('Uninstalled'));
    }
  }
}
