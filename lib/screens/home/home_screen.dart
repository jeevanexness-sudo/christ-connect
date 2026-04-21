import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';
import '../../widgets/widgets.dart';
import '../courses/courses_screen.dart';
import '../community/community_screen.dart';
import '../matrimony/matrimony_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onSwitch;
  const HomeScreen({super.key, required this.onSwitch});

  void _tileAction(BuildContext ctx, String id) {
    switch (id) {
      case 'bible':     onSwitch(K.tabBible); break;
      case 'worship':   onSwitch(K.tabWorship); break;
      case 'media':     onSwitch(K.tabMedia); break;
      case 'community': push(ctx, const CommunityScreen()); break;
      case 'courses':   push(ctx, const CoursesScreen()); break;
      case 'matrimony': push(ctx, const MatrimonyScreen()); break;
    }
  }

  void push(BuildContext ctx, Widget w) =>
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => w));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(child: _Header(onSwitch: onSwitch)),
            // Daily verse
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: K.pad),
                child: _VerseCard(onRead: () => onSwitch(K.tabBible)),
              ),
            ),
            // Section: Explore
            _sectionPad(title: 'Explore', top: 24),
            // Tiles grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: K.pad),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _TileCard(
                    tile: MockData.quickTiles[i],
                    onTap: () =>
                        _tileAction(context, MockData.quickTiles[i].id),
                  ),
                  childCount: MockData.quickTiles.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.08,
                ),
              ),
            ),
            // Section: Worship
            _sectionPad(
              title: 'Worship Now',
              action: 'See all',
              onAction: () => onSwitch(K.tabWorship),
              top: 26,
            ),
            SliverToBoxAdapter(child: _WorshipRow()),
            // Section: Community
            _sectionPad(
              title: 'Community',
              action: 'See all',
              onAction: () =>
                  push(context, const CommunityScreen()),
              top: 26,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: EdgeInsets.fromLTRB(
                      K.pad, i == 0 ? 0 : 10, K.pad, 0),
                  child: _PostPreview(post: MockData.posts[i]),
                ),
                childCount: 2,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _sectionPad({
    required String title,
    String? action,
    VoidCallback? onAction,
    double top = 0,
  }) =>
      SliverToBoxAdapter(
        child: Padding(
          padding:
              EdgeInsets.fromLTRB(K.pad, top, K.pad, 14),
          child: SectionHeader(
              title: title, actionLabel: action, onAction: onAction),
        ),
      );
}

// ─── Header ──────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final void Function(int) onSwitch;
  const _Header({required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(K.pad, 14, K.pad, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TUESDAY, APR 21', style: AppTextStyles.overline),
                const SizedBox(height: 2),
                Text('Christ Connect', style: AppTextStyles.heading1),
              ],
            ),
          ),
          CCIconBtn(icon: Icons.search_rounded),
          const SizedBox(width: 10),
          CCIconBtn(icon: Icons.notifications_outlined),
        ],
      ),
    );
  }
}

// ─── Daily Verse Card ─────────────────────────────────────────────────────
class _VerseCard extends StatelessWidget {
  final VoidCallback onRead;
  const _VerseCard({required this.onRead});

  @override
  Widget build(BuildContext context) {
    final v = MockData.dailyVerse;
    return Stack(children: [
      GradientCard(
        gradient: AppColors.verseGradient,
        borderColor: AppColors.gold.withOpacity(0.18),
        radius: 22,
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CCBadge(text: '✦  VERSE OF THE DAY'),
          const SizedBox(height: 14),
          Text('"${v.text}"', style: AppTextStyles.verseText),
          const SizedBox(height: 10),
          Text('— ${v.reference}', style: AppTextStyles.verseRef),
          const SizedBox(height: 18),
          Row(children: [
            GoldButton(label: 'Read Chapter', onTap: onRead),
            const SizedBox(width: 10),
            OutlineButton2(label: 'Share  ↗'),
          ]),
        ]),
      ),
      Positioned(
        right: 6, top: -4,
        child: IgnorePointer(
          child: Opacity(
            opacity: 0.05,
            child: Text('✝',
                style: TextStyle(fontSize: 100, color: AppColors.white)),
          ),
        ),
      ),
    ]);
  }
}

// ─── Quick Tile ───────────────────────────────────────────────────────────
class _TileCard extends StatelessWidget {
  final QuickTile tile;
  final VoidCallback onTap;
  const _TileCard({required this.tile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: tile.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tile.icon, color: tile.color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(tile.label,
              style: AppTextStyles.caption
                  .copyWith(fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

// ─── Worship Horizontal Row ───────────────────────────────────────────────
class _WorshipRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 186,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: K.pad),
        itemCount: MockData.songs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _SongCard(song: MockData.songs[i]),
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  final Song song;
  const _SongCard({required this.song});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 136,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(13),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity, height: 96,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1F44), Color(0xFF1A2E5A), Color(0xFF2B3F70)
                ],
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Center(
              child: Icon(Icons.music_note_rounded,
                  color: AppColors.gold, size: 32),
            ),
          ),
          const SizedBox(height: 10),
          Text(song.title,
              style: AppTextStyles.cardTitle,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(song.artist,
              style: AppTextStyles.cardSubtitle,
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

// ─── Community Post Preview ───────────────────────────────────────────────
class _PostPreview extends StatelessWidget {
  final CommunityPost post;
  const _PostPreview({required this.post});

  @override
  Widget build(BuildContext context) {
    return CCCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AvatarCircle(initials: post.avatar, size: 38, bgColor: post.avatarBg),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(post.author,
                      style: AppTextStyles.cardTitle
                          .copyWith(fontSize: 13)),
                  Text(post.timeAgo,
                      style: AppTextStyles.cardSubtitle
                          .copyWith(fontSize: 10)),
                ]),
              const SizedBox(height: 5),
              Text(post.content,
                  style: AppTextStyles.body2.copyWith(fontSize: 12),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
        ),
      ]),
    );
  }
}
