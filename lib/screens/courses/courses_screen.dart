import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';
import '../../widgets/widgets.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final active  = MockData.courses.where((c) => c.isEnrolled).toList();
    final explore = MockData.courses.where((c) => !c.isEnrolled).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(context)),
            SliverToBoxAdapter(child: _statsRow()),
            _slab('Continue Learning'),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _pad(i, _CourseCard(course: active[i])),
                childCount: active.length,
              ),
            ),
            _slab('Explore Courses', top: 24),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _pad(i, _CourseCard(course: explore[i])),
                childCount: explore.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _slab(String t, {double top = 0}) =>
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(K.pad, top, K.pad, 14),
          child: SectionHeader(title: t),
        ),
      );

  Widget _pad(int i, Widget child) => Padding(
        padding: EdgeInsets.fromLTRB(K.pad, i == 0 ? 0 : 12, K.pad, 0),
        child: child,
      );

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
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Courses', style: AppTextStyles.heading1),
            Text('Grow in faith & knowledge', style: AppTextStyles.caption),
          ]),
        ]),
      );

  Widget _statsRow() => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 22),
        child: Row(children: [
          Expanded(child: _StatBox(n: '3 Active', l: 'Enrolled')),
          const SizedBox(width: 10),
          Expanded(child: _StatBox(n: '2 hrs', l: 'This week')),
        ]),
      );
}

class _StatBox extends StatelessWidget {
  final String n, l;
  const _StatBox({required this.n, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(n, style: AppTextStyles.goldHeading.copyWith(fontSize: 17)),
        const SizedBox(height: 3),
        Text(l, style: AppTextStyles.overline),
      ]),
    );
  }
}

// ─── Course Card ──────────────────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  final Course course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return CCCard(
      onTap: () {},
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 54, height: 54,
          decoration: BoxDecoration(
            color: course.catColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            course.isEnrolled ? Icons.school_rounded : Icons.menu_book_outlined,
            color: course.isEnrolled ? course.catColor : AppColors.muted,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(course.title,
                style: AppTextStyles.cardTitle,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(course.instructor, style: AppTextStyles.cardSubtitle),
            const SizedBox(height: 9),
            if (course.isEnrolled) ...[
              CCProgressBar(
                  value: course.progress / 100,
                  height: 5,
                  color: course.catColor),
              const SizedBox(height: 7),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                CCBadge(text: course.category, color: course.catColor),
                Text('${course.progress}% done',
                    style: AppTextStyles.goldLabel.copyWith(fontSize: 11)),
              ]),
            ] else ...[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Wrap(spacing: 7, children: [
                  CCBadge(text: course.category, color: course.catColor),
                  CCBadge(
                      text: '${course.lessons} lessons',
                      color: AppColors.muted),
                ]),
                GoldButton(
                  label: 'Enroll',
                  onTap: () {},
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                ),
              ]),
            ],
          ]),
        ),
      ]),
    );
  }
}
