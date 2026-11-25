import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../i18n.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Community tab — links to the PicoLand channel and the developer.
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: EZColors.page,
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icons/community.png',
                height: 110,
                errorBuilder: (_, __, ___) => const Icon(Icons.forum,
                    size: 72, color: EZColors.textDim)),
            const SizedBox(height: 16),
            Text(tr('Community'), style: EZText.section),
            const SizedBox(height: 20),
            _link('PicoLAND', 'https://t.me/picoIand',
                Icons.videogame_asset),
            _link('EZPico — Telegram', 'https://t.me/EZPico',
                Icons.telegram),
            _link('@Cka3kaTG', 'https://t.me/Cka3kaTG',
                Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _link(String label, String url, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: 280,
        child: EZButton(label,
            icon: icon,
            onPressed: () => launchUrl(Uri.parse(url))),
      ),
    );
  }
}
