import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/catalog.dart';
import '../core/devices.dart';
import '../core/downloads.dart';
import '../core/installer.dart';
import '../core/log.dart';
import '../core/packages.dart';
import '../settings.dart';
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
  final _search = TextEditingController();
  final _kbFocus = FocusNode();
  final Set<String> _genres = {};
  String? _language;
  String? _type;
  int? _minSize;
  int? _maxSize;
  String _sort = 'name'; // name | size

  static const _pageSize = 48;
  int _visible = _pageSize;
  int _total = 0;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    Catalog.instance.addListener(_r);
    Settings.instance.addListener(_r);
    Packages.instance.addListener(_r);
    Devices.instance.addListener(_onDevice);
    Installer.instance.addListener(_onJobs);
    if (Devices.instance.info != null) Packages.instance.refresh();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_visible < _total &&
        _scroll.position.pixels >
            _scroll.position.maxScrollExtent - 400) {
      setState(() => _visible += _pageSize);
    }
  }

  void _resetPage() {
    _visible = _pageSize;
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _r() => setState(() {});

  void _onDevice() {
    if (Devices.instance.info != null &&
        Packages.instance.items.isEmpty &&
        !Packages.instance.loading) {
      Packages.instance.refresh();
    }
  }

  int _lastDone = 0;
  void _onJobs() {
    final d = Installer.instance.jobs
        .where((j) => j.state == JobState.done)
        .length;
    if (d != _lastDone) {
      _lastDone = d;
      if (Devices.instance.info != null) Packages.instance.refresh();
    }
  }

  @override
  void dispose() {
    Catalog.instance.removeListener(_r);
    Settings.instance.removeListener(_r);
    Packages.instance.removeListener(_r);
    Devices.instance.removeListener(_onDevice);
    Installer.instance.removeListener(_onJobs);
    _scroll.dispose();
    _kbFocus.dispose();
    _search.dispose();
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
        child: IndexedStack(
          index: _selected == null ? 0 : 1,
          children: [
            _catalog(),
            if (_selected != null)
              _GameDetails(
                game: _selected!,
                onBack: () => setState(() => _selected = null),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
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
      downloadableOnly: !Settings.instance.get(
        'catalog_show_undownloadable',
        false,
      ),
    );
    if (_sort == 'name') {
      games.sort((a, b) => a.title.compareTo(b.title));
    } else {
      games.sort((a, b) => b.bestSize.compareTo(a.bestSize));
    }
    _total = games.length;
    if (_visible > _total || _visible < _pageSize) {
      _visible = _total < _pageSize ? _total : _pageSize;
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 240,
                    child: TextField(
                      controller: _search,
                      style: const TextStyle(
                        color: EZColors.textBright,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: t.searchGames,
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
                          borderSide: const BorderSide(
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                      onChanged: (v) => setState(() {
                        _query = v;
                        _resetPage();
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _filterMenu(
                    t.type,
                    {null: t.all, 'ovrport': 'OVRport', 'fnal': 'FNAL'},
                    _type,
                    (v) => setState(() {
                      _type = v;
                      _resetPage();
                    }),
                  ),
                  _filterMenu(
                    t.size,
                    {null: t.all, 's': t.k1GB, 'm': t.k15GB, 'l': t.k5GB},
                    _sizeKey(),
                    _setSize,
                  ),
                  _filterMenu(
                    t.sort,
                    {'name': t.aZ, 'size': t.size},
                    _sort,
                    (v) => setState(() {
                      _sort = v ?? 'name';
                      _resetPage();
                    }),
                  ),
                  const SizedBox(width: 8),
                  _genreMenu(cat),
                  const SizedBox(width: 12),
                  if (cat.version.isNotEmpty)
                    Text(
                      t.catalogVersion2(arg1: cat.version),
                      style: EZText.hint,
                      overflow: TextOverflow.ellipsis,
                    ),
                  EZIconButton(
                    Icons.refresh,
                    tooltip: t.checkForUpdates,
                    onPressed: cat.loading ? null : () => cat.checkUpdates(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            // The grid stays mounted under any state overlays so its scroll
            // position is never recreated mid-session.
            child: Stack(
              children: [
                GridView.builder(
                  key: const PageStorageKey('picolandGrid'),
                  controller: _scroll,
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 170,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                  itemCount: _visible,
                  itemBuilder: (_, i) => _GameCard(
                    game: games[i],
                    onTap: () {
                      setState(() => _selected = games[i]);
                      _kbFocus.requestFocus();
                    },
                  ),
                ),
                if (cat.loading && games.isEmpty)
                  Positioned.fill(
                    child: Center(
                      child: Text(t.loadingTheCatalog, style: EZText.hint),
                    ),
                  )
                else if (!cat.available)
                  Positioned.fill(
                    child: EmptyPlug(
                      Icons.cloud_off,
                      t.catalogIsUnavailable,
                      subtitle: cat.error,
                    ),
                  )
                else if (games.isEmpty)
                  Positioned.fill(
                    child: EmptyPlug(
                      Icons.search_off,
                      t.nothingMatchesTheFilter,
                    ),
                  ),
              ],
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
      _resetPage();
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
                '$label: ${items[current] ?? t.all}',
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
      tooltip: t.findACategory,
      color: const Color(0xFF242424),
      onSelected: (g) => setState(() {
        _genres.contains(g) ? _genres.remove(g) : _genres.add(g);
        _resetPage();
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
          _genres.isEmpty ? t.allGames : '${_genres.length}',
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
                    _coverImage(g, fit: BoxFit.cover),
                    if (_isInstalled(g))
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Tooltip(
                          message: t.installedBadge,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: EZColors.ok,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
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
                t.backToCatalog,
                icon: Icons.arrow_back,
                height: 32,
                onPressed: onBack,
              ),
              const Spacer(),
              if (g.youtube != null || g.trailer != null)
                EZIconButton(
                  Icons.play_circle_outline,
                  tooltip: t.trailer,
                  onPressed: () => openExternalUrl(
                    context,
                    g.trailer ?? 'https://youtu.be/${g.youtube}',
                  ),
                ),
              if (g.postUrl != null)
                EZIconButton(
                  Icons.telegram,
                  tooltip: t.postInTelegram,
                  onPressed: () => openExternalUrl(context, g.postUrl!),
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
                              ? _coverImage(g)
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
                                t.downloadAndInstall,
                                icon: Icons.download,
                                color: EZColors.accent,
                                textColor: const Color(0xFF111111),
                                onPressed: g.links.isEmpty
                                    ? null
                                    : () =>
                                          _download(context, g, install: true),
                              ),
                            ),
                            ListenableBuilder(
                              listenable: Devices.instance,
                              builder: (_, _) {
                                final serials = Devices.instance.serials;
                                if (serials.length < 2 || g.links.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: PopupMenuButton<String>(
                                    tooltip: t.chooseAHeadset,
                                    color: const Color(0xFF242424),
                                    onSelected: (s) {
                                      Devices.instance.selectDevice(s);
                                      _download(context, g, install: true);
                                    },
                                    itemBuilder: (_) => serials
                                        .map(
                                          (s) => PopupMenuItem(
                                            value: s,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  s ==
                                                          Devices
                                                              .instance
                                                              .info
                                                              ?.serial
                                                      ? Icons.check_circle
                                                      : Icons.headset,
                                                  size: 15,
                                                  color: EZColors.accent,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  s,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    child: Container(
                                      width: 34,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: EZColors.accent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Color(0xFF111111),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            EZIconButton(
                              Icons.settings,
                              tooltip: t.installSettings,
                              onPressed: () async {
                                final o = await showInstallOptionsDialog(
                                  context,
                                  InstallOptions(),
                                );
                                if (o != null && context.mounted) {
                                  _download(
                                    context,
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
                        SizedBox(
                          width: double.infinity,
                          child: EZButton(
                            t.downloadToPC,
                            onPressed: g.links.isEmpty
                                ? null
                                : () => _download(context, g, install: false),
                          ),
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
                                '${t.specialInstall} — ${t.nonStandardInstallationReadTheNotesBelow}',
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
                                  t.fromThePostAsWrittenByIts,
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
                        Text(t.description, style: EZText.section),
                        const SizedBox(height: 4),
                        SelectableText(
                          g.description?.isNotEmpty == true
                              ? g.description!
                              : t.noDescription,
                          style: const TextStyle(
                            color: EZColors.text,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(t.download, style: EZText.section),
                        const SizedBox(height: 6),
                        if (g.links.isEmpty)
                          Text(
                            t.noDownloadLinksOpenThePostIn,
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
              tooltip: t.copyLink,
              size: 24,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: l.url));
                dlog('copied link: ${l.url}');
                toast(context, t.copied(arg1: l.url));
              },
            ),
            EZIconButton(
              Icons.open_in_new,
              tooltip: t.openInTheBrowser,
              size: 24,
              onPressed: () => openExternalUrl(context, l.url),
            ),
            EZIconButton(
              Icons.download,
              tooltip: t.download,
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

  Future<void> _download(
    BuildContext context,
    Game g, {
    required bool install,
    InstallOptions? opts,
  }) async {
    if (install && _isInstalled(g)) {
      final yes = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: EZColors.panel,
          title: Text(t.alreadyInstalled, style: EZText.section),
          content: Text(
            t.gameAlreadyInstalledReinstall(arg1: g.title),
            style: EZText.label,
          ),
          actions: [
            EZButton(t.cancel, onPressed: () => Navigator.pop(context, false)),
            EZButton(
              t.reinstall,
              color: EZColors.accent,
              textColor: const Color(0xFF111111),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );
      if (yes != true || !context.mounted) return;
    }
    final link = g.bestDownloadLink;
    if (link == null) {
      dlog('no usable link for ${g.title}');
      toast(context, t.noDownloadLinksOpenThePostIn);
      return;
    }
    dlog(
      'queueing download: ${g.title} via ${link.kind} (${link.url})'
      ' install=$install',
    );
    Downloads.instance.enqueue(
      title: g.title,
      url: link.url,
      kind: link.kind,
      installAfter: install ? (opts ?? InstallOptions()) : null,
    );
    toast(context, t.downloadAddedToQueueSeeTheInstall);
  }
}

/// True when the game is already on the headset — matched by normalized
/// title/sheet_title against installed labels, packages and install history.
bool _isInstalled(Game g) {
  final k = Packages.instance.installedKeys;
  return k.contains(Packages.norm(g.title)) ||
      k.contains(Packages.norm(g.sheetTitle));
}

/// Game cover: local file from the covers cache when present, otherwise
/// the network image, otherwise a dark placeholder.
Widget _coverImage(Game g, {BoxFit fit = BoxFit.contain}) {
  const placeholder = ColoredBox(color: Color(0xFF1A1A1A));
  if (g.cover == null) return placeholder;
  final lp = g.coverPath;
  if (lp != null && File(lp).existsSync()) {
    return Image.file(
      File(lp),
      fit: fit,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
  return Image.network(
    g.coverUrl,
    fit: fit,
    errorBuilder: (_, _, _) => placeholder,
  );
}
