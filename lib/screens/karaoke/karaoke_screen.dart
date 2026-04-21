import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../models/song_model.dart';
import '../../services/song_service.dart';
import '../../widgets/widgets.dart';

class KaraokeScreen extends StatefulWidget {
  const KaraokeScreen({super.key});

  @override
  State<KaraokeScreen> createState() => _KaraokeScreenState();
}

class _KaraokeScreenState extends State<KaraokeScreen> {
  String _filter = 'all';
  SongModel? _playing;

  static const _filters = [
    ('all', 'All'),
    ('telugu_worship', 'తెలుగు'),
    ('english_worship', 'English'),
    ('hymn', 'Hymns'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      floatingActionButton: _AddSongFAB(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilters(),
            if (_playing != null)
              Text("Now Playing: ${_playing!.title}",
                  style: TextStyle(color: Colors.white)),
            Expanded(
              child: StreamBuilder<List<SongModel>>(
                stream: SongService.instance.songsStream(category: _filter),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final songs = snapshot.data!;
                  if (songs.isEmpty) {
                    return const Center(
                        child: Text("No songs",
                            style: TextStyle(color: Colors.white)));
                  }

                  return ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return ListTile(
                        title: Text(song.title,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(song.artist,
                            style: const TextStyle(color: Colors.white70)),
                        onTap: () {
                          setState(() => _playing = song);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FIXED HEADER
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Karaoke",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Search Button
          CCIconBtn(
            icon: Icons.search,
            onTap: () {},
          ),

          const SizedBox(width: 10),

          // Admin Button
          CCIconBtn(
            icon: Icons.admin_panel_settings,
            iconColor: Colors.amber,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Admin panel coming soon")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final f = _filters[index];
          return GestureDetector(
            onTap: () => setState(() => _filter = f.$1),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _filter == f.$1
                    ? Colors.blue
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  f.$2,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ✅ ADD SONG FAB
class _AddSongFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => const _AddSongSheet(),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

// ✅ ADD SONG SHEET (FIXED)
class _AddSongSheet extends StatefulWidget {
  const _AddSongSheet();

  @override
  State<_AddSongSheet> createState() => _AddSongSheetState();
}

class _AddSongSheetState extends State<_AddSongSheet> {
  final _titleCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _ytCtrl = TextEditingController();

  bool _loading = false;

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty) return;

    setState(() => _loading = true);

    final ytId = extractYouTubeId(_ytCtrl.text);

    await FirebaseFirestore.instance.collection('songs').add({
      "title": _titleCtrl.text,
      "artist": _artistCtrl.text,
      "youtubeId": ytId,
      "createdAt": Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: "Title"),
          ),
          TextField(
            controller: _artistCtrl,
            decoration: const InputDecoration(labelText: "Artist"),
          ),
          TextField(
            controller: _ytCtrl,
            decoration: const InputDecoration(labelText: "YouTube URL"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const CircularProgressIndicator()
                : const Text("Submit"),
          )
        ],
      ),
    );
  }
}

// ✅ YOUTUBE ID EXTRACT (FIXED)
String extractYouTubeId(String url) {
  try {
    final uri = Uri.parse(url);

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.first;
    } else if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'] ?? '';
    }
  } catch (_) {}

  return '';
}
