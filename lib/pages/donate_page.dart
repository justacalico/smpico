import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../i18n.dart';
import '../theme.dart';

/// Support tab — donation options mirroring the original.
class DonatePage extends StatelessWidget {
  const DonatePage({super.key});

  static const _wallets = <String, String>{
    'USDT (TRC20)': 'TSVZtERQNnvQhLqHnNT4zdtWWFfYB1F4qz',
    'TON': 'UQBktJj1eFy2NeDkvx3jTb5WKj8RKU12dKSFRhFZAK9DXmBX',
    'BTC': '14Lhgo7rhMYrF9Xr3UmVfQyqiugTztGfnM',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: EZColors.page,
      padding: const EdgeInsets.all(12),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('assets/icons/donate.png',
                  height: 110,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.favorite,
                      size: 72,
                      color: EZColors.textDim)),
              const SizedBox(height: 14),
              Text(tr('Support'), style: EZText.section),
              const SizedBox(height: 6),
              Text(tr('These details exist for those who want to say thanks.'),
                  style: EZText.hint, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              _card(
                tr('Boosty'),
                'boosty.to/cka3ka',
                onTap: () =>
                    launchUrl(Uri.parse('https://boosty.to/cka3ka')),
              ),
              _card('CloudTips', 'pay.cloudtips.ru',
                  onTap: () => launchUrl(
                      Uri.parse('https://pay.cloudtips.ru/p/1e4d83e5'))),
              ..._wallets.entries.map((e) => _wallet(e.key, e.value)),
              const SizedBox(height: 16),
              Text(tr('PicoLand remains free — the stickers, the role and the warm feeling are simply a thank-you.'),
                  style: EZText.hint, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String title, String sub, {VoidCallback? onTap}) {
    return Container(
      width: 340,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: cardDecoration(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: EZColors.textBright,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Text(sub, style: EZText.hint),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new,
                  size: 16, color: EZColors.textDim),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wallet(String name, String addr) {
    return Builder(
      builder: (ctx) => Container(
        width: 340,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: cardDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: EZColors.textBright,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Text(addr,
                      style: const TextStyle(
                          color: EZColors.textDim, fontSize: 10),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy,
                  size: 16, color: EZColors.textDim),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: addr));
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(tr('Copied'))));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
