import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class BibleVerse {
  final int verse;
  final String text;
  const BibleVerse({required this.verse, required this.text});
}

class BibleBook {
  final String name;
  final int chapters;
  final String testament;
  const BibleBook({required this.name, required this.chapters, required this.testament});
}

class DailyVerse {
  final String text;
  final String reference;
  const DailyVerse({required this.text, required this.reference});
}

class Song {
  final int id;
  final String title;
  final String artist;
  final String duration;
  final String category;
  final String key;
  final int bpm;
  bool isLiked;
  Song({required this.id, required this.title, required this.artist,
        required this.duration, required this.category, required this.key,
        required this.bpm, this.isLiked = false});
}

class LyricsSection {
  final String label;
  final List<String> lines;
  const LyricsSection({required this.label, required this.lines});
}

class SongLyrics {
  final String title;
  final String artist;
  final List<LyricsSection> sections;
  const SongLyrics({required this.title, required this.artist, required this.sections});
}

class MediaItem {
  final int id;
  final String title;
  final String church;
  final String duration;
  final String views;
  final String type;
  const MediaItem({required this.id, required this.title, required this.church,
                   required this.duration, required this.views, required this.type});
  Color get typeColor {
    switch (type) {
      case 'service': return AppColors.blue;
      case 'sermon':  return AppColors.violet;
      case 'event':   return AppColors.danger;
      case 'study':   return AppColors.success;
      case 'worship': return AppColors.goldDim;
      default:        return AppColors.blue;
    }
  }
}

enum PostType { prayer, testimony, devotional }

class CommunityPost {
  final int id;
  final String author;
  final String timeAgo;
  final PostType type;
  final String content;
  final int likes;
  final int comments;
  final String avatar;
  bool isLiked;
  bool isPraying;
  CommunityPost({required this.id, required this.author, required this.timeAgo,
                 required this.type, required this.content, required this.likes,
                 required this.comments, required this.avatar,
                 this.isLiked = false, this.isPraying = false});
  Color get typeColor => type == PostType.prayer
      ? AppColors.blue
      : type == PostType.testimony
          ? AppColors.success
          : AppColors.gold;
  String get typeLabel => type == PostType.prayer
      ? 'Prayer'
      : type == PostType.testimony
          ? 'Testimony'
          : 'Devotional';
  Color get avatarBg => type == PostType.prayer
      ? AppColors.blue
      : type == PostType.testimony
          ? AppColors.success
          : AppColors.goldDim;
}

class Course {
  final int id;
  final String title;
  final int lessons;
  final String duration;
  final int progress;
  final String category;
  final String instructor;
  const Course({required this.id, required this.title, required this.lessons,
                required this.duration, required this.progress,
                required this.category, required this.instructor});
  bool get isEnrolled => progress > 0;
  Color get catColor {
    switch (category) {
      case 'Theology':         return AppColors.blue;
      case 'Spiritual Growth': return AppColors.violet;
      case 'Bible Study':      return AppColors.success;
      case 'Leadership':       return AppColors.gold;
      case 'Family':           return AppColors.pink;
      default:                 return AppColors.blue;
    }
  }
}

class MatrimonyProfile {
  final int id;
  final String name;
  final int age;
  final String location;
  final String denomination;
  final String profession;
  final String bio;
  final String avatar;
  final int match;
  bool isSaved;
  MatrimonyProfile({required this.id, required this.name, required this.age,
                    required this.location, required this.denomination,
                    required this.profession, required this.bio,
                    required this.avatar, required this.match, this.isSaved = false});
}

class QuickTile {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  const QuickTile({required this.id, required this.label, required this.icon, required this.color});
}
