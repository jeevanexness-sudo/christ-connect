import 'dart:convert';
import 'package:http/http.dart' as http;

// ════════════════════════════════════════════════════════════════════════════
// Bible Service — Free APIs, no key needed
// English: bible-api.com (KJV, NIV, ESV, NKJV, WEB)
// Telugu:  bolls.life (tel = Telugu O.V.)
// ════════════════════════════════════════════════════════════════════════════

class BibleVerse {
  final int    verse;
  final String text;
  const BibleVerse({required this.verse, required this.text});
}

class BibleChapter {
  final String       book;
  final int          chapter;
  final String       translation;
  final List<BibleVerse> verses;
  const BibleChapter({
    required this.book,
    required this.chapter,
    required this.translation,
    required this.verses,
  });
}

class BibleBook {
  final int    id;
  final String name;
  final String nameTelugu;
  final int    chapters;
  final String testament; // 'OT' or 'NT'
  const BibleBook({
    required this.id,
    required this.name,
    required this.nameTelugu,
    required this.chapters,
    required this.testament,
  });
}

class SearchResult {
  final String book;
  final int    chapter;
  final int    verse;
  final String text;
  const SearchResult({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });
  String get reference => '$book $chapter:$verse';
}

// ── Translation model ──────────────────────────────────────────────────────
class BibleTranslation {
  final String id;
  final String name;
  final String language;
  const BibleTranslation({required this.id, required this.name, required this.language});
}

class BibleService {
  BibleService._();
  static final BibleService instance = BibleService._();

  static const _timeout = Duration(seconds: 15);

  // ── Available translations ─────────────────────────────────────────────
  static const List<BibleTranslation> translations = [
    BibleTranslation(id: 'kjv',    name: 'KJV',    language: 'English'),
    BibleTranslation(id: 'web',    name: 'WEB',    language: 'English'),
    BibleTranslation(id: 'bbe',    name: 'BBE',    language: 'English'),
    BibleTranslation(id: 'oeb-us', name: 'OEB',    language: 'English'),
    BibleTranslation(id: 'tel',    name: 'తెలుగు', language: 'Telugu'),
  ];

  // ════════════════════════════════════════════════════════════════════════
  // Fetch chapter — auto-routes to correct API based on translation
  // ════════════════════════════════════════════════════════════════════════
  Future<BibleChapter> fetchChapter({
    required String bookName,
    required int    chapter,
    required String translation,
  }) async {
    if (translation == 'tel') {
      return _fetchTelugu(bookName: bookName, chapter: chapter);
    }
    return _fetchEnglish(bookName: bookName, chapter: chapter, translation: translation);
  }

  // ── English — bible-api.com ────────────────────────────────────────────
  Future<BibleChapter> _fetchEnglish({
    required String bookName,
    required int    chapter,
    required String translation,
  }) async {
    final encoded = Uri.encodeComponent('$bookName $chapter');
    final url = 'https://bible-api.com/$encoded?translation=$translation';

    final resp = await http
        .get(Uri.parse(url))
        .timeout(_timeout);

    if (resp.statusCode != 200) {
      throw Exception('Failed to load chapter (${resp.statusCode})');
    }

    final data = json.decode(resp.body) as Map<String, dynamic>;
    final verses = (data['verses'] as List).map((v) {
      return BibleVerse(
        verse: v['verse'] as int,
        text:  (v['text'] as String).trim(),
      );
    }).toList();

    return BibleChapter(
      book:        bookName,
      chapter:     chapter,
      translation: translation.toUpperCase(),
      verses:      verses,
    );
  }

  // ── Telugu — bolls.life ────────────────────────────────────────────────
  Future<BibleChapter> _fetchTelugu({
    required String bookName,
    required int    chapter,
  }) async {
    final bookId = _teluguBookId(bookName);
    if (bookId == null) throw Exception('Book not found in Telugu Bible');

    final url = 'https://bolls.life/get-chapter/tel/$bookId/$chapter/';

    final resp = await http
        .get(Uri.parse(url))
        .timeout(_timeout);

    if (resp.statusCode != 200) {
      throw Exception('Telugu Bible load failed (${resp.statusCode})');
    }

    final data = json.decode(resp.body) as List;
    final verses = data.asMap().entries.map((e) {
      final v = e.value as Map<String, dynamic>;
      return BibleVerse(
        verse: (v['verse'] as int?) ?? (e.key + 1),
        text:  (v['text'] as String).trim(),
      );
    }).toList();

    return BibleChapter(
      book:        bookName,
      chapter:     chapter,
      translation: 'తెలుగు',
      verses:      verses,
    );
  }

  // ── Daily Verse ────────────────────────────────────────────────────────
  Future<BibleVerse> fetchDailyVerse(String translation) async {
    final refs = [
      'John 3:16', 'Philippians 4:13', 'Jeremiah 29:11',
      'Romans 8:28', 'Psalm 23:1', 'Isaiah 40:31',
      'Matthew 11:28', 'Proverbs 3:5', 'Joshua 1:9',
    ];
    final ref = refs[DateTime.now().day % refs.length];

    try {
      final encoded = Uri.encodeComponent(ref);
      final t = translation == 'tel' ? 'kjv' : translation;
      final resp = await http
          .get(Uri.parse('https://bible-api.com/$encoded?translation=$t'))
          .timeout(_timeout);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        return BibleVerse(
          verse: 1,
          text:  (data['text'] as String).trim(),
        );
      }
    } catch (_) {}

    return const BibleVerse(
      verse: 13,
      text: 'I can do all things through Christ who strengthens me.',
    );
  }

  // ── Search (english only via bible-api) ───────────────────────────────
  Future<List<SearchResult>> search(String query, String translation) async {
    if (query.trim().length < 3) return [];
    final t = translation == 'tel' ? 'kjv' : translation;
    final encoded = Uri.encodeComponent(query.trim());
    final url = 'https://bible-api.com/$encoded?translation=$t';

    try {
      final resp = await http.get(Uri.parse(url)).timeout(_timeout);
      if (resp.statusCode != 200) return [];
      final data = json.decode(resp.body) as Map<String, dynamic>;
      if (data['verses'] == null) return [];

      return (data['verses'] as List).map((v) {
        return SearchResult(
          book:    v['book_name'] as String,
          chapter: v['chapter']  as int,
          verse:   v['verse']    as int,
          text:    (v['text']    as String).trim(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Telugu book ID mapping ─────────────────────────────────────────────
  int? _teluguBookId(String bookName) {
    const map = {
      'Genesis': 1, 'Exodus': 2, 'Leviticus': 3, 'Numbers': 4,
      'Deuteronomy': 5, 'Joshua': 6, 'Judges': 7, 'Ruth': 8,
      '1 Samuel': 9, '2 Samuel': 10, '1 Kings': 11, '2 Kings': 12,
      '1 Chronicles': 13, '2 Chronicles': 14, 'Ezra': 15, 'Nehemiah': 16,
      'Esther': 17, 'Job': 18, 'Psalms': 19, 'Proverbs': 20,
      'Ecclesiastes': 21, 'Song of Solomon': 22, 'Isaiah': 23,
      'Jeremiah': 24, 'Lamentations': 25, 'Ezekiel': 26, 'Daniel': 27,
      'Hosea': 28, 'Joel': 29, 'Amos': 30, 'Obadiah': 31,
      'Jonah': 32, 'Micah': 33, 'Nahum': 34, 'Habakkuk': 35,
      'Zephaniah': 36, 'Haggai': 37, 'Zechariah': 38, 'Malachi': 39,
      'Matthew': 40, 'Mark': 41, 'Luke': 42, 'John': 43, 'Acts': 44,
      'Romans': 45, '1 Corinthians': 46, '2 Corinthians': 47,
      'Galatians': 48, 'Ephesians': 49, 'Philippians': 50,
      'Colossians': 51, '1 Thessalonians': 52, '2 Thessalonians': 53,
      '1 Timothy': 54, '2 Timothy': 55, 'Titus': 56, 'Philemon': 57,
      'Hebrews': 58, 'James': 59, '1 Peter': 60, '2 Peter': 61,
      '1 John': 62, '2 John': 63, '3 John': 64, 'Jude': 65,
      'Revelation': 66,
    };
    return map[bookName];
  }

  // ══════════════════════════════════════════════════════════════════════
  // All 66 Bible Books data
  // ══════════════════════════════════════════════════════════════════════
  static const List<BibleBook> allBooks = [
    // ── Old Testament ────────────────────────────────────────────────────
    BibleBook(id:1,  name:'Genesis',          nameTelugu:'ఆదికాండము',        chapters:50,  testament:'OT'),
    BibleBook(id:2,  name:'Exodus',           nameTelugu:'నిర్గమకాండము',       chapters:40,  testament:'OT'),
    BibleBook(id:3,  name:'Leviticus',        nameTelugu:'లేవీయకాండము',        chapters:27,  testament:'OT'),
    BibleBook(id:4,  name:'Numbers',          nameTelugu:'సంఖ్యాకాండము',        chapters:36,  testament:'OT'),
    BibleBook(id:5,  name:'Deuteronomy',      nameTelugu:'ద్వితీయోపదేశకాండము',   chapters:34,  testament:'OT'),
    BibleBook(id:6,  name:'Joshua',           nameTelugu:'యెహోషువ',            chapters:24,  testament:'OT'),
    BibleBook(id:7,  name:'Judges',           nameTelugu:'న్యాయాధిపతులు',       chapters:21,  testament:'OT'),
    BibleBook(id:8,  name:'Ruth',             nameTelugu:'రూతు',               chapters:4,   testament:'OT'),
    BibleBook(id:9,  name:'1 Samuel',         nameTelugu:'1 సమూయేలు',          chapters:31,  testament:'OT'),
    BibleBook(id:10, name:'2 Samuel',         nameTelugu:'2 సమూయేలు',          chapters:24,  testament:'OT'),
    BibleBook(id:11, name:'1 Kings',          nameTelugu:'1 రాజులు',            chapters:22,  testament:'OT'),
    BibleBook(id:12, name:'2 Kings',          nameTelugu:'2 రాజులు',            chapters:25,  testament:'OT'),
    BibleBook(id:13, name:'1 Chronicles',     nameTelugu:'1 దినవృత్తాంతములు',    chapters:29,  testament:'OT'),
    BibleBook(id:14, name:'2 Chronicles',     nameTelugu:'2 దినవృత్తాంతములు',    chapters:36,  testament:'OT'),
    BibleBook(id:15, name:'Ezra',             nameTelugu:'ఎజ్రా',               chapters:10,  testament:'OT'),
    BibleBook(id:16, name:'Nehemiah',         nameTelugu:'నెహెమ్యా',            chapters:13,  testament:'OT'),
    BibleBook(id:17, name:'Esther',           nameTelugu:'ఎస్తేరు',             chapters:10,  testament:'OT'),
    BibleBook(id:18, name:'Job',              nameTelugu:'యోబు',               chapters:42,  testament:'OT'),
    BibleBook(id:19, name:'Psalms',           nameTelugu:'కీర్తనలు',            chapters:150, testament:'OT'),
    BibleBook(id:20, name:'Proverbs',         nameTelugu:'సామెతలు',             chapters:31,  testament:'OT'),
    BibleBook(id:21, name:'Ecclesiastes',     nameTelugu:'ప్రసంగి',             chapters:12,  testament:'OT'),
    BibleBook(id:22, name:'Song of Solomon',  nameTelugu:'పరమగీతము',           chapters:8,   testament:'OT'),
    BibleBook(id:23, name:'Isaiah',           nameTelugu:'యెషయా',              chapters:66,  testament:'OT'),
    BibleBook(id:24, name:'Jeremiah',         nameTelugu:'యిర్మీయా',            chapters:52,  testament:'OT'),
    BibleBook(id:25, name:'Lamentations',     nameTelugu:'విలాపవాక్యములు',       chapters:5,   testament:'OT'),
    BibleBook(id:26, name:'Ezekiel',          nameTelugu:'యెహెఙ్కేలు',           chapters:48,  testament:'OT'),
    BibleBook(id:27, name:'Daniel',           nameTelugu:'దానియేలు',            chapters:12,  testament:'OT'),
    BibleBook(id:28, name:'Hosea',            nameTelugu:'హోషేయ',              chapters:14,  testament:'OT'),
    BibleBook(id:29, name:'Joel',             nameTelugu:'యోవేలు',              chapters:3,   testament:'OT'),
    BibleBook(id:30, name:'Amos',             nameTelugu:'ఆమోసు',              chapters:9,   testament:'OT'),
    BibleBook(id:31, name:'Obadiah',          nameTelugu:'ఓబద్యా',              chapters:1,   testament:'OT'),
    BibleBook(id:32, name:'Jonah',            nameTelugu:'యోనా',               chapters:4,   testament:'OT'),
    BibleBook(id:33, name:'Micah',            nameTelugu:'మీకా',               chapters:7,   testament:'OT'),
    BibleBook(id:34, name:'Nahum',            nameTelugu:'నహూము',              chapters:3,   testament:'OT'),
    BibleBook(id:35, name:'Habakkuk',         nameTelugu:'హబక్కూకు',            chapters:3,   testament:'OT'),
    BibleBook(id:36, name:'Zephaniah',        nameTelugu:'జెఫన్యా',             chapters:3,   testament:'OT'),
    BibleBook(id:37, name:'Haggai',           nameTelugu:'హగ్గయి',              chapters:2,   testament:'OT'),
    BibleBook(id:38, name:'Zechariah',        nameTelugu:'జెకర్యా',             chapters:14,  testament:'OT'),
    BibleBook(id:39, name:'Malachi',          nameTelugu:'మలాకీ',              chapters:4,   testament:'OT'),
    // ── New Testament ────────────────────────────────────────────────────
    BibleBook(id:40, name:'Matthew',          nameTelugu:'మత్తయి',              chapters:28,  testament:'NT'),
    BibleBook(id:41, name:'Mark',             nameTelugu:'మార్కు',              chapters:16,  testament:'NT'),
    BibleBook(id:42, name:'Luke',             nameTelugu:'లూకా',               chapters:24,  testament:'NT'),
    BibleBook(id:43, name:'John',             nameTelugu:'యోహాను',             chapters:21,  testament:'NT'),
    BibleBook(id:44, name:'Acts',             nameTelugu:'అపొస్తలుల కార్యములు', chapters:28,  testament:'NT'),
    BibleBook(id:45, name:'Romans',           nameTelugu:'రోమీయులకు',           chapters:16,  testament:'NT'),
    BibleBook(id:46, name:'1 Corinthians',    nameTelugu:'1 కొరింథీయులకు',       chapters:16,  testament:'NT'),
    BibleBook(id:47, name:'2 Corinthians',    nameTelugu:'2 కొరింథీయులకు',       chapters:13,  testament:'NT'),
    BibleBook(id:48, name:'Galatians',        nameTelugu:'గలతీయులకు',           chapters:6,   testament:'NT'),
    BibleBook(id:49, name:'Ephesians',        nameTelugu:'ఎఫెసీయులకు',          chapters:6,   testament:'NT'),
    BibleBook(id:50, name:'Philippians',      nameTelugu:'ఫిలిప్పీయులకు',        chapters:4,   testament:'NT'),
    BibleBook(id:51, name:'Colossians',       nameTelugu:'కొలొస్సయులకు',         chapters:4,   testament:'NT'),
    BibleBook(id:52, name:'1 Thessalonians',  nameTelugu:'1 థెస్సలొనీకయులకు',    chapters:5,   testament:'NT'),
    BibleBook(id:53, name:'2 Thessalonians',  nameTelugu:'2 థెస్సలొనీకయులకు',    chapters:3,   testament:'NT'),
    BibleBook(id:54, name:'1 Timothy',        nameTelugu:'1 తిమోతికి',          chapters:6,   testament:'NT'),
    BibleBook(id:55, name:'2 Timothy',        nameTelugu:'2 తిమోతికి',          chapters:4,   testament:'NT'),
    BibleBook(id:56, name:'Titus',            nameTelugu:'తీతుకు',              chapters:3,   testament:'NT'),
    BibleBook(id:57, name:'Philemon',         nameTelugu:'ఫిలేమోనుకు',          chapters:1,   testament:'NT'),
    BibleBook(id:58, name:'Hebrews',          nameTelugu:'హెబ్రీయులకు',          chapters:13,  testament:'NT'),
    BibleBook(id:59, name:'James',            nameTelugu:'యాకోబు',              chapters:5,   testament:'NT'),
    BibleBook(id:60, name:'1 Peter',          nameTelugu:'1 పేతురు',            chapters:5,   testament:'NT'),
    BibleBook(id:61, name:'2 Peter',          nameTelugu:'2 పేతురు',            chapters:3,   testament:'NT'),
    BibleBook(id:62, name:'1 John',           nameTelugu:'1 యోహాను',            chapters:5,   testament:'NT'),
    BibleBook(id:63, name:'2 John',           nameTelugu:'2 యోహాను',            chapters:1,   testament:'NT'),
    BibleBook(id:64, name:'3 John',           nameTelugu:'3 యోహాను',            chapters:1,   testament:'NT'),
    BibleBook(id:65, name:'Jude',             nameTelugu:'యూదా',               chapters:1,   testament:'NT'),
    BibleBook(id:66, name:'Revelation',       nameTelugu:'ప్రకటన గ్రంథము',       chapters:22,  testament:'NT'),
  ];
}
