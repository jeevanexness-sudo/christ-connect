import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';
import '../../widgets/widgets.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  String _book    = 'Philippians';
  int    _chapter = 4;
  bool   _showBooks = false;
  String _version = 'KJV';
  final Map<int, bool> _hl = {};

  static const _versions = ['KJV', 'NIV', 'ESV', 'NLT', 'NKJV'];

  List<BibleVerse> get _verses =>
      _book == 'John' ? MockData.john3 : MockData.philippians4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearch()),
            SliverToBoxAdapter(child: _buildSelector()),
            if (_showBooks)
              ..._bookBrowser()
            else
              ..._reader(),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 14, K.pad, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bible', style: AppTextStyles.heading1),
          const SizedBox(height: 2),
          Text('Read  ·  Study  ·  Highlight', style: AppTextStyles.caption),
        ]),
      );

  Widget _buildSearch() => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            const Icon(Icons.search_rounded, color: AppColors.muted, size: 18),
            const SizedBox(width: 10),
            Text('Search scripture…', style: AppTextStyles.body2),
          ]),
        ),
      );

  Widget _buildSelector() => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 14),
        child: CCCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('READING', style: AppTextStyles.overline),
                const SizedBox(height: 2),
                Text('$_book  ·  Ch. $_chapter',
                    style: AppTextStyles.heading2),
              ]),
              GoldButton(
                label: _showBooks ? 'Read' : 'Change',
                onTap: () => setState(() => _showBooks = !_showBooks),
              ),
            ],
          ),
        ),
      );

  // ── Book Browser ────────────────────────────────────────────────────
  List<Widget> _bookBrowser() {
    final ot = MockData.books.where((b) => b.testament == 'OT').toList();
    final nt = MockData.books.where((b) => b.testament == 'NT').toList();
    return [
      _slabHeader('Old Testament'),
      _bookGrid(ot),
      _slabHeader('New Testament', top: 20),
      _bookGrid(nt),
    ];
  }

  SliverToBoxAdapter _slabHeader(String t, {double top = 0}) =>
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(K.pad, top, K.pad, 12),
          child: SectionHeader(title: t),
        ),
      );

  Widget _bookGrid(List<BibleBook> list) => SliverPadding(
        padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 0),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _BookTile(
              book: list[i],
              selected: list[i].name == _book,
              onTap: () => setState(() {
                _book = list[i].name;
                _chapter = 1;
                _showBooks = false;
              }),
            ),
            childCount: list.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10,
            mainAxisSpacing: 10, childAspectRatio: 3.0,
          ),
        ),
      );

  // ── Reader ───────────────────────────────────────────────────────────
  List<Widget> _reader() => [
        SliverToBoxAdapter(child: _versionChips()),
        SliverToBoxAdapter(child: _readingPlan()),
        SliverToBoxAdapter(child: _passage()),
        SliverToBoxAdapter(child: _navBtns()),
      ];

  Widget _versionChips() => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _versions.map((v) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterPill(
                  label: v,
                  isActive: v == _version,
                  onTap: () => setState(() => _version = v),
                ),
              );
            }).toList(),
          ),
        ),
      );

  Widget _readingPlan() => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 18),
        child: GradientCard(
          gradient: const LinearGradient(
              colors: [Color(0xFF081830), Color(0xFF0E244A)]),
          borderColor: AppColors.gold.withOpacity(0.2),
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text('30-Day Reading Plan',
                      style: AppTextStyles.bodyBold.copyWith(fontSize: 13)),
                  Text('Day 18', style: AppTextStyles.goldLabel),
                ]),
                const SizedBox(height: 6),
                const CCProgressBar(value: 0.60, height: 4),
              ]),
            ),
          ]),
        ),
      );

  Widget _passage() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: K.pad),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${_book.toUpperCase()}  ·  CHAPTER $_chapter  ·  $_version',
              style: AppTextStyles.overline,
            ),
            const SizedBox(height: 18),
            ..._verses.map((v) => _VerseRow(
                  verse: v,
                  hl: _hl[v.verse] ?? false,
                  onTap: () => setState(
                      () => _hl[v.verse] = !(_hl[v.verse] ?? false)),
                )),
          ]),
        ),
      );

  Widget _navBtns() => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 16, K.pad, 0),
        child: Row(children: [
          Expanded(
              child: OutlineButton2(
                  label: '← Previous', onTap: () {},
                  width: double.infinity)),
          const SizedBox(width: 12),
          Expanded(
              child: GoldButton(
                  label: 'Next →', onTap: () {},
                  width: double.infinity)),
        ]),
      );
}

// ─── Verse Row ─────────────────────────────────────────────────────────────
class _VerseRow extends StatelessWidget {
  final BibleVerse verse;
  final bool       hl;
  final VoidCallback onTap;
  const _VerseRow(
      {required this.verse, required this.hl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: hl ? AppColors.gold.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 24,
            child: Text('${verse.verse}',
                style: AppTextStyles.verseRef.copyWith(fontSize: 11)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(verse.text,
                style: AppTextStyles.body1.copyWith(
                  color: hl ? AppColors.gold : const Color(0xDDFFFFFF),
                  fontSize: 15,
                )),
          ),
        ]),
      ),
    );
  }
}

// ─── Book Tile ──────────────────────────────────────────────────────────────
class _BookTile extends StatelessWidget {
  final BibleBook    book;
  final bool         selected;
  final VoidCallback onTap;
  const _BookTile(
      {required this.book, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.gold.withOpacity(0.08)
              : AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.gold.withOpacity(0.4)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(book.name,
                style: AppTextStyles.cardTitle.copyWith(
                    color: selected ? AppColors.gold : AppColors.white)),
            Text('${book.chapters} chapters',
                style: AppTextStyles.cardSubtitle),
          ],
        ),
      ),
    );
  }
}
