import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import '../core/installer.dart';
import '../i18n.dart';
import '../theme.dart';
import 'common.dart';

/// Install options dialog: method (direct/overport/repack), package
/// suffix, signing key, SDK metadata, store installer, cache folder,
/// download-only toggle — mirrors InstallOptionsDialog.
Future<InstallOptions?> showInstallOptionsDialog(
    BuildContext context, InstallOptions opts) {
  return showDialog<InstallOptions>(
    context: context,
    builder: (_) => _InstallOptionsDialog(opts),
  );
}

class _InstallOptionsDialog extends StatefulWidget {
  final InstallOptions opts;
  const _InstallOptionsDialog(this.opts);

  @override
  State<_InstallOptionsDialog> createState() => _InstallOptionsDialogState();
}

class _InstallOptionsDialogState extends State<_InstallOptionsDialog> {
  late InstallOptions o = widget.opts;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: EZColors.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tr('Install settings'), style: EZText.section),
                const SizedBox(height: 4),
                Text(tr('Install settings for this game'), style: EZText.hint),
                const SizedBox(height: 14),
                Text(tr('Install method').toUpperCase(), style: EZText.group),
                const SizedBox(height: 8),
                _methodRow(InstallMethod.auto, tr('Auto'),
                    tr('Picked from the package and the headset')),
                _methodRow(InstallMethod.direct, tr('Direct'),
                    tr('The APK is installed as is')),
                _methodRow(InstallMethod.overport, tr('Overport'),
                    tr('Re-signed with a new key, no repack')),
                _methodRow(InstallMethod.repack, tr('Repack'),
                    tr('Decompiled, patched and built again')),
                const SizedBox(height: 14),
                _field(tr('Package suffix'), tr('Installs next to the original app'),
                    o.packageSuffix, (v) => o.packageSuffix = v),
                const SizedBox(height: 8),
                _check(tr('New signing key'), tr('A fresh key for every install'),
                    o.newKey, (v) => setState(() => o.newKey = v)),
                _check(tr('Keep SDK metadata'),
                    tr('Leave pvr.sdk.version and similar in the manifest'),
                    o.keepSdkMeta, (v) => setState(() => o.keepSdkMeta = v)),
                _check(tr('Store installer'),
                    tr('Pass -i com.picovr.store to pm install'),
                    o.storeInstaller, (v) => setState(() => o.storeInstaller = v)),
                const SizedBox(height: 14),
                Text(tr('Game cache (OBB)').toUpperCase(), style: EZText.group),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        o.cacheFolder ?? tr('Folder next to the APK (automatically)'),
                        style: EZText.hint,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    EZButton(tr('Choose folder'),
                        height: 28,
                        fontSize: 11,
                        onPressed: () async {
                      final d = await getDirectoryPath(
                          confirmButtonText: tr('Choose the game cache folder'));
                      if (d != null) setState(() => o.cacheFolder = d);
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                _check(tr('download only'),
                    tr('Off — only download, install later with the «Install» button'),
                    o.downloadOnly, (v) => setState(() => o.downloadOnly = v)),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    EZButton(tr('Cancel'),
                        onPressed: () => Navigator.pop(context)),
                    const SizedBox(width: 8),
                    EZButton(tr('Apply'),
                        color: EZColors.accent,
                        textColor: const Color(0xFF111111),
                        onPressed: () => Navigator.pop(context, o)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _methodRow(InstallMethod m, String title, String hint) {
    final sel = o.method == m;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => o.method = m),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFF2B2B2B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: sel ? EZColors.accent : const Color(0xFF2C2C2C)),
          ),
          child: Row(
            children: [
              Icon(sel ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 16,
                  color: sel ? EZColors.accent : EZColors.textDim),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Color(0xFFE4E4E4),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    Text(hint, style: EZText.hint),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, String hint, String value,
      ValueChanged<String> onChanged) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFFE4E4E4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              Text(hint, style: EZText.hint),
            ],
          ),
        ),
        Expanded(
          child: TextFormField(
            initialValue: value,
            style: const TextStyle(color: EZColors.textBright, fontSize: 12),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: EZColors.consoleBg,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2C2C2C))),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _check(String label, String hint, bool value,
      ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            _EZCheckbox(value: value, onChanged: onChanged),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Color(0xFFE4E4E4),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  Text(hint, style: EZText.hint),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// QCheckBox styled per global.qss: 18px, rounded 5, #677ea1 checked.
class _EZCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _EZCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: value ? const Color(0xFF677EA1) : const Color(0xFF1D1D1D),
          border: Border.all(
              color: value ? const Color(0xFF677EA1) : const Color(0xFF3C3C3C)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: value
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}
