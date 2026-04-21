import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/app_models.dart';

class MockData {
  MockData._();

  static const DailyVerse dailyVerse = DailyVerse(
    text: 'I can do all things through Christ who strengthens me.',
    reference: 'Philippians 4:13',
  );

  static const List<BibleBook> books = [
    BibleBook(name: 'Genesis',     chapters: 50,  testament: 'OT'),
    BibleBook(name: 'Exodus',      chapters: 40,  testament: 'OT'),
    BibleBook(name: 'Psalms',      chapters: 150, testament: 'OT'),
    BibleBook(name: 'Proverbs',    chapters: 31,  testament: 'OT'),
    BibleBook(name: 'Isaiah',      chapters: 66,  testament: 'OT'),
    BibleBook(name: 'Jeremiah',    chapters: 52,  testament: 'OT'),
    BibleBook(name: 'Matthew',     chapters: 28,  testament: 'NT'),
    BibleBook(name: 'Mark',        chapters: 16,  testament: 'NT'),
    BibleBook(name: 'John',        chapters: 21,  testament: 'NT'),
    BibleBook(name: 'Acts',        chapters: 28,  testament: 'NT'),
    BibleBook(name: 'Romans',      chapters: 16,  testament: 'NT'),
    BibleBook(name: 'Philippians', chapters: 4,   testament: 'NT'),
    BibleBook(name: 'Hebrews',     chapters: 13,  testament: 'NT'),
    BibleBook(name: 'Revelation',  chapters: 22,  testament: 'NT'),
  ];

  static const List<BibleVerse> philippians4 = [
    BibleVerse(verse: 1,  text: 'Paul and Timothy, servants of Christ Jesus, to all the saints in Christ Jesus at Philippi, with the overseers and deacons:'),
    BibleVerse(verse: 2,  text: 'Grace to you and peace from God our Father and the Lord Jesus Christ.'),
    BibleVerse(verse: 3,  text: 'I thank my God in all my remembrance of you,'),
    BibleVerse(verse: 4,  text: 'always in every prayer of mine for you all making my prayer with joy,'),
    BibleVerse(verse: 5,  text: 'because of your partnership in the gospel from the first day until now.'),
    BibleVerse(verse: 6,  text: 'And I am sure of this, that he who began a good work in you will bring it to completion at the day of Jesus Christ.'),
    BibleVerse(verse: 7,  text: 'It is right for me to feel this way about you all, because I hold you in my heart.'),
    BibleVerse(verse: 11, text: 'Not that I am speaking of being in need, for I have learned, in whatever situation I am, to be content.'),
    BibleVerse(verse: 13, text: 'I can do all things through him who strengthens me.'),
    BibleVerse(verse: 19, text: 'And my God will supply every need of yours according to his riches in glory in Christ Jesus.'),
  ];

  static const List<BibleVerse> john3 = [
    BibleVerse(verse: 1,  text: 'Now there was a man of the Pharisees named Nicodemus, a ruler of the Jews.'),
    BibleVerse(verse: 2,  text: 'This man came to Jesus by night and said to him, "Rabbi, we know that you are a teacher come from God."'),
    BibleVerse(verse: 3,  text: 'Jesus answered him, "Truly, truly, I say to you, unless one is born again he cannot see the kingdom of God."'),
    BibleVerse(verse: 16, text: 'For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.'),
    BibleVerse(verse: 17, text: 'For God did not send his Son into the world to condemn the world, but in order that the world might be saved through him.'),
  ];

  static List<Song> get songs => [
    Song(id: 1, title: 'Amazing Grace',         artist: 'Traditional Hymn',      duration: '4:12', category: 'Hymns',        key: 'G',  bpm: 76),
    Song(id: 2, title: 'Oceans',                artist: 'Hillsong United',       duration: '5:42', category: 'Contemporary', key: 'D',  bpm: 67, isLiked: true),
    Song(id: 3, title: 'Way Maker',             artist: 'Sinach',                duration: '7:15', category: 'Praise',       key: 'A',  bpm: 80),
    Song(id: 4, title: 'What a Beautiful Name', artist: 'Hillsong Worship',      duration: '5:09', category: 'Contemporary', key: 'D',  bpm: 68, isLiked: true),
    Song(id: 5, title: 'Great Are You Lord',    artist: 'All Sons & Daughters',  duration: '4:44', category: 'Worship',      key: 'E',  bpm: 71),
    Song(id: 6, title: 'Holy Spirit',           artist: 'Francesca Battistelli', duration: '4:21', category: 'Contemporary', key: 'Bb', bpm: 73),
    Song(id: 7, title: 'Build My Life',         artist: 'Pat Barrett',           duration: '4:06', category: 'Worship',      key: 'C',  bpm: 69),
    Song(id: 8, title: 'Goodness of God',       artist: 'Bethel Music',          duration: '5:35', category: 'Praise',       key: 'B',  bpm: 74),
  ];

  static const SongLyrics wayMakerLyrics = SongLyrics(
    title: 'Way Maker', artist: 'Sinach',
    sections: [
      LyricsSection(label: 'Verse 1', lines: [
        'You are here, moving in our midst',
        'I worship You, I worship You',
        'You are here, working in this place',
        'I worship You, I worship You',
      ]),
      LyricsSection(label: 'Chorus', lines: [
        'Way Maker, Miracle Worker',
        'Promise Keeper, Light in the darkness',
        'My God, that is who You are',
        'Way Maker, Miracle Worker',
        'Promise Keeper, Light in the darkness',
        'My God, that is who You are',
      ]),
      LyricsSection(label: 'Verse 2', lines: [
        'You are here, touching every heart',
        'I worship You, I worship You',
        'You are here, healing every heart',
        'I worship You, I worship You',
      ]),
      LyricsSection(label: 'Bridge', lines: [
        "Even when I don't see it, You're working",
        "Even when I don't feel it, You're working",
        'You never stop, You never stop working',
        'You never stop, You never stop working',
      ]),
    ],
  );

  static const List<MediaItem> mediaItems = [
    MediaItem(id: 1, title: 'Sunday Service - April 20, 2026', church: 'Grace Fellowship',  duration: '1:12:33', views: '2.4K', type: 'service'),
    MediaItem(id: 2, title: 'Power of Prayer - Sermon Series', church: 'City Church',        duration: '38:17',   views: '892',  type: 'sermon'),
    MediaItem(id: 3, title: 'Easter Celebration 2026',         church: 'New Life Church',    duration: '2:04:11', views: '5.1K', type: 'event'),
    MediaItem(id: 4, title: 'Youth Bible Study - Romans 8',    church: 'Bethel Community',   duration: '44:22',   views: '318',  type: 'study'),
    MediaItem(id: 5, title: 'Worship Night Live',              church: 'Hillside Worship',   duration: '58:40',   views: '1.7K', type: 'worship'),
    MediaItem(id: 6, title: 'Healing and Miracles Conference', church: 'Dominion Church',    duration: '1:30:00', views: '3.2K', type: 'event'),
  ];

  static List<CommunityPost> get posts => [
    CommunityPost(id: 1, author: 'Sarah M.',     timeAgo: '2h ago', type: PostType.prayer,     content: "Please pray for my mother's recovery. She goes into surgery tomorrow. Trusting God's healing!", likes: 47,  comments: 12, avatar: 'SM'),
    CommunityPost(id: 2, author: 'James K.',     timeAgo: '4h ago', type: PostType.testimony,  content: 'God is faithful! After 3 years of waiting, I received the job offer this morning. He never fails!', likes: 134, comments: 28, avatar: 'JK'),
    CommunityPost(id: 3, author: 'Pastor David', timeAgo: '6h ago', type: PostType.devotional, content: '"Be still and know that I am God." In the chaos of life, find your stillness in Him.', likes: 89, comments: 34, avatar: 'PD'),
    CommunityPost(id: 4, author: 'Grace C.',     timeAgo: '1d ago', type: PostType.prayer,     content: 'Requesting prayer for my marriage. We are in a difficult season. Please stand with us in faith.', likes: 63, comments: 19, avatar: 'GC'),
  ];

  static const List<Course> courses = [
    Course(id: 1, title: 'Foundations of Faith',         lessons: 12, duration: '4 hrs',   progress: 75, category: 'Theology',         instructor: 'Dr. Paul Adeyemi'),
    Course(id: 2, title: 'Prayer & Fasting Masterclass', lessons: 8,  duration: '2.5 hrs', progress: 30, category: 'Spiritual Growth', instructor: 'Pastor Grace Obi'),
    Course(id: 3, title: 'Understanding Revelation',     lessons: 20, duration: '8 hrs',   progress: 0,  category: 'Bible Study',      instructor: 'Dr. Matthew Clark'),
    Course(id: 4, title: 'Christian Leadership',         lessons: 15, duration: '6 hrs',   progress: 60, category: 'Leadership',       instructor: 'Bishop Samuel Eze'),
    Course(id: 5, title: "Marriage God's Way",           lessons: 10, duration: '3.5 hrs', progress: 0,  category: 'Family',           instructor: 'Pastor & Mrs. John'),
  ];

  static List<MatrimonyProfile> get profiles => [
    MatrimonyProfile(id: 1, name: 'Priya S.',    age: 27, location: 'Chennai', denomination: 'Pentecostal', profession: 'Doctor',   bio: 'Seeking a God-fearing partner to build a Christ-centred family.',         avatar: 'PS', match: 92),
    MatrimonyProfile(id: 2, name: 'Daniel A.',   age: 31, location: 'Lagos',   denomination: 'Baptist',     profession: 'Engineer', bio: 'Love for God, family, and community. Ready to build a home on His word.', avatar: 'DA', match: 88),
    MatrimonyProfile(id: 3, name: 'Rebecca T.',  age: 25, location: 'Nairobi', denomination: 'Anglican',    profession: 'Teacher',  bio: 'Passionate about ministry, children, and living a faith-filled life.',    avatar: 'RT', match: 85),
    MatrimonyProfile(id: 4, name: 'Emmanuel O.', age: 29, location: 'Abuja',   denomination: 'Catholic',    profession: 'Lawyer',   bio: 'Grounded in faith, seeking a virtuous woman to walk this journey with.',  avatar: 'EO', match: 81),
  ];

  static const List<QuickTile> quickTiles = [
    QuickTile(id: 'bible',     label: 'Bible',     icon: Icons.menu_book_outlined,      color: AppColors.blue),
    QuickTile(id: 'worship',   label: 'Worship',   icon: Icons.music_note_outlined,     color: AppColors.violet),
    QuickTile(id: 'media',     label: 'Media',     icon: Icons.play_circle_outline,     color: AppColors.danger),
    QuickTile(id: 'courses',   label: 'Courses',   icon: Icons.school_outlined,         color: AppColors.success),
    QuickTile(id: 'community', label: 'Community', icon: Icons.people_outline_rounded,  color: AppColors.gold),
    QuickTile(id: 'matrimony', label: 'Matrimony', icon: Icons.favorite_border_rounded, color: AppColors.pink),
  ];
}
