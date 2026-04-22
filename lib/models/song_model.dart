import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SongModel {
  final String  id;
  final String  title;
  final String  titleTelugu;
  final String  artist;
  final String  youtubeUrl;
  final String  youtubeId;
  final String  category;
  final String  language;
  final List<LyricsLine> lyrics;
  final String  addedBy;
  final bool    isApproved;
  final DateTime createdAt;

  const SongModel({
    required this.id,
    required this.title,
    required this.titleTelugu,
    required this.artist,
    required this.youtubeUrl,
    required this.youtubeId,
    required this.category,
    required this.language,
    required this.lyrics,
    required this.addedBy,
    required this.isApproved,
    required this.createdAt,
  });

  factory SongModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final ytUrl = d['youtubeUrl'] as String? ?? '';
    return SongModel(
      id:          doc.id,
      title:       d['title']       ?? '',
      titleTelugu: d['titleTelugu'] ?? '',
      artist:      d['artist']      ?? '',
      youtubeUrl:  ytUrl,
      youtubeId:   d['youtubeId']   ?? extractYoutubeId(ytUrl),
      category:    d['category']    ?? 'telugu_worship',
      language:    d['language']    ?? 'telugu',
      lyrics:      (d['lyrics'] as List? ?? [])
          .map((l) => LyricsLine.fromMap(l as Map<String, dynamic>))
          .toList(),
      addedBy:     d['addedBy']    ?? '',
      isApproved:  d['isApproved'] ?? false,
      createdAt:   (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title':       title,
    'titleTelugu': titleTelugu,
    'artist':      artist,
    'youtubeUrl':  youtubeUrl,
    'youtubeId':   youtubeId,
    'category':    category,
    'language':    language,
    'lyrics':      lyrics.map((l) => l.toMap()).toList(),
    'addedBy':     addedBy,
    'isApproved':  isApproved,
    'createdAt':   Timestamp.fromDate(createdAt),
  };

  // ── PUBLIC static helper ───────────────────────────────────────────────
  static String extractYoutubeId(String url) {
    if (url.isEmpty) return '';
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    }
    return uri.queryParameters['v'] ?? '';
  }

  Color get categoryColor {
    switch (category) {
      case 'telugu_worship':  return const Color(0xFFF4A623);
      case 'english_worship': return const Color(0xFF2B5CE6);
      case 'hymn':            return const Color(0xFF10B981);
      default:                return const Color(0xFF7C3AED);
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'telugu_worship':  return 'Telugu Worship';
      case 'english_worship': return 'English Worship';
      case 'hymn':            return 'Hymn';
      default:                return 'Other';
    }
  }
}

class LyricsLine {
  final String text;
  final int    startSeconds;
  const LyricsLine({required this.text, required this.startSeconds});

  factory LyricsLine.fromMap(Map<String, dynamic> m) => LyricsLine(
    text:         m['text']         as String? ?? '',
    startSeconds: (m['startSeconds'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'text':         text,
    'startSeconds': startSeconds,
  };
}
