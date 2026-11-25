import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../i18n.dart';
import '../theme.dart';
import 'common.dart';

/// First-launch welcome dialog — shows the bundled welcome doc and
/// an "Accept" button that stores the first-launch mark.
class WelcomeDialog extends StatefulWidget {
  const WelcomeDialog({super.key});

  @override
  State<WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> {
  String _text = '';

  @override
  void initState() {
    super.initState();
    _load();
    I18n.instance.addListener(_load);
  }

  Future<void> _load() async {
    final lang = I18n.instance.lang == AppLang.ru ? 'ru' : 'en';
    final t = await rootBundle.loadString('assets/docs/welcome_$lang.md');
    if (mounted) setState(() => _text = t);
  }

  @override
  void dispose() {
    I18n.instance.removeListener(_load);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: EZColors.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9 > 560
              ? 560
              : MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.85 > 560
              ? 560
              : MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.headset, size: 22, color: EZColors.accent),
                  const SizedBox(width: 10),
                  Text(
                    tr('Welcome to SMPico'),
                    style: const TextStyle(
                      color: EZColors.textBright,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Markdown(
                  data: _text,
                  styleSheet: mdStyle,
                  onTapLink: (_, href, __) {
                    if (href != null) openExternalUrl(context, href);
                  },
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Spacer(),
                  EZButton(
                    tr('Accept'),
                    color: EZColors.accent,
                    textColor: const Color(0xFF111111),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
