import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';
import '../../widgets/widgets.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late final List<CommunityPost> _posts = MockData.posts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: Text('Post', style: AppTextStyles.buttonPrimary),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _stats()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: EdgeInsets.fromLTRB(
                      K.pad, i == 0 ? 0 : 12, K.pad, 0),
                  child: _PostCard(
                    post: _posts[i],
                    onLike: () => setState(
                        () => _posts[i].isLiked = !_posts[i].isLiked),
                    onPray: () => setState(
                        () => _posts[i].isPraying = !_posts[i].isPraying),
                  ),
                ),
                childCount: _posts.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 14, K.pad, 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Community', style: AppTextStyles.heading1),
          Text('Pray  ·  Share  ·  Encourage',
              style: AppTextStyles.caption),
        ]),
      );

  Widget _stats() => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 20),
        child: Row(children: [
          Expanded(child: StatCard(number: '1,248', label: 'Prayers')),
          const SizedBox(width: 10),
          Expanded(child: StatCard(number: '364', label: 'Testimonies')),
          const SizedBox(width: 10),
          Expanded(child: StatCard(number: '89', label: 'Churches')),
        ]),
      );
}

// ─── Post Card ────────────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onLike;
  final VoidCallback onPray;
  const _PostCard(
      {required this.post, required this.onLike, required this.onPray});

  @override
  Widget build(BuildContext context) {
    return CCCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Author row
        Row(children: [
          AvatarCircle(
              initials: post.avatar, size: 42, bgColor: post.avatarBg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(post.author, style: AppTextStyles.cardTitle),
                const SizedBox(width: 8),
                CCBadge(text: post.typeLabel, color: post.typeColor),
              ]),
              Text(post.timeAgo,
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 10)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Text(post.content,
            style: AppTextStyles.body1.copyWith(fontSize: 14)),
        const SizedBox(height: 14),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 12),
        // Actions
        Row(children: [
          _Btn(
            icon: post.isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: '${post.likes + (post.isLiked ? 1 : 0)}',
            color: post.isLiked ? AppColors.danger : AppColors.muted,
            onTap: onLike,
          ),
          const SizedBox(width: 18),
          _Btn(
            icon: Icons.chat_bubble_outline_rounded,
            label: '${post.comments}',
            color: AppColors.muted,
            onTap: () {},
          ),
          const SizedBox(width: 18),
          _Btn(
            icon: Icons.volunteer_activism_outlined,
            label: post.isPraying ? 'Praying' : 'Pray',
            color: post.isPraying ? AppColors.blue : AppColors.muted,
            onTap: onPray,
          ),
        ]),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Btn(
      {required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 5),
        Text(label,
            style: AppTextStyles.caption.copyWith(
                color: color, fontSize: 12)),
      ]),
    );
  }
}
