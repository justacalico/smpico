import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/devices.dart';
import '../core/remote_files.dart';
import '../i18n.dart';
import '../theme.dart';
import '../widgets/common.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  final Set<String> _selected = {};
  bool _dragging = false;
  String _filter = '';
  bool _heaviest = false;
  List<RemoteEntry> _heavy = [];

  @override
  void initState() {
    super.initState();
    RemoteFiles.instance.addListener(_r);
    Transfers.instance.addListener(_r);
    Devices.instance.addListener(_r);
    if (Devices.instance.connected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        RemoteFiles.instance.open('/sdcard');
      });
    }
  }

  void _r() => setState(() {});
  @override
  void dispose() {
    RemoteFiles.instance.removeListener(_r);
    Transfers.instance.removeListener(_r);
    Devices.instance.removeListener(_r);
    super.dispose();
  }

  Future<void> _scanHeaviest() async {
    setState(() => _heaviest = true);
    _heavy = await RemoteFiles.instance.heaviest('/sdcard');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fm = RemoteFiles.instance;
    final connected = Devices.instance.connected;
    final shown = _heaviest
        ? _heavy
        : fm.entries
              .where(
                (e) =>
                    _filter.isEmpty ||
                    e.name.toLowerCase().contains(_filter.toLowerCase()),
              )
              .toList();

    return Container(
      color: EZColors.page,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // toolbar
          Row(
            children: [
              EZIconButton(
                Icons.arrow_back,
                tooltip: t.backAlt,
                onPressed: fm.historyPos > 0 ? () => fm.back() : null,
              ),
              EZIconButton(
                Icons.arrow_forward,
                tooltip: t.forwardAlt,
                onPressed: fm.historyPos < fm.history.length - 1
                    ? () => fm.forward()
                    : null,
              ),
              EZIconButton(
                Icons.arrow_upward,
                tooltip: t.upOneLevelBackspace,
                onPressed: fm.currentPath != '/' ? () => fm.up() : null,
              ),
              EZIconButton(
                Icons.refresh,
                tooltip: t.refreshF5,
                onPressed: () => fm.refresh(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _editPath(fm),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: EZColors.consoleBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2C2C2C)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _heaviest ? t.heaviestFiles : fm.currentPath,
                      style: EZText.console.copyWith(
                        color: const Color(0xFFE6E6E6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              EZButton(
                t.heaviestFiles,
                height: 32,
                fontSize: 11,
                onPressed: connected ? _scanHeaviest : null,
              ),
              const SizedBox(width: 6),
              EZIconButton(
                Icons.create_new_folder,
                tooltip: t.createAFolderCtrlShiftN,
                onPressed: connected ? () => _newFolder(fm) : null,
              ),
              EZIconButton(
                Icons.upload_file,
                tooltip: t.uploadFiles,
                onPressed: connected ? _uploadFiles : null,
              ),
              EZIconButton(
                Icons.drive_folder_upload,
                tooltip: t.uploadFolder,
                onPressed: connected ? _uploadFolder : null,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // quick access + filter row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...RemoteFiles.quickPaths.map(
                (qp) => _QuickPath(qp, fm.currentPath == qp, () => fm.open(qp)),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 140, maxWidth: 220),
                child: TextField(
                  style: const TextStyle(
                    fontSize: 12,
                    color: EZColors.textBright,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: t.filterEnterDeepSearch,
                    hintStyle: EZText.hint,
                    filled: true,
                    fillColor: EZColors.consoleBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 7,
                    ),
                  ),
                  onChanged: (v) => setState(() => _filter = v),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Checkbox(
                    value: fm.showHidden,
                    onChanged: (v) {
                      fm.showHidden = v ?? false;
                      fm.refresh();
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(t.hiddenFiles, style: EZText.hint),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // file list
          Expanded(
            child: DropTarget(
              onDragEntered: (_) => setState(() => _dragging = true),
              onDragExited: (_) => setState(() => _dragging = false),
              onDragDone: (d) {
                setState(() => _dragging = false);
                if (connected) {
                  Transfers.instance.upload(
                    d.files.map((f) => f.path).toList(),
                    fm.currentPath,
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: EZColors.consoleBg,
                  border: Border.all(
                    color: _dragging
                        ? EZColors.accent
                        : const Color(0xFF2C2C2C),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: !connected
                    ? EmptyPlug(Icons.usb_off, t.noDeviceConnected)
                    : fm.loading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: EZColors.accent,
                        ),
                      )
                    : fm.error != null
                    ? EmptyPlug(Icons.error_outline, fm.error!)
                    : shown.isEmpty
                    ? EmptyPlug(
                        Icons.folder_open,
                        t.folderIsEmpty,
                        subtitle: t.dragFilesHereFromThePCTo,
                      )
                    : Column(
                        children: [
                          _headerRow(),
                          const HSeparator(),
                          Expanded(
                            child: ListView.builder(
                              itemCount: shown.length,
                              itemBuilder: (_, i) => _fileRow(shown[i], fm),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // status + transfers
          Row(
            children: [
              Text(
                _heaviest
                    ? t.heaviestFilesTotalScannedAt(
                        arg1: _heavy.length,
                        arg2: '',
                        arg3: '',
                      )
                    : t.foldersFiles(
                        arg1: shown.where((e) => e.isDir).length,
                        arg2: shown.where((e) => !e.isDir).length,
                      ),
                style: EZText.hint,
              ),
              const Spacer(),
              if (_selected.isNotEmpty) ...[
                Text(t.selected(arg1: _selected.length), style: EZText.hint),
                const SizedBox(width: 8),
                EZButton(
                  t.download,
                  height: 28,
                  fontSize: 11,
                  onPressed: _downloadSelected,
                ),
                const SizedBox(width: 4),
                EZButton(
                  t.delete,
                  height: 28,
                  fontSize: 11,
                  color: EZColors.bad,
                  textColor: Colors.white,
                  onPressed: _deleteSelected,
                ),
              ],
              if (Transfers.instance.items.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '${Transfers.instance.items.where((t) => !t.done).length} ${t.active}',
                  style: EZText.hint,
                ),
                EZIconButton(
                  Icons.clear_all,
                  tooltip: t.clearFinished,
                  size: 24,
                  onPressed: () => Transfers.instance.clearFinished(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 28),
          Expanded(flex: 4, child: Text(t.name, style: EZText.group)),
          Expanded(child: Text(t.size, style: EZText.group)),
          Expanded(child: Text(t.modified, style: EZText.group)),
          const SizedBox(width: 100),
        ],
      ),
    );
  }

  Widget _fileRow(RemoteEntry e, RemoteFiles fm) {
    final sel = _selected.contains(e.path);
    return InkWell(
      onTap: () {
        if (e.isDir) {
          setState(() => _selected.clear());
          _heaviest = false;
          fm.open(e.path);
        } else {
          setState(() {
            sel ? _selected.remove(e.path) : _selected.add(e.path);
          });
        }
      },
      onLongPress: () => _fileMenu(e, fm),
      child: Container(
        color: sel ? const Color(0xFF2F3A1C) : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Row(
          children: [
            Icon(
              e.isDir ? Icons.folder : Icons.insert_drive_file,
              size: 16,
              color: e.isDir ? EZColors.accent : EZColors.textDim,
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: Text(
                e.name,
                style: TextStyle(
                  color: sel ? const Color(0xFFB5E651) : EZColors.textBright,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(e.isDir ? '' : fmtBytes(e.size), style: EZText.hint),
            ),
            Expanded(child: Text(e.modified, style: EZText.hint)),
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  EZIconButton(
                    Icons.save_alt,
                    tooltip: t.downloadToPC,
                    size: 24,
                    onPressed: () => _download([e]),
                  ),
                  if (!e.isDir)
                    EZIconButton(
                      Icons.calculate,
                      tooltip: t.calculateSize,
                      size: 24,
                      onPressed: null,
                    ),
                  EZIconButton(
                    Icons.delete_outline,
                    tooltip: t.delete,
                    size: 24,
                    onPressed: () => _delete([e]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fileMenu(RemoteEntry e, RemoteFiles fm) async {
    final ctrl = TextEditingController(text: e.name);
    final act = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 200, 0, 0),
      color: EZColors.card,
      items: [
        PopupMenuItem(value: 'rename', child: Text(t.rename)),
        PopupMenuItem(value: 'delete', child: Text(t.delete)),
        PopupMenuItem(value: 'copypath', child: Text(t.copyPath)),
      ],
    );
    if (!mounted) return;
    if (act == 'rename') {
      final name = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: EZColors.panel,
          title: Text(t.rename, style: EZText.section),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            EZButton(t.cancel, onPressed: () => Navigator.pop(context)),
            EZButton(
              t.save,
              onPressed: () => Navigator.pop(context, ctrl.text),
            ),
          ],
        ),
      );
      if (name != null && name.isNotEmpty) {
        try {
          await fm.rename(e, name);
        } catch (err) {
          if (mounted) toast(context, '$err');
        }
      }
    } else if (act == 'delete') {
      _delete([e]);
    } else if (act == 'copypath') {
      Clipboard.setData(ClipboardData(text: e.path));
    }
  }

  Future<void> _editPath(RemoteFiles fm) async {
    final ctrl = TextEditingController(text: fm.currentPath);
    final v = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: EZColors.panel,
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: EZText.console,
          decoration: InputDecoration(hintText: t.clickToTypeAPathCtrlL),
        ),
        actions: [
          EZButton(t.cancel, onPressed: () => Navigator.pop(context)),
          EZButton(t.open, onPressed: () => Navigator.pop(context, ctrl.text)),
        ],
      ),
    );
    if (v != null && v.isNotEmpty) {
      setState(() => _heaviest = false);
      fm.open(v);
    }
  }

  Future<void> _newFolder(RemoteFiles fm) async {
    final ctrl = TextEditingController();
    final v = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: EZColors.panel,
        title: Text(t.newFolder, style: EZText.section),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          EZButton(t.cancel, onPressed: () => Navigator.pop(context)),
          EZButton(
            t.create,
            onPressed: () => Navigator.pop(context, ctrl.text),
          ),
        ],
      ),
    );
    if (v != null && v.isNotEmpty) {
      try {
        await fm.mkdir(v);
      } catch (e) {
        if (mounted) toast(context, '$e');
      }
    }
  }

  Future<void> _uploadFiles() async {
    final files = await openFiles();
    if (files.isNotEmpty) {
      Transfers.instance.upload(
        files.map((f) => f.path).toList(),
        RemoteFiles.instance.currentPath,
      );
    }
  }

  Future<void> _uploadFolder() async {
    final dir = await getDirectoryPath();
    if (dir != null) {
      Transfers.instance.upload([dir], RemoteFiles.instance.currentPath);
    }
  }

  Future<void> _download(List<RemoteEntry> items) async {
    final dir = await getDirectoryPath();
    if (dir != null) {
      Transfers.instance.download(items, Directory(dir));
    }
  }

  void _downloadSelected() {
    final fm = RemoteFiles.instance;
    _download(fm.entries.where((e) => _selected.contains(e.path)).toList());
  }

  Future<void> _delete(List<RemoteEntry> items) async {
    final fm = RemoteFiles.instance;
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: EZColors.panel,
        title: Text(t.deleteFiles, style: EZText.section),
        content: Text(
          t.deleteItemsFromTheHeadset(arg1: items.length),
          style: EZText.label,
        ),
        actions: [
          EZButton(t.cancel, onPressed: () => Navigator.pop(context, false)),
          EZButton(
            t.delete,
            color: EZColors.bad,
            textColor: Colors.white,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (yes == true) {
      await fm.delete(items);
      setState(() => _selected.clear());
    }
  }

  void _deleteSelected() {
    final fm = RemoteFiles.instance;
    _delete(fm.entries.where((e) => _selected.contains(e.path)).toList());
  }
}

class _QuickPath extends StatelessWidget {
  final String path;
  final bool active;
  final VoidCallback onTap;
  const _QuickPath(this.path, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    final name = path == '/' ? t.root : path.split('/').last;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2F3A1C) : EZColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? EZColors.accent : EZColors.cardBorder,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: active ? const Color(0xFFB5E651) : EZColors.textDim,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
