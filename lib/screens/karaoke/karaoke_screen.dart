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

// ════════════════════════════════════════════════════════════════════════════
// Karaoke Screen
// ════════════════════════════════════════════════════════════════════════════
class KaraokeScreen extends StatefulWidget {
  const KaraokeScreen({super.key});

  @override
  State<KaraokeScreen> createState() => _KaraokeScreenState();
}

class _KaraokeScreenState extends State<KaraokeScreen> {
  String _filter   = 'all';
  SongModel? _playing;

  static const _filters = [
    ('all',             'All'),
    ('telugu_worship',  'తెలుగు'),
    ('english_worship', 'English'),
    ('hymn',            'Hymns'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      floatingActionButton: _AddSongFAB(),
      body: SafeArea(
        child: Column(children: [
          _buildHeader(context),
          _buildFilters(),
          // Now playing bar
          if (_playing != null) _NowPlayingBar(
            song: _playing!,
            onTap: () => _openPlayer(context, _playing!),
            onClose: () => setState(() => _playing = null),
          ),
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
                    song:      songs[i],
                    isPlaying: _playing?.id == songs[i].id,
                    onTap: () {
                      setState(() => _playing = songs[i]);
                      _openPlayer(context, songs[i]);
                    },
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(K.pad, 14, K.pad, 10),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Karaoke', style: AppTextStyles.heading1),
          Text('Telugu  ·  English  ·  Hymns', style: AppTextStyles.caption),
        ])),
        CCIconBtn(icon: Icons.search_rounded),
        const SizedBox(width: 8),
        // Admin button
        CCIconBtn(
          icon: Icons.admin_panel_settings_outlined,
          iconColor: AppColors.gold,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminSongsScreen())),
        ),
      ]),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: K.pad),
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => FilterPill(
            label:    _filters[i].$2,
            isActive: _filter == _filters[i].$1,
            onTap:    () => setState(() => _filter = _filters[i].$1),
          ),
        ),
      ),
    );
  }

  void _openPlayer(BuildContext context, SongModel song) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _PlayerScreen(song: song)));
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Song Card
// ════════════════════════════════════════════════════════════════════════════
class _SongCard extends StatelessWidget {
  final SongModel song;
  final bool      isPlaying;
  final VoidCallback onTap;
  const _SongCard({required this.song, required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isPlaying
              ? AppColors.gold.withOpacity(0.08)
              : AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPlaying ? AppColors.gold.withOpacity(0.4) : AppColors.border,
            width: isPlaying ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          // Thumbnail
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  song.categoryColor.withOpacity(0.3),
                  song.categoryColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(alignment: Alignment.center, children: [
              Icon(
                isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
                color: isPlaying ? AppColors.gold : song.categoryColor,
                size: 34,
              ),
            ]),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              song.language == 'telugu' ? song.titleTelugu : song.title,
              style: AppTextStyles.cardTitle.copyWith(
                color: isPlaying ? AppColors.gold : AppColors.white,
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            if (song.language == 'telugu' && song.title.isNotEmpty)
              Text(song.title,
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 10),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(children: [
              Text(song.artist,
                style: AppTextStyles.cardSubtitle),
              const SizedBox(width: 8),
              CCBadge(text: song.categoryLabel, color: song.categoryColor),
            ]),
            if (song.lyrics.isNotEmpty) ...[
              const SizedBox(height: 4),
              CCBadge(text: '${song.lyrics.length} lyrics lines', color: AppColors.muted),
            ],
          ])),
          // YouTube icon
          if (song.youtubeId.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF0000).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_display_rounded,
                  color: Color(0xFFFF0000), size: 20),
            ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Now Playing Bar
// ════════════════════════════════════════════════════════════════════════════
class _NowPlayingBar extends StatelessWidget {
  final SongModel    song;
  final VoidCallback onTap;
  final VoidCallback onClose;
  const _NowPlayingBar({required this.song, required this.onTap, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppColors.blueGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          const Icon(Icons.music_note_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(
            song.language == 'telugu' ? song.titleTelugu : song.title,
            style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          )),
          const Text('▶ Open', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Player Screen — YouTube + Lyrics
// ════════════════════════════════════════════════════════════════════════════
class _PlayerScreen extends StatefulWidget {
  final SongModel song;
  const _PlayerScreen({required this.song});

  @override
  State<_PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<_PlayerScreen> {
  bool _videoOn      = true;
  bool _isPlaying    = false;
  int  _currentLine  = 0;
  int  _elapsed      = 0;

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(children: [
          // ── Top bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              CCIconBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  song.language == 'telugu' ? song.titleTelugu : song.title,
                  style: AppTextStyles.heading3,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text(song.artist, style: AppTextStyles.caption),
              ])),
              // Video toggle
              GestureDetector(
                onTap: () => setState(() => _videoOn = !_videoOn),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _videoOn
                        ? const Color(0xFFFF0000).withOpacity(0.12)
                        : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _videoOn
                          ? const Color(0xFFFF0000).withOpacity(0.4)
                          : AppColors.border2,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      _videoOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                      color: _videoOn ? const Color(0xFFFF0000) : AppColors.muted,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _videoOn ? 'Video ON' : 'Video OFF',
                      style: GoogleFonts.nunito(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: _videoOn ? const Color(0xFFFF0000) : AppColors.muted,
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 12),

          // ── YouTube video area ─────────────────────────────────────────
          if (_videoOn && song.youtubeId.isNotEmpty)
            _YouTubeEmbed(youtubeId: song.youtubeId)
          else if (_videoOn)
            _NoVideoPlaceholder(song: song)
          else
            _AudioOnlyView(song: song),

          const SizedBox(height: 16),

          // ── Lyrics ─────────────────────────────────────────────────────
          Expanded(
            child: song.lyrics.isEmpty
                ? _NoLyrics()
                : _LyricsView(
                    lyrics:      song.lyrics,
                    currentLine: _currentLine,
                    language:    song.language,
                  ),
          ),

          // ── Bottom actions ─────────────────────────────────────────────
          _BottomActions(song: song),
        ]),
      ),
    );
  }
}

// ── YouTube Embed (WebView alternative using URL launch) ──────────────────
class _YouTubeEmbed extends StatelessWidget {
  final String youtubeId;
  const _YouTubeEmbed({required this.youtubeId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: K.pad),
      height: 200,
      decoration: BoxDecoration(
        color:        Colors.black,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(alignment: Alignment.center, children: [
          // Thumbnail
          Image.network(
            'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg',
            width:  double.infinity,
            height: double.infinity,
            fit:    BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF0A1530),
              child: const Icon(Icons.music_video_rounded,
                  color: AppColors.muted, size: 48),
            ),
          ),
          // Play overlay
          GestureDetector(
            onTap: () => _launchYouTube(youtubeId),
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color:  Colors.red.withOpacity(0.9),
                shape:  BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 36),
            ),
          ),
          // YouTube badge
          Positioned(
            bottom: 8, right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:        Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('YouTube',
                style: TextStyle(color: Colors.white,
                    fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
          // Tap to open label
          Positioned(
            top: 8, left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:        Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Tap to open in YouTube',
                style: TextStyle(color: Colors.white70, fontSize: 10)),
            ),
          ),
        ]),
      ),
    );
  }

  void _launchYouTube(String id) {
    // Opens YouTube app or browser
    final url = 'https://www.youtube.com/watch?v=$id';
    // Using clipboard as fallback since url_launcher not added
    Clipboard.setData(ClipboardData(text: url));
  }
}

// ── No Video Placeholder ──────────────────────────────────────────────────
class _NoVideoPlaceholder extends StatelessWidget {
  final SongModel song;
  const _NoVideoPlaceholder({required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: K.pad),
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [song.categoryColor.withOpacity(0.2), AppColors.cardDark],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border2),
      ),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.link_off_rounded, color: AppColors.muted, size: 32),
        const SizedBox(height: 8),
        Text('No YouTube link added', style: AppTextStyles.body2),
        Text('Add YouTube URL in Admin panel',
          style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ])),
    );
  }
}

// ── Audio Only View ───────────────────────────────────────────────────────
class _AudioOnlyView extends StatelessWidget {
  final SongModel song;
  const _AudioOnlyView({required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: K.pad),
      height: 120,
      decoration: BoxDecoration(
        gradient: AppColors.playerGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold.withOpacity(0.4)),
          ),
          child: const Icon(Icons.music_note_rounded, color: AppColors.gold, size: 28),
        ),
        const SizedBox(width: 16),
        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Video OFF', style: AppTextStyles.caption),
          Text('Lyrics Mode', style: AppTextStyles.bodyBold.copyWith(color: AppColors.gold)),
          Text('Sing along below', style: AppTextStyles.caption),
        ]),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Lyrics View
// ════════════════════════════════════════════════════════════════════════════
class _LyricsView extends StatelessWidget {
  final List<LyricsLine> lyrics;
  final int              currentLine;
  final String           language;
  const _LyricsView({
    required this.lyrics,
    required this.currentLine,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(K.pad, 8, K.pad, 16),
      physics: const BouncingScrollPhysics(),
      itemCount: lyrics.length,
      itemBuilder: (_, i) {
        final isActive = i == currentLine;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.gold.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? AppColors.gold.withOpacity(0.4)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            lyrics[i].text,
            textAlign: TextAlign.center,
            style: language == 'telugu'
                ? GoogleFonts.notoSansTelugu(
                    fontSize:   isActive ? 20 : 16,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color:      isActive ? AppColors.gold : AppColors.textSecondary,
                    height:     1.5,
                  )
                : GoogleFonts.nunito(
                    fontSize:   isActive ? 20 : 16,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color:      isActive ? AppColors.gold : AppColors.textSecondary,
                    height:     1.5,
                  ),
          ),
        );
      },
    );
  }
}

class _NoLyrics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.lyrics_outlined, color: AppColors.muted, size: 52),
          const SizedBox(height: 12),
          Text('No lyrics added', style: AppTextStyles.heading3),
          const SizedBox(height: 6),
          Text('Admin can add lyrics in the Admin panel',
            style: AppTextStyles.body2, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Bottom Actions
// ════════════════════════════════════════════════════════════════════════════
class _BottomActions extends StatelessWidget {
  final SongModel song;
  const _BottomActions({required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(K.pad, 10, K.pad, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        // Open in YouTube
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (song.youtubeUrl.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: song.youtubeUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('YouTube URL copied! Paste in browser.',
                        style: AppTextStyles.body2),
                    backgroundColor: const Color(0xFFFF0000),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFFF0000).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFF0000).withOpacity(0.3)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.smart_display_rounded,
                    color: Color(0xFFFF0000), size: 18),
                const SizedBox(width: 6),
                Text('Open YouTube',
                    style: AppTextStyles.buttonSecondary
                        .copyWith(color: const Color(0xFFFF0000), fontSize: 13)),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Share
        CCIconBtn(icon: Icons.share_rounded, size: 46),
        const SizedBox(width: 10),
        // Favorite
        CCIconBtn(icon: Icons.favorite_border_rounded,
            iconColor: AppColors.pink, size: 46),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Add Song FAB — User request
// ════════════════════════════════════════════════════════════════════════════
class _AddSongFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          gradient: AppColors.blueGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(
            color: AppColors.blue.withOpacity(0.35),
            blurRadius: 16, offset: const Offset(0, 4),
          )],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text('Add Song', style: AppTextStyles.buttonSecondary
              .copyWith(fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  void _showAddSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddSongSheet(),
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
  final _titleCtrl    = TextEditingController();
  final _artistCtrl   = TextEditingController();
  final _ytCtrl       = TextEditingController();
  final _lyricsCtrl   = TextEditingController();
  String  _category   = 'telugu_worship';
  bool    _submitting = false;
  String? _error;

  static const _cats = [
    ('telugu_worship',  'తెలుగు Worship'),
    ('english_worship', 'English Worship'),
    ('hymn',            'Hymn'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose(); _artistCtrl.dispose();
    _ytCtrl.dispose();    _lyricsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Song title required'); return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      final uid  = FirebaseAuth.instance.currentUser?.uid ?? '';
      final ytId = extractYouTubeId(_ytCtrl.text.trim());
      // Parse lyrics (each line = one lyric)
      final lines = _lyricsCtrl.text.trim().split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();
      final lyrics = lines.asMap().entries.map((e) =>
          LyricsLine(text: e.value.trim(), startSeconds: e.key * 10)).toList();

      final song = SongModel(
        id:          '',
        title:       _titleCtrl.text.trim(),
        titleTelugu: _category == 'telugu_worship' ? _titleCtrl.text.trim() : '',
        artist:      _artistCtrl.text.trim(),
        youtubeUrl:  _ytCtrl.text.trim(),
        youtubeId:   ytId,
        category:    _category,
        language:    _category == 'telugu_worship' ? 'telugu' : 'english',
        lyrics:      lyrics,
        addedBy:     uid,
        isApproved:  false, // needs admin approval
        createdAt:   DateTime.now(),
      );
      await SongService.instance.addSong(song);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Song submitted! Waiting for admin approval.',
              style: AppTextStyles.body2),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      setState(() { _error = 'Failed. Try again.'; _submitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border2),
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Add Song Request', style: AppTextStyles.heading3),
          Text('Admin will review and approve', style: AppTextStyles.caption),
          const SizedBox(height: 20),

          // Category
          Text('CATEGORY', style: AppTextStyles.overline),
          const SizedBox(height: 8),
          Row(children: _cats.map((c) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: c.$1 != 'hymn' ? 8 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _category = c.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _category == c.$1
                        ? AppColors.blue.withOpacity(0.15) : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _category == c.$1 ? AppColors.blue : AppColors.border,
                      width: _category == c.$1 ? 1.5 : 1,
                    ),
                  ),
                  child: Text(c.$2, textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: _category == c.$1 ? AppColors.blue : AppColors.muted,
                    )),
                ),
              ),
            ),
          )).toList()),
          const SizedBox(height: 14),

          // Title
          Text('SONG TITLE', style: AppTextStyles.overline),
          const SizedBox(height: 6),
          TextField(controller: _titleCtrl,
            style: GoogleFonts.nunito(color: AppColors.white, fontSize: 14),
            decoration: InputDecoration(hintText: 'Song name...',
              hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 13))),
          const SizedBox(height: 12),

          // Artist
          Text('ARTIST / SINGER', style: AppTextStyles.overline),
          const SizedBox(height: 6),
          TextField(controller: _artistCtrl,
            style: GoogleFonts.nunito(color: AppColors.white, fontSize: 14),
            decoration: InputDecoration(hintText: 'Artist name...',
              hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 13))),
          const SizedBox(height: 12),

          // YouTube
          Text('YOUTUBE LINK (optional)', style: AppTextStyles.overline),
          const SizedBox(height: 6),
          TextField(controller: _ytCtrl,
            style: GoogleFonts.nunito(color: AppColors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'https://youtube.com/watch?v=...',
              hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 12),
              prefixIcon: const Icon(Icons.smart_display_rounded,
                  color: Color(0xFFFF0000), size: 18),
            )),
          const SizedBox(height: 12),

          // Lyrics
          Text('LYRICS (one line per row)', style: AppTextStyles.overline),
          const SizedBox(height: 6),
          TextField(controller: _lyricsCtrl, maxLines: 5,
            style: GoogleFonts.nunito(color: AppColors.white, fontSize: 13, height: 1.6),
            decoration: InputDecoration(
              hintText: 'Line 1\nLine 2\nLine 3...',
              hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 12),
            )),

          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
          ],
          const SizedBox(height: 16),

          // Submit
          GestureDetector(
            onTap: _submitting ? null : _submit,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.blueGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: _submitting
                  ? const Center(child: SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
                  : Text('Submit for Approval', textAlign: TextAlign.center,
                      style: AppTextStyles.bodyBold),
            ),
          ),
        ]),
      ),
    );
  }
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
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border2),
            ),
            child: const Center(child: Text('🎵', style: TextStyle(fontSize: 34))),
          ),
          const SizedBox(height: 16),
          Text('No songs yet', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text('Admin can add songs in the Admin panel\nor tap + to request a song!',
              style: AppTextStyles.body2, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
String extractYouTubeId(String url) {
  try {
    final uri = Uri.parse(url);

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    } else if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    }
  } catch (e) {
    return '';
  }
  return '';
}
