import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../services/bible_service.dart';
import '../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════
// Bible Screen — Full English + Telugu Bible via API
// ════════════════════════════════════════════════════════════════════════════
class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen>
    with SingleTickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────
  BibleBook    _book        = BibleService.allBooks[49]; // Philippians
  int          _chapter     = 4;
  String       _translation = 'kjv';
  bool         _isTelugu    = false;

  BibleChapter? _chapterData;
  bool          _loading    = false;
  String?       _error;

  final Set<int> _highlighted = {};
  bool _showSearch  = false;
  bool _showBooks   = false;

  final _searchCtrl = TextEditingController();
  List<SearchResult> _searchResults = [];
  bool _searching = false;

  late final TabController _testamentTab = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    _loadChapter();
  }

  @override
  void dispose() {
    _testamentTab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Load chapter from API ────────────────────────────────────────────
  Future<void> _loadChapter() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await BibleService.instance.fetchChapter(
        bookName:    _book.name,
        chapter:     _chapter,
        translation: _translation,
      );
      if (!mounted) return;
      setState(() { _chapterData = data; _loading = false; _highlighted.clear(); });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); _loading = false; });
    }
  }

  // ── Search ────────────────────────────────────────────────────────────
  Future<void> _search(String query) async {
    if (query.trim().length < 3) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    final results = await BibleService.instance.search(query, _translation);
    if (!mounted) return;
    setState(() { _searchResults = results; _searching = false; });
  }

  // ── Navigation ────────────────────────────────────────────────────────
  void _prevChapter() {
    if (_chapter > 1) {
      setState(() { _chapter--; _highlighted.clear(); });
      _loadChapter();
    } else {
      final idx = BibleService.allBooks.indexOf(_book);
      if (idx > 0) {
        final prev = BibleService.allBooks[idx - 1];
        setState(() { _book = prev; _chapter = prev.chapters; _highlighted.clear(); });
        _loadChapter();
      }
    }
  }

  void _nextChapter() {
    if (_chapter < _book.chapters) {
      setState(() { _chapter++; _highlighted.clear(); });
      _loadChapter();
    } else {
      final idx = BibleService.allBooks.indexOf(_book);
      if (idx < BibleService.allBooks.length - 1) {
        setState(() { _book = BibleService.allBooks[idx + 1]; _chapter = 1; _highlighted.clear(); });
        _loadChapter();
      }
    }
  }

  void _toggleHighlight(int verse) {
    HapticFeedback.lightImpact();
    setState(() {
      _highlighted.contains(verse) ? _highlighted.remove(verse) : _highlighted.add(verse);
    });
  }

  void _copyVerse(String text, String ref) {
    Clipboard.setData(ClipboardData(text: '$text\n— $ref'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verse copied!', style: AppTextStyles.body2.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          if (_showSearch) _buildSearchBar(),
          if (!_showSearch && !_showBooks) _buildControls(),
          Expanded(
            child: _showBooks
                ? _BookBrowser(
                    selectedBook: _book,
                    activeTab:    _testamentTab,
                    isTelugu:     _isTelugu,
                    onSelect: (book) {
                      setState(() { _book = book; _chapter = 1; _showBooks = false; });
                      _loadChapter();
                    },
                  )
                : _showSearch
                    ? _SearchView(
                        results:    _searchResults,
                        isSearching: _searching,
                        isTelugu:   _isTelugu,
                        onSelect: (r) {
                          final book = BibleService.allBooks.firstWhere(
                            (b) => b.name == r.book,
                            orElse: () => _book,
                          );
                          setState(() {
                            _book     = book;
                            _chapter  = r.chapter;
                            _showSearch = false;
                            _searchCtrl.clear();
                            _searchResults = [];
                          });
                          _loadChapter();
                        },
                      )
                    : _loading
                        ? const _Loader()
                        : _error != null
                            ? _ErrorView(error: _error!, onRetry: _loadChapter)
                            : _chapterData == null
                                ? const _Loader()
                                : _ReaderView(
                                    chapter:     _chapterData!,
                                    highlighted: _highlighted,
                                    book:        _book,
                                    isTelugu:    _isTelugu,
                                    onHighlight: _toggleHighlight,
                                    onCopy:      _copyVerse,
                                    onPrev:      _prevChapter,
                                    onNext:      _nextChapter,
                                  ),
          ),
        ]),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(K.pad, 14, K.pad, 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() { _showBooks = !_showBooks; _showSearch = false; }),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bible', style: AppTextStyles.heading1),
              Row(children: [
                Text(
                  _isTelugu ? '${_book.nameTelugu} ${_chapter}వ అధ్యాయం'
                             : '${_book.name}  ·  Chapter $_chapter',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(width: 4),
                Icon(
                  _showBooks ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.gold, size: 16,
                ),
              ]),
            ]),
          ),
        ),
        // Language toggle
        GestureDetector(
          onTap: () {
            setState(() {
              _isTelugu    = !_isTelugu;
              _translation = _isTelugu ? 'tel' : 'kjv';
            });
            _loadChapter();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color:        _isTelugu ? AppColors.gold.withOpacity(0.15) : AppColors.cardDark,
              borderRadius: BorderRadius.circular(20),
              border:       Border.all(color: _isTelugu ? AppColors.gold : AppColors.border2),
            ),
            child: Text(
              _isTelugu ? 'తెలుగు' : 'English',
              style: GoogleFonts.nunito(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: _isTelugu ? AppColors.gold : AppColors.muted,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        CCIconBtn(
          icon:      _showSearch ? Icons.close_rounded : Icons.search_rounded,
          iconColor: _showSearch ? AppColors.gold : AppColors.white,
          onTap: () => setState(() {
            _showSearch = !_showSearch;
            _showBooks  = false;
            if (!_showSearch) { _searchCtrl.clear(); _searchResults = []; }
          }),
        ),
      ]),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(K.pad, 10, K.pad, 4),
      child: TextField(
        controller:    _searchCtrl,
        autofocus:     true,
        style: GoogleFonts.nunito(color: AppColors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText:  _isTelugu ? 'లేఖనం వెతకండి...' : 'Search scripture (e.g. John 3:16)...',
          hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
          suffixIcon: _searching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2)),
                )
              : null,
        ),
        onChanged: _search,
      ),
    );
  }

  // ── Controls — translation + reading plan ──────────────────────────
  Widget _buildControls() {
    if (_isTelugu) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(K.pad, 8, K.pad, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: BibleService.translations
              .where((t) => t.language == 'English')
              .map((t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterPill(
                      label:    t.name,
                      isActive: _translation == t.id,
                      onTap: () {
                        setState(() => _translation = t.id);
                        _loadChapter();
                      },
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Reader View — displays chapter verses
// ════════════════════════════════════════════════════════════════════════════
class _ReaderView extends StatelessWidget {
  final BibleChapter chapter;
  final Set<int>     highlighted;
  final BibleBook    book;
  final bool         isTelugu;
  final void Function(int)           onHighlight;
  final void Function(String, String) onCopy;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _ReaderView({
    required this.chapter,
    required this.highlighted,
    required this.book,
    required this.isTelugu,
    required this.onHighlight,
    required this.onCopy,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Reading plan bar
        SliverToBoxAdapter(child: _ReadingPlanBar()),

        // Chapter heading
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(K.pad, 16, K.pad, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.verseGradient,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gold.withOpacity(0.2)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  isTelugu
                      ? '${book.nameTelugu} ${chapter.chapter}వ అధ్యాయం'
                      : '${chapter.book} Chapter ${chapter.chapter}',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 2),
                Text(
                  '${chapter.translation}  ·  ${chapter.verses.length} verses',
                  style: AppTextStyles.caption,
                ),
              ]),
            ),
          ),
        ),

        // Verses
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: K.pad),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final v         = chapter.verses[i];
                final isHl      = highlighted.contains(v.verse);
                final ref       = '${chapter.book} ${chapter.chapter}:${v.verse} ${chapter.translation}';
                return _VerseRow(
                  verse:       v,
                  isHighlight: isHl,
                  onTap:       () => onHighlight(v.verse),
                  onLongPress: () => onCopy(v.text, ref),
                  isTelugu:    isTelugu,
                );
              },
              childCount: chapter.verses.length,
            ),
          ),
        ),

        // Nav buttons
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(K.pad, 20, K.pad, 40),
            child: Row(children: [
              Expanded(child: OutlineButton2(label: '← Previous', onTap: onPrev, width: double.infinity)),
              const SizedBox(width: 12),
              Expanded(child: GoldButton(label: 'Next →', onTap: onNext, width: double.infinity)),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Verse Row ─────────────────────────────────────────────────────────────
class _VerseRow extends StatelessWidget {
  final BibleVerse verse;
  final bool       isHighlight;
  final bool       isTelugu;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _VerseRow({
    required this.verse,
    required this.isHighlight,
    required this.isTelugu,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:      onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin:  const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color:        isHighlight ? AppColors.gold.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHighlight ? AppColors.gold.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 28,
            child: Text(
              '${verse.verse}',
              style: AppTextStyles.verseRef.copyWith(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              verse.text,
              style: isTelugu
                  ? GoogleFonts.notoSansTelugu(
                      fontSize: 15, color: isHighlight ? AppColors.gold : AppColors.textPrimary,
                      height: 1.8,
                    )
                  : AppTextStyles.body1.copyWith(
                      fontSize: 15,
                      color: isHighlight ? AppColors.gold : AppColors.textPrimary,
                    ),
            ),
          ),
          if (isHighlight)
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 2),
              child: Icon(Icons.bookmark_rounded, color: AppColors.gold, size: 14),
            ),
        ]),
      ),
    );
  }
}

// ── Reading Plan Bar ──────────────────────────────────────────────────────
class _ReadingPlanBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final day  = DateTime.now().day;
    final pct  = (day / 30).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(K.pad, 10, K.pad, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color:        AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          const Icon(Icons.local_fire_department_rounded, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('30-Day Reading Plan', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
                Text('Day $day', style: AppTextStyles.goldLabel.copyWith(fontSize: 11)),
              ]),
              const SizedBox(height: 4),
              CCProgressBar(value: pct, height: 3),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Book Browser
// ════════════════════════════════════════════════════════════════════════════
class _BookBrowser extends StatefulWidget {
  final BibleBook      selectedBook;
  final TabController  activeTab;
  final bool           isTelugu;
  final void Function(BibleBook) onSelect;

  const _BookBrowser({
    required this.selectedBook,
    required this.activeTab,
    required this.isTelugu,
    required this.onSelect,
  });

  @override
  State<_BookBrowser> createState() => _BookBrowserState();
}

class _BookBrowserState extends State<_BookBrowser> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final allBooks = BibleService.allBooks;
    final filtered = _query.isEmpty
        ? allBooks
        : allBooks.where((b) =>
            b.name.toLowerCase().contains(_query.toLowerCase()) ||
            b.nameTelugu.contains(_query)).toList();

    final ot = filtered.where((b) => b.testament == 'OT').toList();
    final nt = filtered.where((b) => b.testament == 'NT').toList();

    return Column(children: [
      // Search books
      Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 8, K.pad, 8),
        child: TextField(
          style: GoogleFonts.nunito(color: AppColors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: widget.isTelugu ? 'పుస్తకం వెతకండి...' : 'Search book...',
            hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 13),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted, size: 18),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      // OT / NT tabs
      if (_query.isEmpty) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 8),
          child: Row(children: [
            Expanded(child: FilterPill(
              label: 'Old Testament (${ot.length})',
              isActive: widget.activeTab.index == 0,
              onTap: () { widget.activeTab.animateTo(0); setState(() {}); },
            )),
            const SizedBox(width: 8),
            Expanded(child: FilterPill(
              label: 'New Testament (${nt.length})',
              isActive: widget.activeTab.index == 1,
              onTap: () { widget.activeTab.animateTo(1); setState(() {}); },
            )),
          ]),
        ),
      ],
      // Books grid
      Expanded(
        child: _query.isNotEmpty
            ? _booksGrid(filtered, widget.isTelugu)
            : TabBarView(
                controller: widget.activeTab,
                children: [
                  _booksGrid(ot, widget.isTelugu),
                  _booksGrid(nt, widget.isTelugu),
                ],
              ),
      ),
    ]);
  }

  Widget _booksGrid(List<BibleBook> books, bool isTelugu) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: K.pad, vertical: 4),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10,
        mainAxisSpacing: 10, childAspectRatio: 2.8,
      ),
      itemCount: books.length,
      itemBuilder: (_, i) {
        final book     = books[i];
        final selected = book.name == widget.selectedBook.name;
        return GestureDetector(
          onTap: () => widget.onSelect(book),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:        selected ? AppColors.gold.withOpacity(0.1) : AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.gold.withOpacity(0.5) : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
                Text(
                  isTelugu ? book.nameTelugu : book.name,
                  style: AppTextStyles.cardTitle.copyWith(
                    color:    selected ? AppColors.gold : AppColors.white,
                    fontSize: isTelugu ? 11 : 13,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text('${book.chapters} ch',
                  style: AppTextStyles.overline.copyWith(fontSize: 9)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Search View
// ════════════════════════════════════════════════════════════════════════════
class _SearchView extends StatelessWidget {
  final List<SearchResult> results;
  final bool               isSearching;
  final bool               isTelugu;
  final void Function(SearchResult) onSelect;

  const _SearchView({
    required this.results,
    required this.isSearching,
    required this.isTelugu,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearching) return const _Loader();
    if (results.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_rounded, color: AppColors.muted, size: 48),
          const SizedBox(height: 12),
          Text('Type to search scripture', style: AppTextStyles.body2),
          const SizedBox(height: 4),
          Text('e.g.  John 3:16  or  love', style: AppTextStyles.caption),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(K.pad),
      itemCount: results.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final r = results[i];
        return GestureDetector(
          onTap: () => onSelect(r),
          child: CCCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CCBadge(text: r.reference, color: AppColors.gold),
              const SizedBox(height: 8),
              Text(r.text, style: AppTextStyles.body2.copyWith(fontSize: 13, height: 1.6)),
            ]),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Utility widgets
// ════════════════════════════════════════════════════════════════════════════
class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2.5));
}

class _ErrorView extends StatelessWidget {
  final String       error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded, color: AppColors.muted, size: 52),
        const SizedBox(height: 16),
        Text('Could not load chapter', style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        Text(error, style: AppTextStyles.body2, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        GoldButton(label: 'Try Again', onTap: onRetry, width: 140),
      ]),
    ),
  );
}
