import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../data/mock_data.dart';
import '../../models/app_models.dart';
import '../../widgets/widgets.dart';
import 'lyrics_screen.dart';

class WorshipScreen extends StatefulWidget {
  const WorshipScreen({super.key});

  @override
  State<WorshipScreen> createState() => _WorshipScreenState();
}

class _WorshipScreenState extends State<WorshipScreen> {
  late List<Song> _songs;
  Song? _active;
  bool _playing = false;
  String _filter = 'All';
  double _progress = 0.0;
  Timer? _timer;

  static const _cats = [
    'All', 'Hymns', 'Contemporary', 'Praise', 'Worship'
  ];

  @override
  void initState() {
    super.initState();
    _songs = MockData.songs;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<Song> get _filtered =>
      _filter == 'All' ? _songs : _songs.where((s) => s.category == _filter).toList();

  void _play(Song s) {
    _timer?.cancel();
    setState(() { _active = s; _playing = true; _progress = 0.0; });
    _timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (!mounted) return;
      setState(() {
        _progress = (_progress + 0.003).clamp(0.0, 1.0);
        if (_progress >= 1.0) { _playing = false; _timer?.cancel(); }
      });
    });
  }

  void _togglePlay() {
    setState(() => _playing = !_playing);
    if (_playing) {
      _timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
        if (!mounted) return;
        setState(() => _progress = (_progress + 0.003).clamp(0.0, 1.0));
      });
    } else {
      _timer?.cancel();
    }
  }

  String _elapsed() {
    if (_active == null) return '0:00';
    final parts = _active!.duration.split(':');
    final total = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final cur = (total * _progress).round();
    return '${cur ~/ 60}:${(cur % 60).toString().padLeft(2, '0')}';
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
            if (_active != null)
              SliverToBoxAdapter(child: _player(context)),
            SliverToBoxAdapter(child: _filters()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final s = _filtered[i];
                  return _SongRow(
                    song: s,
                    isActive: _active?.id == s.id,
                    isPlaying: _playing && _active?.id == s.id,
                    onTap: () => _play(s),
                    onLyrics: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const LyricsScreen())),
                  );
                },
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
        padding: const EdgeInsets.fromLTRB(K.pad, 14, K.pad, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Worship', style: AppTextStyles.heading1),
          Text('Sing, praise & worship together', style: AppTextStyles.caption),
        ]),
      );

  Widget _player(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 18),
        child: GradientCard(
          gradient: AppColors.playerGradient,
          borderColor: AppColors.gold.withOpacity(0.22),
          radius: 18,
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            // Song info
            Row(children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  gradient: AppColors.violetGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.music_note_rounded,
                    color: AppColors.gold, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_active!.title,
                      style: AppTextStyles.bodyBold,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(_active!.artist, style: AppTextStyles.cardSubtitle),
                ]),
              ),
              // Lyrics button
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LyricsScreen())),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.violet.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.violet.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.mic_rounded,
                        color: AppColors.violet, size: 14),
                    const SizedBox(width: 4),
                    Text('LYRICS',
                        style: AppTextStyles.badge
                            .copyWith(color: AppColors.violet)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            CCProgressBar(value: _progress, height: 3),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_elapsed(), style: AppTextStyles.overline),
              Text(_active!.duration, style: AppTextStyles.overline),
            ]),
            const SizedBox(height: 12),
            // Controls
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded,
                    color: AppColors.muted, size: 28),
                onPressed: () {},
              ),
              const SizedBox(width: 6),
              PlayButton(isPlaying: _playing, onTap: _togglePlay, size: 52),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded,
                    color: AppColors.muted, size: 28),
                onPressed: () {},
              ),
            ]),
          ]),
        ),
      );

  Widget _filters() => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: K.pad),
            itemCount: _cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => FilterPill(
              label: _cats[i],
              isActive: _cats[i] == _filter,
              onTap: () => setState(() => _filter = _cats[i]),
            ),
          ),
        ),
      );
}

// ─── Song Row ─────────────────────────────────────────────────────────────
class _SongRow extends StatelessWidget {
  final Song song;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onLyrics;

  const _SongRow({
    required this.song,
    required this.isActive,
    required this.isPlaying,
    required this.onTap,
    required this.onLyrics,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.gold.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: K.pad),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  gradient: isActive ? AppColors.violetGradient : null,
                  color: isActive ? null : AppColors.card2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive && isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: isActive ? AppColors.gold : AppColors.muted,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(song.title,
                      style: AppTextStyles.cardTitle.copyWith(
                          color: isActive ? AppColors.gold : AppColors.white),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${song.artist}  ·  ${song.duration}',
                      style: AppTextStyles.cardSubtitle),
                ]),
              ),
              CCBadge(text: 'Key ${song.key}', color: AppColors.violet),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onLyrics,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.mic_rounded,
                      color: AppColors.muted, size: 18),
                ),
              ),
            ]),
          ),
          const Divider(height: 1, color: AppColors.border),
        ]),
      ),
    );
  }
}
