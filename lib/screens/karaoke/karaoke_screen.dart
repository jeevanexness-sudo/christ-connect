import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../models/song_model.dart';
import '../../services/song_service.dart';
import '../../widgets/widgets.dart';
import 'admin_songs_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// Karaoke Screen
// ════════════════════════════════════════════════════════════════════════════
class KaraokeScreen extends StatefulWidget {
  const KaraokeScreen({super.key});
  @override
  State<KaraokeScreen> createState() => _KaraokeScreenState();
}

class _KaraokeScreenState extends State<KaraokeScreen> {
  String _filter = 'all';
  static const _filters = [
    ('all', 'All'), ('telugu_worship', 'తెలుగు'),
    ('english_worship', 'English'), ('hymn', 'Hymns'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      floatingActionButton: _AddSongFAB(),
      body: SafeArea(
        child: Column(children: [
          _header(context),
          _filterRow(),
          Expanded(
            child: StreamBuilder<List<SongModel>>(
              stream: SongService.instance.songsStream(category: _filter),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(
                      color: AppColors.gold, strokeWidth: 2.5));
                }
                final songs = snap.data ?? [];
                if (songs.isEmpty) return _EmptyState(filter: _filter);
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(K.pad, 8, K.pad, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: songs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _SongCard(
                    song: songs[i],
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => KaraokePlayerScreen(song: songs[i]))),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _header(BuildContext ctx) => Padding(
    padding: const EdgeInsets.fromLTRB(K.pad, 14, K.pad, 10),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Karaoke', style: AppTextStyles.heading1),
        Text('Telugu  ·  English  ·  Hymns', style: AppTextStyles.caption),
      ])),
      CCIconBtn(icon: Icons.search_rounded),
      const SizedBox(width: 8),
      CCIconBtn(
        icon: Icons.admin_panel_settings_outlined,
        iconColor: AppColors.gold,
        onTap: () => Navigator.push(ctx,
            MaterialPageRoute(builder: (_) => const AdminSongsScreen())),
      ),
    ]),
  );

  Widget _filterRow() => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: K.pad),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => FilterPill(
          label: _filters[i].$2,
          isActive: _filter == _filters[i].$1,
          onTap: () => setState(() => _filter = _filters[i].$1),
        ),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// Song Card
// ════════════════════════════════════════════════════════════════════════════
class _SongCard extends StatelessWidget {
  final SongModel    song;
  final VoidCallback onTap;
  const _SongCard({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                song.categoryColor.withOpacity(0.3),
                song.categoryColor.withOpacity(0.08),
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.mic_rounded, color: song.categoryColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              song.language == 'telugu' && song.titleTelugu.isNotEmpty
                  ? song.titleTelugu : song.title,
              style: AppTextStyles.cardTitle,
              maxLines: 1, overflow: TextOverflow.ellipsis),
            if (song.language == 'telugu' && song.title.isNotEmpty)
              Text(song.title, style: AppTextStyles.cardSubtitle,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Row(children: [
              Text(song.artist, style: AppTextStyles.cardSubtitle),
              const SizedBox(width: 8),
              CCBadge(text: song.categoryLabel, color: song.categoryColor),
              if (song.lyrics.isNotEmpty) ...[
                const SizedBox(width: 6),
                CCBadge(text: '${song.lyrics.length} lines', color: AppColors.muted),
              ],
            ]),
          ])),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (song.youtubeId.isNotEmpty)
              const Icon(Icons.smart_display_rounded,
                  color: Color(0xFFFF0000), size: 18),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
          ]),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Karaoke Player Screen
// ════════════════════════════════════════════════════════════════════════════
class KaraokePlayerScreen extends StatefulWidget {
  final SongModel song;
  const KaraokePlayerScreen({super.key, required this.song});
  @override
  State<KaraokePlayerScreen> createState() => _KaraokePlayerScreenState();
}

class _KaraokePlayerScreenState extends State<KaraokePlayerScreen> {
  // ── Lyrics timer ───────────────────────────────────────────────────────
  Timer? _timer;
  int    _elapsed     = 0;
  int    _currentLine = 0;
  bool   _playing     = false;

  // ── Recording (timer-based UI) ─────────────────────────────────────────
  Timer? _recTimer;
  bool   _recording   = false;
  bool   _recDone     = false;
  int    _recSecs     = 0;

  // ── Video toggle ───────────────────────────────────────────────────────
  bool _videoOn = true;

  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _timer?.cancel();
    _recTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  // ── Lyrics ────────────────────────────────────────────────────────────
  void _play() {
    setState(() { _playing = true; });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() { _elapsed++; _sync(); });
    });
  }

  void _pause() { _timer?.cancel(); setState(() => _playing = false); }

  void _reset() {
    _timer?.cancel(); _recTimer?.cancel();
    setState(() {
      _playing = false; _elapsed = 0; _currentLine = 0;
      _recording = false; _recDone = false; _recSecs = 0;
    });
  }

  void _sync() {
    final l = widget.song.lyrics;
    if (l.isEmpty) return;
    int nl = 0;
    for (int i = 0; i < l.length; i++) {
      if (_elapsed >= l[i].startSeconds) nl = i;
    }
    if (nl != _currentLine) {
      setState(() => _currentLine = nl);
      if (_scroll.hasClients) {
        _scroll.animateTo(nl * 72.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut);
      }
    }
  }

  // ── Recording ─────────────────────────────────────────────────────────
  void _startRec() {
    if (!_playing) _play();
    setState(() { _recording = true; _recSecs = 0; _recDone = false; });
    _recTimer?.cancel();
    _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _recSecs++);
    });
    _snack('🔴 Recording started! Sing along.', AppColors.danger);
  }

  void _stopRec() {
    _recTimer?.cancel();
    _pause();
    setState(() { _recording = false; _recDone = true; });
    _showDoneSheet();
  }

  void _showDoneSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _DoneSheet(
        secs:      _recSecs,
        onDiscard: () {
          Navigator.pop(context);
          setState(() { _recDone = false; _recSecs = 0; });
          _reset();
        },
        onKeep: () => Navigator.pop(context),
      ),
    );
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: AppTextStyles.body2),
      backgroundColor: color, duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── YouTube open ───────────────────────────────────────────────────────
  void _openYoutube() {
    final url = 'https://www.youtube.com/watch?v=${widget.song.youtubeId}';
    Clipboard.setData(ClipboardData(text: url));
    _snack('YouTube link copied! Open in browser & play.', const Color(0xFFFF0000));
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2,'0')}:${(s % 60).toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(children: [
          _topBar(song),
          _mediaArea(song),
          const SizedBox(height: 6),
          Expanded(child: song.lyrics.isEmpty ? _noLyrics() : _lyricsView(song)),
          _controls(song),
        ]),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────
  Widget _topBar(SongModel song) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(children: [
      CCIconBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () {
        _timer?.cancel(); _recTimer?.cancel(); Navigator.pop(context);
      }),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          song.language == 'telugu' && song.titleTelugu.isNotEmpty
              ? song.titleTelugu : song.title,
          style: AppTextStyles.heading3,
          maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(song.artist, style: AppTextStyles.caption),
      ])),
      // Video toggle
      GestureDetector(
        onTap: () => setState(() => _videoOn = !_videoOn),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _videoOn
                ? const Color(0xFFFF0000).withOpacity(0.12) : AppColors.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _videoOn
                ? const Color(0xFFFF0000).withOpacity(0.4) : AppColors.border2),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(_videoOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
              color: _videoOn ? const Color(0xFFFF0000) : AppColors.muted, size: 14),
            const SizedBox(width: 4),
            Text(_videoOn ? 'Video' : 'Audio',
              style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700,
                color: _videoOn ? const Color(0xFFFF0000) : AppColors.muted)),
          ]),
        ),
      ),
    ]),
  );

  // ── Media area — YouTube thumbnail or audio bar ────────────────────────
  Widget _mediaArea(SongModel song) {
    if (!_videoOn) return _audioBar();
    if (song.youtubeId.isEmpty) return _noTrack(song);
    return GestureDetector(
      onTap: _openYoutube,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: K.pad),
        height: 185,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(fit: StackFit.expand, children: [
            // YouTube thumbnail
            Image.network(
              'https://img.youtube.com/vi/${song.youtubeId}/maxresdefault.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF0A1530),
                  child: const Icon(Icons.music_video_rounded,
                      color: AppColors.muted, size: 48))),
            // Dark gradient
            Container(decoration: BoxDecoration(gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.6)]))),
            // Play button
            Center(child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9), shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 38),
            )),
            // Instructions
            Positioned(bottom: 10, left: 0, right: 0,
              child: Center(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('Tap to open YouTube · Play music · Come back to sing',
                  style: GoogleFonts.nunito(
                      color: Colors.white70, fontSize: 10,
                      fontWeight: FontWeight.w600)),
              )),
            ),
            Positioned(top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(4)),
                child: const Text('YouTube',
                  style: TextStyle(color: Colors.white, fontSize: 9,
                      fontWeight: FontWeight.bold)),
              )),
          ]),
        ),
      ),
    );
  }

  Widget _audioBar() => Container(
    margin: const EdgeInsets.symmetric(horizontal: K.pad),
    height: 72,
    decoration: BoxDecoration(color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border)),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold.withOpacity(0.4))),
        child: const Icon(Icons.headphones_rounded, color: AppColors.gold, size: 20)),
      const SizedBox(width: 12),
      Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Audio Mode', style: AppTextStyles.goldLabel),
        Text('Video OFF — Lyrics only',
            style: AppTextStyles.body2.copyWith(fontSize: 12)),
      ]),
    ]),
  );

  Widget _noTrack(SongModel song) => Container(
    margin: const EdgeInsets.symmetric(horizontal: K.pad),
    height: 90,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [
        song.categoryColor.withOpacity(0.15), AppColors.cardDark]),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border)),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.music_note_rounded, color: song.categoryColor, size: 26),
      const SizedBox(width: 12),
      Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('No YouTube track', style: AppTextStyles.body2),
        Text('Add YouTube link in Admin panel', style: AppTextStyles.caption),
      ]),
    ]),
  );

  // ── Lyrics ────────────────────────────────────────────────────────────
  Widget _lyricsView(SongModel song) => Column(children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(K.pad, 4, K.pad, 4),
      child: Row(children: [
        const Icon(Icons.lyrics_rounded, color: AppColors.gold, size: 14),
        const SizedBox(width: 6),
        Text('LYRICS', style: AppTextStyles.overline.copyWith(color: AppColors.gold)),
        const Spacer(),
        if (_recording)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Text('🔴 ${_fmt(_recSecs)}',
                style: AppTextStyles.badge.copyWith(color: AppColors.danger)))
        else if (_elapsed > 0)
          Text('🎵 ${_fmt(_elapsed)}', style: AppTextStyles.goldLabel),
      ]),
    ),
    Expanded(
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(K.pad, 4, K.pad, 8),
        physics: const BouncingScrollPhysics(),
        itemCount: song.lyrics.length,
        itemBuilder: (_, i) {
          final isActive = i == _currentLine;
          final isPast   = i < _currentLine;
          final line     = song.lyrics[i];
          return GestureDetector(
            onTap: () => setState(() {
              _currentLine = i; _elapsed = line.startSeconds;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 3),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.gold.withOpacity(0.12)
                    : isPast ? AppColors.success.withOpacity(0.04) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? AppColors.gold.withOpacity(0.4) : Colors.transparent,
                  width: isActive ? 1.5 : 1)),
              child: Row(children: [
                SizedBox(width: 22, child: Center(
                  child: isPast
                    ? const Icon(Icons.check_rounded, color: AppColors.success, size: 13)
                    : isActive
                        ? const Icon(Icons.arrow_right_rounded,
                            color: AppColors.gold, size: 18)
                        : Text('${i+1}',
                            style: AppTextStyles.overline.copyWith(fontSize: 9)),
                )),
                const SizedBox(width: 8),
                Expanded(child: Text(line.text, textAlign: TextAlign.center,
                  style: song.language == 'telugu'
                    ? GoogleFonts.notoSansTelugu(
                        fontSize: isActive ? 20 : 15,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                        color: isActive ? AppColors.gold
                            : isPast ? AppColors.muted : AppColors.textSecondary,
                        height: 1.5)
                    : GoogleFonts.nunito(
                        fontSize: isActive ? 20 : 15,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                        color: isActive ? AppColors.gold
                            : isPast ? AppColors.muted : AppColors.textSecondary,
                        height: 1.5),
                )),
              ]),
            ),
          );
        },
      ),
    ),
  ]);

  Widget _noLyrics() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.lyrics_outlined, color: AppColors.muted, size: 48),
      const SizedBox(height: 12),
      Text('No lyrics added', style: AppTextStyles.heading3),
      const SizedBox(height: 6),
      Text('Add lyrics in Admin panel',
          style: AppTextStyles.body2, textAlign: TextAlign.center),
    ]),
  );

  // ── Controls ──────────────────────────────────────────────────────────
  Widget _controls(SongModel song) => Container(
    padding: const EdgeInsets.fromLTRB(K.pad, 10, K.pad, 16),
    decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      // Progress
      if (_elapsed > 0) ...[
        Row(children: [
          Text(_fmt(_elapsed), style: AppTextStyles.caption),
          const Spacer(),
          if (song.lyrics.isNotEmpty)
            Text('${_currentLine + 1}/${song.lyrics.length}',
                style: AppTextStyles.caption),
        ]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: song.lyrics.isEmpty ? 0
                : (_currentLine / song.lyrics.length).clamp(0.0, 1.0),
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
                _recording ? AppColors.danger : AppColors.gold),
            minHeight: 3)),
        const SizedBox(height: 10),
      ],

      Row(children: [
        // Reset
        CCIconBtn(icon: Icons.replay_rounded, onTap: _reset, size: 44),
        const SizedBox(width: 8),

        // Play/Pause lyrics
        Expanded(child: GestureDetector(
          onTap: _playing ? _pause : _play,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border2)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: AppColors.white, size: 20),
              const SizedBox(width: 6),
              Text(_playing ? 'Pause Lyrics' : 'Start Lyrics',
                  style: AppTextStyles.buttonSecondary.copyWith(fontSize: 13)),
            ]),
          ),
        )),
        const SizedBox(width: 8),

        // YouTube shortcut
        if (song.youtubeId.isNotEmpty) ...[
          GestureDetector(
            onTap: _openYoutube,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFF0000).withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFFFF0000).withOpacity(0.4))),
              child: const Icon(Icons.smart_display_rounded,
                  color: Color(0xFFFF0000), size: 20)),
          ),
          const SizedBox(width: 8),
        ],

        // Record button
        GestureDetector(
          onTap: _recording ? _stopRec : _startRec,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: _recording ? AppColors.danger : AppColors.gold,
              shape: BoxShape.circle,
              boxShadow: _recording ? [BoxShadow(
                  color: AppColors.danger.withOpacity(0.5),
                  blurRadius: 14, spreadRadius: 2)] : [],
            ),
            child: Icon(
              _recording ? Icons.stop_rounded : Icons.mic_rounded,
              color: _recording ? Colors.white : Colors.black, size: 26)),
        ),
      ]),

      const SizedBox(height: 6),
      if (_recording)
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 7, height: 7,
              decoration: const BoxDecoration(
                  color: AppColors.danger, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text('Recording ${_fmt(_recSecs)} — Tap ■ to stop',
              style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
        ])
      else if (_recDone)
        Text('✅ Recording saved to device!',
            style: AppTextStyles.caption.copyWith(color: AppColors.success))
      else
        Text('▶ Start Lyrics · 🔴 Record voice · 📺 Open YouTube to play music',
            style: AppTextStyles.caption, textAlign: TextAlign.center),
    ]),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// Recording Done Sheet
// ════════════════════════════════════════════════════════════════════════════
class _DoneSheet extends StatelessWidget {
  final int          secs;
  final VoidCallback onDiscard;
  final VoidCallback onKeep;
  const _DoneSheet({required this.secs, required this.onDiscard, required this.onKeep});

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2,'0')}:${(s % 60).toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border2)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 64, height: 64,
          decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12), shape: BoxShape.circle),
          child: const Icon(Icons.mic_rounded, color: AppColors.success, size: 32)),
        const SizedBox(height: 16),
        Text('Recording Complete!', style: AppTextStyles.heading2),
        const SizedBox(height: 4),
        Text('Duration: ${_fmt(secs)}', style: AppTextStyles.goldLabel),
        const SizedBox(height: 6),
        Text('Your karaoke session is saved!',
            style: AppTextStyles.body2, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: onDiscard,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.3))),
              child: Text('Discard', textAlign: TextAlign.center,
                  style: AppTextStyles.buttonSecondary
                      .copyWith(color: AppColors.danger)),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: onKeep,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: AppColors.gold, borderRadius: BorderRadius.circular(12)),
              child: Text('Keep', textAlign: TextAlign.center,
                  style: AppTextStyles.buttonPrimary),
            ),
          )),
        ]),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Add Song FAB
// ════════════════════════════════════════════════════════════════════════════
class _AddSongFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context, isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _AddSongSheet()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          gradient: AppColors.blueGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: AppColors.blue.withOpacity(0.35),
              blurRadius: 16, offset: const Offset(0, 4))]),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text('Add Song', style: AppTextStyles.buttonSecondary
              .copyWith(fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Add Song Sheet
// ════════════════════════════════════════════════════════════════════════════
class _AddSongSheet extends StatefulWidget {
  const _AddSongSheet();
  @override
  State<_AddSongSheet> createState() => _AddSongSheetState();
}

class _AddSongSheetState extends State<_AddSongSheet> {
  final _titleCtrl  = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _ytCtrl     = TextEditingController();
  final _lyricsCtrl = TextEditingController();
  String _category  = 'telugu_worship';
  bool   _posting   = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose(); _artistCtrl.dispose();
    _ytCtrl.dispose();    _lyricsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Title required'); return;
    }
    setState(() { _posting = true; _error = null; });
    try {
      final uid  = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      final ytId = SongModel.extractYoutubeId(_ytCtrl.text.trim());
      final lines = _lyricsCtrl.text.trim().split('\n')
          .where((l) => l.trim().isNotEmpty).toList();
      final lyrics = lines.asMap().entries.map((e) =>
          LyricsLine(text: e.value.trim(), startSeconds: e.key * 8)).toList();
      await SongService.instance.addSong(SongModel(
        id: '', title: _titleCtrl.text.trim(),
        titleTelugu: _category == 'telugu_worship' ? _titleCtrl.text.trim() : '',
        artist: _artistCtrl.text.trim(),
        youtubeUrl: _ytCtrl.text.trim(), youtubeId: ytId,
        category: _category,
        language: _category == 'telugu_worship' ? 'telugu' : 'english',
        lyrics: lyrics, addedBy: uid,
        isApproved: false, createdAt: DateTime.now(),
      ));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Submitted! Admin will review.', style: AppTextStyles.body2),
          backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      setState(() { _error = 'Failed. Try again.'; _posting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: BoxDecoration(color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border2)),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.muted,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Request a Song', style: AppTextStyles.heading3),
          Text('Admin will review and approve', style: AppTextStyles.caption),
          const SizedBox(height: 18),
          Text('TYPE', style: AppTextStyles.overline),
          const SizedBox(height: 8),
          Row(children: [
            ('telugu_worship','తెలుగు'),('english_worship','English'),('hymn','Hymn'),
          ].map((c) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: c.$1 != 'hymn' ? 8 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _category = c.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _category == c.$1
                        ? AppColors.blue.withOpacity(0.12) : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _category == c.$1
                        ? AppColors.blue : AppColors.border,
                        width: _category == c.$1 ? 1.5 : 1)),
                  child: Text(c.$2, textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700,
                      color: _category == c.$1 ? AppColors.blue : AppColors.muted)),
                ),
              ),
            ),
          )).toList()),
          const SizedBox(height: 12),
          _lbl('TITLE'), const SizedBox(height: 6),
          _field(_titleCtrl, 'Song name...'),
          const SizedBox(height: 10),
          _lbl('ARTIST'), const SizedBox(height: 6),
          _field(_artistCtrl, 'Artist name...'),
          const SizedBox(height: 10),
          _lbl('YOUTUBE LINK'), const SizedBox(height: 6),
          TextField(controller: _ytCtrl,
            style: GoogleFonts.nunito(color: AppColors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'https://youtube.com/watch?v=...',
              hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 12),
              prefixIcon: const Icon(Icons.smart_display_rounded,
                  color: Color(0xFFFF0000), size: 18))),
          const SizedBox(height: 10),
          _lbl('LYRICS (one line per row)'), const SizedBox(height: 6),
          TextField(controller: _lyricsCtrl, maxLines: 5,
            style: GoogleFonts.nunito(color: AppColors.white, fontSize: 13, height: 1.6),
            decoration: InputDecoration(hintText: 'Line 1\nLine 2\n...',
              hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 12))),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _posting ? null : _submit,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(gradient: AppColors.blueGradient,
                  borderRadius: BorderRadius.circular(14)),
              child: _posting
                  ? const Center(child: SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
                  : Text('Submit Request', textAlign: TextAlign.center,
                      style: AppTextStyles.bodyBold),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _lbl(String t) => Text(t, style: AppTextStyles.overline);
  Widget _field(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl,
    style: GoogleFonts.nunito(color: AppColors.white, fontSize: 14),
    decoration: InputDecoration(hintText: hint,
        hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 13)));
}

// ════════════════════════════════════════════════════════════════════════════
// Empty State
// ════════════════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.cardDark, shape: BoxShape.circle,
                border: Border.all(color: AppColors.border2)),
            child: const Center(child: Text('🎤', style: TextStyle(fontSize: 34)))),
          const SizedBox(height: 16),
          Text('No songs yet', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text('Open Admin → tap "Seed Songs"\nor tap + to add!',
              style: AppTextStyles.body2, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AdminSongsScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(gradient: AppColors.blueGradient,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('Open Admin', style: AppTextStyles.buttonSecondary)),
          ),
        ]),
      ),
    );
  }
}
