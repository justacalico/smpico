import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/catalog.dart';
import '../core/devices.dart';
import '../core/downloads.dart';
import '../core/installer.dart';
import '../i18n.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/install_options.dart';

class PicoLandPage extends StatefulWidget {
  const PicoLandPage({super.key});

  @override
  State<PicoLandPage> createState() => _PicoLandPageState();
}

class _PicoLandPageState extends State<PicoLandPage> {
  Game? _selected;
  String _query = '';
  final _kbFocus = FocusNode();
  final Set<String> _genres = {};
  String? _language;
  String? _type;
  int? _minSize;
  int? _maxSize;
  bool _downloadableOnly = false;
  String _sort = 'name'; // name | size

  @override
  void initState() {
    super.initState();
    Catalog.instance.addListener(_r);
  }

  void _r() => setState(() {});
  @override
  void dispose() {
    Catalog.instance.removeListener(_r);
    _kbFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _kbFocus,
      autofocus: true,
      onKeyEvent: (e) {
        if (e is KeyDownEvent &&
            e.logicalKey == LogicalKeyboardKey.escape &&
            _selected != null) {
          setState(() => _selected = null);
        }
      },
      child: Container(
        color: EZColors.page,
        child: _selected != null
            ? _GameDetails(
                game: _selected!,
                onBack: () => setState(() => _selected = null),
              )
            : _catalog(),
      ),
    );
  }

  Widget _catalog() {
    final cat = Catalog.instance;
    final games = cat.filter(
      query: _query,
      genreFilter: _genres,
      language: _language,
      type: _type,
      minSize: _minSize,
      maxSize: _maxSize,
      downloadableOnly: _downloadableOnly,
    );
    if (_sort == 'name') {
      games.sort((a, b) => a.title.compareTo(b.title));
    } else {
      games.sort((a, b) => b.bestSize.compareTo(a.bestSize));
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 240,
                  child: TextField(
                    style: const TextStyle(
                      color: EZColors.textBright,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: tr('Search games…'),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: 8),
                _filterMenu(
                  tr('Type'),
                  {null: tr('All'), 'ovrport': 'OVRport', 'fnal': 'FNAL'},
                  _type,
                  (v) => setState(() => _type = v),
                ),
                _filterMenu(
                  tr('Size'),
                  {
                    null: tr('All'),
                    's': tr('< 1 GB'),
                    'm': tr('1–5 GB'),
                    'l': tr('5+ GB'),
                  },
                  _sizeKey(),
                  _setSize,
                ),
                _filterMenu(
                  tr('Sort'),
                  {'name': tr('A–Z'), 'size': tr('Size')},
                  _sort,
                  (v) => setState(() => _sort = v ?? 'name'),
                ),
                FilterChip(
                  label: Text(
                    tr('Downloadable'),
                    style: const TextStyle(fontSize: 11),
                  ),
                  selected: _downloadableOnly,
                  onSelected: (v) => setState(() => _downloadableOnly = v),
                  backgroundColor: const Color(0xFF242424),
                  selectedColor: const Color(0xFF2F3A1C),
                  checkmarkColor: EZColors.accent,
                  side: const BorderSide(color: Color(0xFF2E2E2E)),
                ),
                const SizedBox(width: 8),
                _genreMenu(cat),
                const SizedBox(width: 12),
                if (cat.version.isNotEmpty)
                  Text(
                    tr('Catalog version {}', [cat.version]),
                    style: EZText.hint,
                    overflow: TextOverflow.ellipsis,
                  ),
                EZIconButton(
                  Icons.refresh,
                  tooltip: tr('Check for updates'),
                  onPressed: cat.loading ? null : () => cat.checkUpdates(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: cat.loading && games.isEmpty
                ? Center(
                    child: Text(tr('Loading the catalog…'), style: EZText.hint),
                  )
                : !cat.available
                ? EmptyPlug(
                    Icons.cloud_off,
                    tr('Catalog is unavailable'),
                    subtitle: cat.error,
                  )
                : games.isEmpty
                ? EmptyPlug(Icons.search_off, tr('Nothing matches the filter'))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 170,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: games.length,
                    itemBuilder: (_, i) => _GameCard(
                      game: games[i],
                      onTap: () {
                        setState(() => _selected = games[i]);
                        _kbFocus.requestFocus();
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _sizeKey() {
    if (_minSize == null && _maxSize == null) return '';
    if (_maxSize == 1 << 30) return 's';
    if (_minSize == 1 << 30) return 'l';
    return 'm';
  }

  void _setSize(String? v) {
    setState(() {
      _minSize = switch (v) {
        'm' => 1 << 30,
        'l' => 5 << 30,
        _ => null,
      };
      _maxSize = switch (v) {
        's' => 1 << 30,
        'm' => 5 << 30,
        _ => null,
      };
    });
  }

  Widget _filterMenu(
    String label,
    Map<String?, String> items,
    String? current,
    ValueChanged<String?> onSel,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: PopupMenuButton<String?>(
        tooltip: label,
        color: const Color(0xFF242424),
        onSelected: onSel,
        itemBuilder: (_) => items.entries
            .map(
              (e) => PopupMenuItem<String?>(
                value: e.key,
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 12,
                    color: e.key == current
                        ? EZColors.accent
                        : EZColors.textBright,
                  ),
                ),
              ),
            )
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF242424),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2E2E2E)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$label: ${items[current] ?? tr('All')}',
                style: const TextStyle(fontSize: 11, color: EZColors.text),
              ),
              const Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: EZColors.textDim,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genreMenu(Catalog cat) {
    return PopupMenuButton<String>(
      tooltip: tr('Find a category…'),
      color: const Color(0xFF242424),
      onSelected: (g) => setState(() {
        _genres.contains(g) ? _genres.remove(g) : _genres.add(g);
      }),
      itemBuilder: (_) => cat.genres
          .map(
            (g) => PopupMenuItem(
              value: g,
              child: Row(
                children: [
                  Icon(
                    _genres.contains(g)
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 16,
                    color: EZColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(g, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF242424),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _genres.isEmpty ? const Color(0xFF2E2E2E) : EZColors.accent,
          ),
        ),
        child: Text(
          _genres.isEmpty ? tr('All games') : '${_genres.length}',
          style: const TextStyle(fontSize: 11, color: EZColors.text),
        ),
      ),
    );
  }
}

class _GameCard extends StatefulWidget {
  final Game game;
  final VoidCallback onTap;
  const _GameCard({required this.game, required this.onTap});

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          decoration: BoxDecoration(
            color: EZColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _h ? EZColors.accent : EZColors.cardBorder,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (g.cover != null)
                      Image.network(
                        g.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: const Color(0xFF1A1A1A)),
                      )
                    else
                      Container(color: const Color(0xFF1A1A1A)),
                    if (g.ovrport)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xDD333333),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'OVRPORT',
                            style: TextStyle(
                              color: Color(0xFFD0D0D0),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.title,
                      style: const TextStyle(
                        color: EZColors.textBright,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      g.genres.take(2).join(' · '),
                      style: EZText.hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameDetails extends StatelessWidget {
  final Game game;
  final VoidCallback onBack;
  const _GameDetails({required this.game, required this.onBack});

  Color _linkColor(String status) => switch (status) {
    'ok' => EZColors.accent,
    'removed' || 'dead' || 'failed' => EZColors.bad,
    _ => EZColors.textDim,
  };

  @override
  Widget build(BuildContext context) {
    final g = game;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              EZButton(
                tr('← Back to catalog'),
                icon: Icons.arrow_back,
                height: 32,
                onPressed: onBack,
              ),
              const Spacer(),
              if (g.youtube != null || g.trailer != null)
                EZIconButton(
                  Icons.play_circle_outline,
                  tooltip: tr('Trailer'),
                  onPressed: () {
                    final url = g.trailer ?? 'https://youtu.be/${g.youtube}';
                    launchUrl(Uri.parse(url));
                  },
                ),
              if (g.postUrl != null)
                EZIconButton(
                  Icons.telegram,
                  tooltip: tr('Post in Telegram'),
                  onPressed: () => launchUrl(Uri.parse(g.postUrl!)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // left column: cover + download buttons
                  SizedBox(
                    width: 260,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: g.cover != null
                              ? Image.network(
                                  g.coverUrl,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 300,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                )
                              : Container(
                                  height: 300,
                                  color: const Color(0xFF1A1A1A),
                                ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: EZButton(
                                tr('Download and install'),
                                icon: Icons.download,
                                color: EZColors.accent,
                                textColor: const Color(0xFF111111),
                                onPressed: g.links.isEmpty
                                    ? null
                                    : () => _download(g, install: true),
                              ),
                            ),
                            const SizedBox(width: 6),
                            EZIconButton(
                              Icons.settings,
                              tooltip: tr('Install settings'),
                              onPressed: () async {
                                final o = await showInstallOptionsDialog(
                                  context,
                                  InstallOptions(),
                                );
                                if (o != null) {
                                  _download(
                                    g,
                                    install: !o.downloadOnly,
                                    opts: o,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        EZButton(
                          tr('Download to PC…'),
                          onPressed: g.links.isEmpty
                              ? null
                              : () => _download(g, install: false),
                        ),
                        if (g.special)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: EZColors.banner,
                                border: Border.all(
                                  color: EZColors.bannerBorder,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tr('Special install') +
                                    ' — ' +
                                    tr(
                                      'Non-standard installation — read the notes below.',
                                    ),
                                style: const TextStyle(
                                  color: EZColors.warn,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        if ((g.downloadNotes ?? '').isNotEmpty ||
                            (g.installNotes ?? '').isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: cardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr(
                                    'From the post (as written by its author):',
                                  ),
                                  style: EZText.group,
                                ),
                                const SizedBox(height: 6),
                                SelectableText(
                                  '${g.installNotes ?? ''}\n${g.downloadNotes ?? ''}'
                                      .trim(),
                                  style: const TextStyle(
                                    color: EZColors.text,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // right: title + meta + description + links
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.sheetTitle.isNotEmpty ? g.sheetTitle : g.title,
                          style: const TextStyle(
                            color: EZColors.textBright,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: [
                            if (g.language != null) _chip(g.language!),
                            ...g.genres.map(_chip),
                            if (g.multiplayer != null)
                              _chip('MP: ${g.multiplayer}'),
                            if (g.ovrport) _chip('OVRport'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(tr('Description'), style: EZText.section),
                        const SizedBox(height: 4),
                        SelectableText(
                          g.description?.isNotEmpty == true
                              ? g.description!
                              : tr('No description'),
                          style: const TextStyle(
                            color: EZColors.text,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(tr('Download'), style: EZText.section),
                        const SizedBox(height: 6),
                        if (g.links.isEmpty)
                          Text(
                            tr('No download links — open the post in Telegram'),
                            style: EZText.hint,
                          ),
                        for (final l in g.links) _linkRow(context, g, l),
                      ],
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

  Widget _chip(String t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        t,
        style: const TextStyle(
          color: Color(0xFFBDBDBD),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _linkRow(BuildContext context, Game g, GameLink l) {
    final icon = l.kind == 'tg'
        ? Icons.telegram
        : l.kind == 'yandex' || l.kind == 'gdrive' || l.kind == 'sber'
        ? Icons.cloud
        : Icons.link;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: cardDecoration(radius: 8),
        child: Row(
          children: [
            StatusDot(_linkColor(l.status)),
            const SizedBox(width: 8),
            Icon(icon, size: 16, color: EZColors.textDim),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.label.isNotEmpty ? l.label : l.kind,
                    style: const TextStyle(
                      color: Color(0xFFE4E4E4),
                      fontSize: 12,
                    ),
                  ),
                  if (l.note != null || l.size > 0)
                    Text(
                      [
                        if (l.size > 0) fmtBytes(l.size),
                        if (l.note != null) l.note,
                      ].join(' · '),
                      style: EZText.hint,
                    ),
                ],
              ),
            ),
            EZIconButton(
              Icons.copy,
              tooltip: tr('Copy link'),
              size: 24,
              onPressed: () => Clipboard.setData(ClipboardData(text: l.url)),
            ),
            EZIconButton(
              Icons.open_in_new,
              tooltip: tr('Open in the browser'),
              size: 24,
              onPressed: () => launchUrl(Uri.parse(l.url)),
            ),
            EZIconButton(
              Icons.download,
              tooltip: tr('Download'),
              size: 24,
              onPressed: () => Downloads.instance.enqueue(
                title: g.title,
                url: l.url,
                kind: l.kind,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _download(Game g, {required bool install, InstallOptions? opts}) {
    // prefer a working cloud link
    final link = g.links.cast<GameLink?>().firstWhere(
      (l) =>
          l!.status == 'ok' &&
          (l.kind == 'yandex' || l.kind == 'gdrive' || l.kind == 'sber'),
      orElse: () => g.links.isNotEmpty ? g.links.first : null,
    );
    if (link == null) return;
    Downloads.instance.enqueue(
      title: g.title,
      url: link.url,
      kind: link.kind,
      installAfter: install ? (opts ?? InstallOptions()) : null,
    );
  }
}
