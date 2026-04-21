import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';
import '../../widgets/widgets.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  int _activeFilter = 0;
  static const _cats = ['All', 'Services', 'Sermons', 'Events', 'Studies'];

  List<MediaItem> get _filtered {
    if (_activeFilter == 0) return MockData.mediaItems;
    final map = {1: 'service', 2: 'sermon', 3: 'event', 4: 'study'};
    final type = map[_activeFilter] ?? '';
    return MockData.mediaItems.where((m) => m.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _categories()),
            SliverToBoxAdapter(child: _featured()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(K.pad, 2, K.pad, 14),
                child: const SectionHeader(title: 'Recent Videos'),
              ),
            ),
            _filtered.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text('No videos in this category.',
                            style: TextStyle(color: AppColors.muted)),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: EdgeInsets.fromLTRB(
                            K.pad, i == 0 ? 0 : 12, K.pad, 0),
                        child: _VideoCard(item: _filtered[i]),
                      ),
                      childCount: _filtered.length,
                    ),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 14, K.pad, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Media', style: AppTextStyles.heading1),
          Text('Sermons  ·  Services  ·  Events',
              style: AppTextStyles.caption),
        ]),
      );

  Widget _categories() => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: K.pad),
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => FilterPill(
              label: _cats[i],
              isActive: i == _activeFilter,
              onTap: () => setState(() => _activeFilter = i),
            ),
          ),
        ),
      );

  Widget _featured() => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 22),
        child: GradientCard(
          gradient: AppColors.featuredGradient,
          borderColor: AppColors.blue.withOpacity(0.28),
          radius: 20,
          padding: const EdgeInsets.all(20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const LiveBadge(),
              const SizedBox(width: 8),
              CCBadge(text: 'FEATURED', color: AppColors.blue),
            ]),
            const SizedBox(height: 12),
            Text('Easter Sunday Service 2026',
                style: AppTextStyles.heading3.copyWith(fontSize: 17)),
            const SizedBox(height: 4),
            Text('Grace Fellowship  ·  1:14:22',
                style: AppTextStyles.cardSubtitle),
            const SizedBox(height: 16),
            Container(
              width: double.infinity, height: 130,
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 1.5),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: AppColors.gold, size: 30),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              CCBadge(text: '5.1K views', color: AppColors.muted),
              const SizedBox(width: 8),
              CCBadge(text: 'HD', color: AppColors.success),
            ]),
          ]),
        ),
      );
}

// ─── Video Card ─────────────────────────────────────────────────────────────
class _VideoCard extends StatelessWidget {
  final MediaItem item;
  const _VideoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return CCCard(
      onTap: () {},
      child: Row(children: [
        Container(
          width: 84, height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF0A1630), Color(0xFF152040)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: item.typeColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow_rounded,
                  color: item.typeColor, size: 18),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 13),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(item.church, style: AppTextStyles.cardSubtitle),
            const SizedBox(height: 7),
            Wrap(spacing: 7, runSpacing: 4, children: [
              CCBadge(text: item.duration,          color: AppColors.muted),
              CCBadge(text: '${item.views} views',  color: AppColors.muted),
              CCBadge(text: item.type,              color: item.typeColor),
            ]),
          ]),
        ),
      ]),
    );
  }
}
