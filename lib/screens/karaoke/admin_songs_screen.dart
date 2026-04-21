import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../models/song_model.dart';
import '../../services/song_service.dart';
import '../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════
// Admin Songs Screen
// ════════════════════════════════════════════════════════════════════════════
class AdminSongsScreen extends StatefulWidget {
  const AdminSongsScreen({super.key});

  @override
  State<AdminSongsScreen> createState() => _AdminSongsScreenState();
}

class _AdminSongsScreenState extends State<AdminSongsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      floatingActionButton: GestureDetector(
        onTap: () => _showAddSongAdmin(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.add_rounded, color: Colors.black, size: 20),
            const SizedBox(width: 6),
            Text('Add Song', style: AppTextStyles.buttonPrimary),
          ]),
        ),
      ),
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(K.pad, 14, K.pad, 10),
            child: Row(children: [
              CCIconBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Admin Panel', style: AppTextStyles.heading2),
                Text('Manage songs & lyrics', style: AppTextStyles.caption),
              ])),
              // Seed button
              GestureDetector(
                onTap: () => _seedSampleSongs(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Text('Seed Songs',
                    style: GoogleFonts.nunito(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: AppColors.success)),
                ),
              ),
            ]),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: K.pad),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TabBar(
              controller: _tabs,
              indicator: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor:        Colors.black,
              unselectedLabelColor: AppColors.muted,
              labelStyle:   GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: const [Tab(text: 'All Songs'), Tab(text: 'Pending Approval')],
            ),
          ),
          const SizedBox(height: 8),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _AllSongsTab(),
                _PendingTab(),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _seedSampleSongs(BuildContext context) async {
    try {
      final col = FirebaseFirestore.instance.collection('songs');
      for (final song in SongService.sampleSongs) {
        await col.add(song);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${SongService.sampleSongs.length} sample songs added!',
              style: AppTextStyles.body2),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e', style: AppTextStyles.body2),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  void _showAddSongAdmin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdminAddSongSheet(),
    );
  }
}

// ── All Songs Tab ─────────────────────────────────────────────────────────
class _AllSongsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SongModel>>(
      stream: SongService.instance.songsStream(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(
              color: AppColors.gold, strokeWidth: 2.5));
        }
        final songs = snap.data ?? [];
        if (songs.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.queue_music_rounded, color: AppColors.muted, size: 52),
            const SizedBox(height: 12),
            Text('No songs yet', style: AppTextStyles.heading3),
            const SizedBox(height: 6),
            Text('Tap "Seed Songs" to add samples\nor + to add manually',
                style: AppTextStyles.body2, textAlign: TextAlign.center),
          ]));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(K.pad, 4, K.pad, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: songs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _AdminSongCard(song: songs[i]),
        );
      },
    );
  }
}

// ── Pending Tab ───────────────────────────────────────────────────────────
class _PendingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SongModel>>(
      stream: SongService.instance.pendingStream(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(
              color: AppColors.gold, strokeWidth: 2.5));
        }
        final songs = snap.data ?? [];
        if (songs.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.success, size: 52),
            const SizedBox(height: 12),
            Text('No pending songs', style: AppTextStyles.heading3),
            const SizedBox(height: 6),
            Text('All requests have been reviewed',
                style: AppTextStyles.body2),
          ]));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(K.pad, 4, K.pad, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: songs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _PendingCard(song: songs[i]),
        );
      },
    );
  }
}

// ── Admin Song Card ───────────────────────────────────────────────────────
class _AdminSongCard extends StatelessWidget {
  final SongModel song;
  const _AdminSongCard({required this.song});

  @override
  Widget build(BuildContext context) {
    return CCCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(song.title.isNotEmpty ? song.title : song.titleTelugu,
                style: AppTextStyles.cardTitle, maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(song.artist, style: AppTextStyles.cardSubtitle),
          ])),
          CCBadge(text: song.categoryLabel, color: song.categoryColor),
        ]),
        const SizedBox(height: 10),
        if (song.youtubeUrl.isNotEmpty)
          Row(children: [
            const Icon(Icons.smart_display_rounded,
                color: Color(0xFFFF0000), size: 14),
            const SizedBox(width: 6),
            Expanded(child: Text(song.youtubeUrl,
                style: AppTextStyles.caption.copyWith(color: AppColors.blue),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        const SizedBox(height: 8),
        Text('${song.lyrics.length} lyrics lines',
            style: AppTextStyles.caption),
        const SizedBox(height: 10),
        Row(children: [
          // Edit
          Expanded(child: GestureDetector(
            onTap: () => _showEditSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.blue.withOpacity(0.3)),
              ),
              child: Text('Edit', textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.blue, fontWeight: FontWeight.w700)),
            ),
          )),
          const SizedBox(width: 8),
          // Delete
          Expanded(child: GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Text('Delete', textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.danger, fontWeight: FontWeight.w700)),
            ),
          )),
        ]),
      ]),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSongSheet(song: song),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Song?', style: AppTextStyles.heading3),
        content: Text('This cannot be undone.', style: AppTextStyles.body2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppTextStyles.goldLabel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SongService.instance.deleteSong(song.id);
            },
            child: Text('Delete',
                style: AppTextStyles.body2.copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

// ── Pending Card ──────────────────────────────────────────────────────────
class _PendingCard extends StatelessWidget {
  final SongModel song;
  const _PendingCard({required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(
            song.title.isNotEmpty ? song.title : song.titleTelugu,
            style: AppTextStyles.cardTitle)),
          CCBadge(text: 'Pending', color: AppColors.gold),
        ]),
        const SizedBox(height: 4),
        Text(song.artist, style: AppTextStyles.cardSubtitle),
        const SizedBox(height: 12),
        Row(children: [
          // Approve
          Expanded(child: GestureDetector(
            onTap: () async {
              await SongService.instance.approveSong(song.id);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Song approved!', style: AppTextStyles.body2),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Text('✓ Approve', textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.success, fontWeight: FontWeight.w700)),
            ),
          )),
          const SizedBox(width: 8),
          // Reject
          Expanded(child: GestureDetector(
            onTap: () async => await SongService.instance.deleteSong(song.id),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Text('✗ Reject', textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.danger, fontWeight: FontWeight.w700)),
            ),
          )),
        ]),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Admin Add Song Sheet — with YouTube + Lyrics
// ════════════════════════════════════════════════════════════════════════════
class _AdminAddSongSheet extends StatefulWidget {
  @override
  State<_AdminAddSongSheet> createState() => _AdminAddSongSheetState();
}

class _AdminAddSongSheetState extends State<_AdminAddSongSheet> {
  final _titleCtrl      = TextEditingController();
  final _titleTelCtrl   = TextEditingController();
  final _artistCtrl     = TextEditingController();
  final _ytCtrl         = TextEditingController();
  final _lyricsCtrl     = TextEditingController();
  String _category      = 'telugu_worship';
  bool   _submitting    = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose(); _titleTelCtrl.dispose();
    _artistCtrl.dispose(); _ytCtrl.dispose(); _lyricsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Title required'); return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      final ytId = SongModel._extractId(_ytCtrl.text.trim());
      final lines = _lyricsCtrl.text.trim().split('\n')
          .where((l) => l.trim().isNotEmpty).toList();
      final lyrics = lines.asMap().entries.map((e) =>
          LyricsLine(text: e.value.trim(), startSeconds: e.key * 8)).toList();

      final song = SongModel(
        id: '', title: _titleCtrl.text.trim(),
        titleTelugu: _titleTelCtrl.text.trim(),
        artist:      _artistCtrl.text.trim(),
        youtubeUrl:  _ytCtrl.text.trim(),
        youtubeId:   ytId,
        category:    _category,
        language:    _category == 'telugu_worship' ? 'telugu' : 'english',
        lyrics:      lyrics,
        addedBy:     'admin',
        isApproved:  true, // admin adds = auto approved
        createdAt:   DateTime.now(),
      );
      await SongService.instance.addSong(song);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = 'Failed: $e'; _submitting = false; });
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
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.muted, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.black, size: 18)),
            const SizedBox(width: 10),
            Text('Admin — Add Song', style: AppTextStyles.heading3),
          ]),
          const SizedBox(height: 4),
          Text('Song will be auto-approved', style: AppTextStyles.caption.copyWith(color: AppColors.success)),
          const SizedBox(height: 18),

          // Category
          _label('CATEGORY'),
          const SizedBox(height: 6),
          Row(children: [
            ('telugu_worship', 'తెలుగు'),
            ('english_worship', 'English'),
            ('hymn', 'Hymn'),
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
                        ? AppColors.gold.withOpacity(0.15) : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _category == c.$1 ? AppColors.gold : AppColors.border,
                      width: _category == c.$1 ? 1.5 : 1),
                  ),
                  child: Text(c.$2, textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700,
                      color: _category == c.$1 ? AppColors.gold : AppColors.muted)),
                ),
              ),
            ),
          )).toList()),
          const SizedBox(height: 12),

          _label('ENGLISH TITLE'), const SizedBox(height: 6),
          _field(_titleCtrl, 'Song title in English'),
          const SizedBox(height: 10),

          _label('TELUGU TITLE (if applicable)'), const SizedBox(height: 6),
          _field(_titleTelCtrl, 'తెలుగు పేరు'),
          const SizedBox(height: 10),

          _label('ARTIST / SINGER'), const SizedBox(height: 6),
          _field(_artistCtrl, 'Artist name'),
          const SizedBox(height: 10),

          _label('YOUTUBE LINK'), const SizedBox(height: 6),
          TextField(controller: _ytCtrl,
            style: GoogleFonts.nunito(color: AppColors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'https://youtube.com/watch?v=xxxxx',
              hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 12),
              prefixIcon: const Icon(Icons.smart_display_rounded,
                  color: Color(0xFFFF0000), size: 18))),
          const SizedBox(height: 10),

          _label('LYRICS (one line per row, auto-timed)'), const SizedBox(height: 6),
          TextField(controller: _lyricsCtrl, maxLines: 6,
            style: GoogleFonts.nunito(color: AppColors.white, fontSize: 13, height: 1.6),
            decoration: InputDecoration(
              hintText: 'Line 1\nLine 2\nChorus...',
              hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 12))),

          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
          ],
          const SizedBox(height: 16),

          GestureDetector(
            onTap: _submitting ? null : _save,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(14),
              ),
              child: _submitting
                  ? const Center(child: SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5)))
                  : Text('Save Song', textAlign: TextAlign.center,
                      style: AppTextStyles.buttonPrimary),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: AppTextStyles.overline);

  Widget _field(TextEditingController ctrl, String hint) => TextField(
    controller: ctrl,
    style: GoogleFonts.nunito(color: AppColors.white, fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 13)),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// Edit Song Sheet
// ════════════════════════════════════════════════════════════════════════════
class _EditSongSheet extends StatefulWidget {
  final SongModel song;
  const _EditSongSheet({required this.song});

  @override
  State<_EditSongSheet> createState() => _EditSongSheetState();
}

class _EditSongSheetState extends State<_EditSongSheet> {
  late final _titleCtrl  = TextEditingController(text: widget.song.title);
  late final _artistCtrl = TextEditingController(text: widget.song.artist);
  late final _ytCtrl     = TextEditingController(text: widget.song.youtubeUrl);
  late final _lyricsCtrl = TextEditingController(
      text: widget.song.lyrics.map((l) => l.text).join('\n'));
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose(); _artistCtrl.dispose();
    _ytCtrl.dispose(); _lyricsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final lines = _lyricsCtrl.text.trim().split('\n')
        .where((l) => l.trim().isNotEmpty).toList();
    final lyrics = lines.asMap().entries.map((e) =>
        LyricsLine(text: e.value.trim(), startSeconds: e.key * 8)).toList();

    final ytId = SongModel._extractId(_ytCtrl.text.trim());
    await SongService.instance.updateSong(widget.song.id, {
      'title':      _titleCtrl.text.trim(),
      'artist':     _artistCtrl.text.trim(),
      'youtubeUrl': _ytCtrl.text.trim(),
      'youtubeId':  ytId,
      'lyrics':     lyrics.map((l) => l.toMap()).toList(),
    });
    if (mounted) Navigator.pop(context);
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
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.muted, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Edit Song', style: AppTextStyles.heading3),
          const SizedBox(height: 16),

          Text('TITLE', style: AppTextStyles.overline), const SizedBox(height: 6),
          TextField(controller: _titleCtrl,
            style: GoogleFonts.nunito(color: AppColors.white, fontSize: 14),
            decoration: InputDecoration(hintText: 'Song title',
              hintStyle: GoogleFonts.nunito(color: AppColors.muted))),
          const SizedBox(height: 10),

          Text('ARTIST', style: AppTextStyles.overline), const SizedBox(height: 6),
          TextField(controller: _artistCtrl,
            style: GoogleFonts.nunito(color: AppColors.white, fontSize: 14),
            decoration: InputDecoration(hintText: 'Artist name',
              hintStyle: GoogleFonts.nunito(color: AppColors.muted))),
          const SizedBox(height: 10),

          Text('YOUTUBE LINK', style: AppTextStyles.overline), const SizedBox(height: 6),
          TextField(controller: _ytCtrl,
            style: GoogleFonts.nunito(color: AppColors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'https://youtube.com/watch?v=...',
              hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 12),
              prefixIcon: const Icon(Icons.smart_display_rounded,
                  color: Color(0xFFFF0000), size: 18))),
          const SizedBox(height: 10),

          Text('LYRICS (one line per row)', style: AppTextStyles.overline), const SizedBox(height: 6),
          TextField(controller: _lyricsCtrl, maxLines: 7,
            style: GoogleFonts.nunito(color: AppColors.white, fontSize: 13, height: 1.6),
            decoration: InputDecoration(
              hintText: 'Line 1\nLine 2...',
              hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 12))),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: _saving ? null : _save,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  color: AppColors.gold, borderRadius: BorderRadius.circular(14)),
              child: _saving
                  ? const Center(child: SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5)))
                  : Text('Save Changes', textAlign: TextAlign.center,
                      style: AppTextStyles.buttonPrimary),
            ),
          ),
        ]),
      ),
    );
  }
}
