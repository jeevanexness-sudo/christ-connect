import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../data/mock_data.dart';
import '../../widgets/widgets.dart';

class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  int _line = 0;
  late final int _total;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _total = MockData.wayMakerLyrics.sections
        .fold(0, (s, sec) => s + sec.lines.length);
    _timer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      if (mounted) setState(() => _line = (_line + 1) % _total);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(context)),
            SliverToBoxAdapter(child: _artwork()),
            ..._lyrics(),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 14, K.pad, 20),
        child: Row(children: [
          CCIconBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(ctx),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(MockData.wayMakerLyrics.title,
                  style: AppTextStyles.heading2),
              Text(MockData.wayMakerLyrics.artist, style: AppTextStyles.caption),
            ]),
          ),
          const LiveBadge(),
        ]),
      );

  Widget _artwork() => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 26),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A1630), Color(0xFF1D2E60), Color(0xFF3D1A6E)
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.violet.withOpacity(0.25)),
          ),
          child: Stack(children: [
            Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.mic_rounded,
                    color: AppColors.gold.withOpacity(0.5), size: 52),
                const SizedBox(height: 8),
                Text('Karaoke Mode Active',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.white.withOpacity(0.4))),
              ]),
            ),
            Positioned(
              bottom: 14, left: 18, right: 18,
              child: Column(children: [
                CCProgressBar(
                    value: 0.35, height: 3, color: AppColors.violet),
                const SizedBox(height: 5),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text('2:10', style: AppTextStyles.overline),
                  Text('7:15', style: AppTextStyles.overline),
                ]),
              ]),
            ),
          ]),
        ),
      );

  List<Widget> _lyrics() {
    int counter = 0;
    return MockData.wayMakerLyrics.sections.map((sec) {
      final start = counter;
      counter += sec.lines.length;
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CCBadge(text: sec.label, color: AppColors.muted),
              const SizedBox(height: 12),
              ...List.generate(sec.lines.length, (i) {
                final idx = start + i;
                final active = idx == _line;
                return AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  style: active
                      ? AppTextStyles.heading3.copyWith(
                          color: AppColors.gold,
                          fontSize: 18,
                          height: 2.1,
                        )
                      : AppTextStyles.body1.copyWith(
                          color: AppColors.white.withOpacity(0.28),
                          fontSize: 14,
                          height: 2.0,
                        ),
                  child: Text(sec.lines[i]),
                );
              }),
            ],
          ),
        ),
      );
    }).toList();
  }
}
