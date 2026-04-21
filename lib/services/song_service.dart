import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/song_model.dart';

class SongService {
  SongService._();
  static final SongService instance = SongService._();

  final _col = FirebaseFirestore.instance.collection('songs');

  // ── Get all approved songs ────────────────────────────────────────────
  Stream<List<SongModel>> songsStream({String? category}) {
    Query q = _col
        .where('isApproved', isEqualTo: true)
        .orderBy('createdAt', descending: true);
    if (category != null && category != 'all') {
      q = q.where('category', isEqualTo: category);
    }
    return q.snapshots().map((snap) =>
        snap.docs.map((d) => SongModel.fromFirestore(d)).toList());
  }

  // ── Add song (user request — needs admin approval) ────────────────────
  Future<void> addSong(SongModel song) async {
    await _col.add(song.toFirestore());
  }

  // ── Admin: approve song ───────────────────────────────────────────────
  Future<void> approveSong(String id) async {
    await _col.doc(id).update({'isApproved': true});
  }

  // ── Admin: delete song ────────────────────────────────────────────────
  Future<void> deleteSong(String id) async {
    await _col.doc(id).delete();
  }

  // ── Admin: update song ────────────────────────────────────────────────
  Future<void> updateSong(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  // ── Get pending songs (admin) ─────────────────────────────────────────
  Stream<List<SongModel>> pendingStream() {
    return _col
        .where('isApproved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => SongModel.fromFirestore(d)).toList());
  }

  // ── Sample songs to seed Firestore ───────────────────────────────────
  static List<Map<String, dynamic>> get sampleSongs => [
    {
      'title': 'Way Maker',
      'titleTelugu': 'మార్గం చేసేవాడు',
      'artist': 'Sinach',
      'youtubeUrl': 'https://www.youtube.com/watch?v=iKTMBMmcaKU',
      'youtubeId': 'iKTMBMmcaKU',
      'category': 'english_worship',
      'language': 'english',
      'isApproved': true,
      'addedBy': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
      'lyrics': [
        {'text': 'You are here, moving in our midst', 'startSeconds': 10},
        {'text': 'I worship You, I worship You', 'startSeconds': 18},
        {'text': 'You are here, working in this place', 'startSeconds': 26},
        {'text': 'I worship You, I worship You', 'startSeconds': 34},
        {'text': 'Way Maker, Miracle Worker', 'startSeconds': 60},
        {'text': 'Promise Keeper, Light in the darkness', 'startSeconds': 68},
        {'text': 'My God, that is who You are', 'startSeconds': 76},
      ],
    },
    {
      'title': 'యేసయ్య నా జీవితం',
      'titleTelugu': 'యేసయ్య నా జీవితం',
      'artist': 'Telugu Christian',
      'youtubeUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      'youtubeId': 'dQw4w9WgXcQ',
      'category': 'telugu_worship',
      'language': 'telugu',
      'isApproved': true,
      'addedBy': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
      'lyrics': [
        {'text': 'యేసయ్య నా జీవితం', 'startSeconds': 5},
        {'text': 'నీవే నా ఆశ్రయం', 'startSeconds': 13},
        {'text': 'నీ నామమే మహిమ', 'startSeconds': 21},
        {'text': 'నీవే నా దేవుడు', 'startSeconds': 29},
      ],
    },
    {
      'title': 'Amazing Grace',
      'titleTelugu': 'అద్భుతమైన కృప',
      'artist': 'Traditional Hymn',
      'youtubeUrl': 'https://www.youtube.com/watch?v=CDdvReNKKuk',
      'youtubeId': 'CDdvReNKKuk',
      'category': 'hymn',
      'language': 'english',
      'isApproved': true,
      'addedBy': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
      'lyrics': [
        {'text': 'Amazing grace, how sweet the sound', 'startSeconds': 8},
        {'text': 'That saved a wretch like me', 'startSeconds': 16},
        {'text': 'I once was lost, but now am found', 'startSeconds': 24},
        {'text': 'Was blind, but now I see', 'startSeconds': 32},
      ],
    },
    {
      'title': 'Oceans',
      'titleTelugu': 'సముద్రాలు',
      'artist': 'Hillsong United',
      'youtubeUrl': 'https://www.youtube.com/watch?v=dy9nwe9_xzw',
      'youtubeId': 'dy9nwe9_xzw',
      'category': 'english_worship',
      'language': 'english',
      'isApproved': true,
      'addedBy': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
      'lyrics': [
        {'text': 'You call me out upon the waters', 'startSeconds': 30},
        {'text': 'The great unknown where feet may fail', 'startSeconds': 38},
        {'text': 'And there I find You in the mystery', 'startSeconds': 46},
        {'text': 'In oceans deep, my faith will stand', 'startSeconds': 54},
      ],
    },
  ];
}
