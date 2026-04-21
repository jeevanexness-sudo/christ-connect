import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';
import '../../widgets/widgets.dart';

class MatrimonyScreen extends StatefulWidget {
  const MatrimonyScreen({super.key});

  @override
  State<MatrimonyScreen> createState() => _MatrimonyScreenState();
}

class _MatrimonyScreenState extends State<MatrimonyScreen> {
  late final List<MatrimonyProfile> _profiles = MockData.profiles;
  String _filter = 'All';
  static const _filters = ['All', 'Nearby', 'Same Denomination', 'Age 25–35'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(context)),
            SliverToBoxAdapter(child: _banner()),
            SliverToBoxAdapter(child: _filterRow()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: EdgeInsets.fromLTRB(
                      K.pad, i == 0 ? 0 : 14, K.pad, 0),
                  child: _ProfileCard(
                    profile: _profiles[i],
                    onSave: () => setState(
                        () => _profiles[i].isSaved = !_profiles[i].isSaved),
                  ),
                ),
                childCount: _profiles.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 14, K.pad, 18),
        child: Row(children: [
          if (Navigator.canPop(context)) ...[
            CCIconBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 14),
          ],
          const Icon(Icons.favorite_rounded,
              color: AppColors.pink, size: 22),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Matrimony', style: AppTextStyles.heading1),
            Text('Find your God-ordained partner',
                style: AppTextStyles.caption),
          ]),
        ]),
      );

  Widget _banner() => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 20),
        child: GradientCard(
          gradient: AppColors.pinkGradient,
          borderColor: AppColors.pink.withOpacity(0.2),
          radius: 18,
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(children: [
            Text('✦  FAITH-FIRST MATCHMAKING  ✦',
                style: AppTextStyles.overline.copyWith(
                    color: AppColors.white.withOpacity(0.45),
                    letterSpacing: 1.4)),
            const SizedBox(height: 10),
            Text(
              '"He who finds a wife finds what is good\n'
              'and receives favour from the Lord."',
              textAlign: TextAlign.center,
              style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text('Proverbs 18:22',
                style: AppTextStyles.badge
                    .copyWith(color: AppColors.pink, fontSize: 11)),
          ]),
        ),
      );

  Widget _filterRow() => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: K.pad),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final active = _filters[i] == _filter;
              return GestureDetector(
                onTap: () => setState(() => _filter = _filters[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.pink.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active
                          ? AppColors.pink.withOpacity(0.45)
                          : AppColors.border2,
                    ),
                  ),
                  child: Text(
                    _filters[i],
                    style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: active ? AppColors.pink : AppColors.muted),
                  ),
                ),
              );
            },
          ),
        ),
      );
}

// ─── Profile Card ─────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final MatrimonyProfile profile;
  final VoidCallback onSave;
  const _ProfileCard({required this.profile, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return CCCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Avatar
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.pinkGradient,
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.pink.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(profile.avatar,
                  style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pink)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Expanded(
                  child: Text('${profile.name}, ${profile.age}',
                      style: AppTextStyles.heading3.copyWith(fontSize: 16)),
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${profile.match}%',
                      style: AppTextStyles.bodyBold.copyWith(
                          color: AppColors.success, fontSize: 15)),
                  Text('match', style: AppTextStyles.overline),
                ]),
              ]),
              const SizedBox(height: 3),
              Text('${profile.location}  ·  ${profile.profession}',
                  style: AppTextStyles.cardSubtitle),
              const SizedBox(height: 8),
              CCBadge(text: profile.denomination, color: AppColors.pink),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Text(profile.bio,
            style: AppTextStyles.body2.copyWith(fontSize: 13),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 14),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 12),
        Row(children: [
          // Save
          GestureDetector(
            onTap: onSave,
            child: Container(
              width: 42, height: 38,
              decoration: BoxDecoration(
                color: profile.isSaved
                    ? AppColors.gold.withOpacity(0.12)
                    : AppColors.card2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: profile.isSaved ? AppColors.gold : AppColors.border2,
                ),
              ),
              child: Icon(
                profile.isSaved
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: profile.isSaved ? AppColors.gold : AppColors.muted,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: OutlineButton2(
                  label: 'View Profile',
                  onTap: () {},
                  width: double.infinity)),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.pink,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text('Connect',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.buttonSecondary
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}
