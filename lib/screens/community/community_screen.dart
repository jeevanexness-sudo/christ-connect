import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/constants.dart';
import '../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════
// Community Screen — Real-time Firestore posts
// ════════════════════════════════════════════════════════════════════════════
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  // ── Firestore ─────────────────────────────────────────────────────────────
  final _col = FirebaseFirestore.instance
      .collection('posts')
      .withConverter<PostModel>(
        fromFirestore: (snap, _) => PostModel.fromFirestore(snap),
        toFirestore:   (post, _) => post.toFirestore(),
      );

  // ── Likes cache (local UI state) ──────────────────────────────────────────
  final Set<String> _likedIds = {};

  // ── Tab controller ─────────────────────────────────────────────────────────
  late final TabController _tabs = TabController(length: 3, vsync: this);
  int _activeTab = 0;

  static const _tabLabels = ['All', 'Prayer', 'Testimony'];

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // ── Firestore stream filtered by tab ──────────────────────────────────────
  Stream<QuerySnapshot<PostModel>> get _stream {
    Query<PostModel> q = _col.orderBy('createdAt', descending: true);
    if (_activeTab == 1) q = q.where('type', isEqualTo: 'prayer');
    if (_activeTab == 2) q = q.where('type', isEqualTo: 'testimony');
    return q.snapshots();
  }

  // ── Toggle like locally ───────────────────────────────────────────────────
  void _toggleLike(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      _likedIds.contains(id) ? _likedIds.remove(id) : _likedIds.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      floatingActionButton: _AddPostFAB(collection: _col),
      body: SafeArea(
        child: Column(children: [
          _Header(),
          _StatsBar(),
          _TabRow(
            tabs:      _tabLabels,
            activeIdx: _activeTab,
            onTap: (i) => setState(() {
              _activeTab = i;
              _tabs.animateTo(i);
            }),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: StreamBuilder<QuerySnapshot<PostModel>>(
              stream: _stream,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const _CenteredLoader();
                }
                if (snap.hasError) {
                  return _CenteredError(error: snap.error.toString());
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const _EmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(K.pad, 8, K.pad, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final post    = docs[i].data();
                    final isLiked = _likedIds.contains(post.id);
                    return _PostCard(
                      post:    post,
                      isLiked: isLiked,
                      onLike:  () => _toggleLike(post.id),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Data Model
// ════════════════════════════════════════════════════════════════════════════
class PostModel {
  final String    id;
  final String    userId;
  final String    userName;
  final String    message;
  final String    type;       // 'prayer' | 'testimony' | 'devotional'
  final Timestamp createdAt;
  final int       likes;

  const PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.likes,
  });

  factory PostModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return PostModel(
      id:        doc.id,
      userId:    d['userId']   ?? '',
      userName:  d['userName'] ?? 'Anonymous',
      message:   d['message']  ?? '',
      type:      d['type']     ?? 'prayer',
      createdAt: d['createdAt'] as Timestamp? ?? Timestamp.now(),
      likes:     d['likes']    ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId':    userId,
    'userName':  userName,
    'message':   message,
    'type':      type,
    'createdAt': createdAt,
    'likes':     likes,
  };

  // ── Helpers ───────────────────────────────────────────────────────────────
  String get initials {
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return userName.isNotEmpty ? userName[0].toUpperCase() : 'A';
  }

  String get timeAgo {
    final now  = DateTime.now();
    final then = createdAt.toDate();
    final diff = now.difference(then);
    if (diff.inSeconds < 60)  return 'Just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24)  return '${diff.inHours}h ago';
    if (diff.inDays    < 7)   return '${diff.inDays}d ago';
    return '${then.day}/${then.month}/${then.year}';
  }

  Color get typeColor {
    switch (type) {
      case 'prayer':     return AppColors.blue;
      case 'testimony':  return AppColors.success;
      case 'devotional': return AppColors.gold;
      default:           return AppColors.blue;
    }
  }

  String get typeLabel {
    switch (type) {
      case 'prayer':     return 'Prayer';
      case 'testimony':  return 'Testimony';
      case 'devotional': return 'Devotional';
      default:           return 'Prayer';
    }
  }

  String get typeEmoji {
    switch (type) {
      case 'prayer':     return '🙏';
      case 'testimony':  return '✨';
      case 'devotional': return '📖';
      default:           return '🙏';
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Header
// ════════════════════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(K.pad, 14, K.pad, 10),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Community', style: AppTextStyles.heading1),
          Text('Pray  ·  Share  ·  Encourage', style: AppTextStyles.caption),
        ])),
        CCIconBtn(icon: Icons.search_rounded),
        const SizedBox(width: 8),
        CCIconBtn(icon: Icons.notifications_outlined),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Stats Bar — live count from Firestore
// ════════════════════════════════════════════════════════════════════════════
class _StatsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (ctx, snap) {
        final docs  = snap.data?.docs ?? [];
        final total = docs.length;
        final prayers    = docs.where((d) => (d.data() as Map)['type'] == 'prayer').length;
        final testimonies = docs.where((d) => (d.data() as Map)['type'] == 'testimony').length;

        return Padding(
          padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 12),
          child: Row(children: [
            Expanded(child: _StatBox(number: '$total',       label: 'Posts')),
            const SizedBox(width: 10),
            Expanded(child: _StatBox(number: '$prayers',     label: 'Prayers')),
            const SizedBox(width: 10),
            Expanded(child: _StatBox(number: '$testimonies', label: 'Testimonies')),
          ]),
        );
      },
    );
  }
}

class _StatBox extends StatelessWidget {
  final String number;
  final String label;
  const _StatBox({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Text(number, style: AppTextStyles.goldHeading.copyWith(fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.overline),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Tab Row
// ════════════════════════════════════════════════════════════════════════════
class _TabRow extends StatelessWidget {
  final List<String> tabs;
  final int          activeIdx;
  final void Function(int) onTap;
  const _TabRow({required this.tabs, required this.activeIdx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(K.pad, 0, K.pad, 0),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == activeIdx;
          return Padding(
            padding: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color:        active ? AppColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? AppColors.gold : AppColors.border2),
                ),
                child: Text(
                  tabs[i],
                  style: GoogleFonts.nunito(
                    fontSize:   12,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.black : AppColors.muted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Post Card
// ════════════════════════════════════════════════════════════════════════════
class _PostCard extends StatelessWidget {
  final PostModel post;
  final bool      isLiked;
  final VoidCallback onLike;
  const _PostCard({required this.post, required this.isLiked, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final isOwn = post.userId == FirebaseAuth.instance.currentUser?.uid;

    return Container(
      decoration: BoxDecoration(
        color:        AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOwn ? AppColors.gold.withOpacity(0.25) : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Author row ────────────────────────────────────────────────────
          Row(children: [
            // Avatar
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color:  post.typeColor.withOpacity(0.18),
                shape:  BoxShape.circle,
                border: Border.all(color: post.typeColor.withOpacity(0.4)),
              ),
              child: Center(
                child: Text(post.initials,
                  style: GoogleFonts.nunito(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    color: post.typeColor,
                  )),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(
                    child: Text(post.userName,
                      style: AppTextStyles.cardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isOwn) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('You',
                        style: AppTextStyles.badge.copyWith(color: AppColors.gold, fontSize: 9)),
                    ),
                  ],
                ]),
                Text(post.timeAgo,
                  style: AppTextStyles.cardSubtitle.copyWith(fontSize: 10)),
              ]),
            ),
            // Type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:        post.typeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${post.typeEmoji} ${post.typeLabel}',
                style: AppTextStyles.badge.copyWith(color: post.typeColor, fontSize: 10),
              ),
            ),
          ]),

          const SizedBox(height: 12),

          // ── Message ───────────────────────────────────────────────────────
          Text(post.message,
            style: AppTextStyles.body1.copyWith(fontSize: 14, height: 1.6)),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // ── Actions ───────────────────────────────────────────────────────
          Row(children: [
            // Like
            GestureDetector(
              onTap: onLike,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:        isLiked
                      ? AppColors.danger.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isLiked
                        ? AppColors.danger.withOpacity(0.3)
                        : AppColors.border,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isLiked ? AppColors.danger : AppColors.muted,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${post.likes + (isLiked ? 1 : 0)}',
                    style: AppTextStyles.caption.copyWith(
                      color: isLiked ? AppColors.danger : AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            // Pray
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:        AppColors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border:       Border.all(color: AppColors.blue.withOpacity(0.25)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('🙏', style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text('Praying',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.blue, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            const Spacer(),
            // Share
            GestureDetector(
              onTap: () {},
              child: Icon(Icons.share_outlined, color: AppColors.muted, size: 18),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Add Post FAB — opens bottom sheet
// ════════════════════════════════════════════════════════════════════════════
class _AddPostFAB extends StatelessWidget {
  final CollectionReference<PostModel> collection;
  const _AddPostFAB({required this.collection});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddPostSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.blueGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color:       AppColors.blue.withOpacity(0.35),
              blurRadius:  16,
              offset:      const Offset(0, 4),
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 6),
          Text('Post', style: AppTextStyles.buttonSecondary.copyWith(fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  void _showAddPostSheet(BuildContext context) {
    showModalBottomSheet(
      context:        context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPostSheet(collection: collection),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Add Post Bottom Sheet
// ════════════════════════════════════════════════════════════════════════════
class _AddPostSheet extends StatefulWidget {
  final CollectionReference<PostModel> collection;
  const _AddPostSheet({required this.collection});

  @override
  State<_AddPostSheet> createState() => _AddPostSheetState();
}

class _AddPostSheetState extends State<_AddPostSheet> {
  final _ctrl      = TextEditingController();
  String _type     = 'prayer';
  bool   _posting  = false;
  String? _error;

  static const _types = [
    ('prayer',     '🙏 Prayer Request', AppColors.blue),
    ('testimony',  '✨ Testimony',       AppColors.success),
    ('devotional', '📖 Devotional',      AppColors.gold),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Please write something.');
      return;
    }
    if (text.length < 10) {
      setState(() => _error = 'Post must be at least 10 characters.');
      return;
    }

    setState(() { _posting = true; _error = null; });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final name = user?.displayName ??
          (user?.phoneNumber != null ? 'Phone User' : 'Anonymous');

      await widget.collection.add(PostModel(
        id:        '',
        userId:    user?.uid  ?? '',
        userName:  name,
        message:   text,
        type:      _type,
        createdAt: Timestamp.now(),
        likes:     0,
      ));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error   = 'Failed to post. Please try again.';
        _posting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border:       Border.all(color: AppColors.border2),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Handle bar
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color:        AppColors.muted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text('Share with the Community', style: AppTextStyles.heading3),
        const SizedBox(height: 4),
        Text('Your post will be visible to all believers', style: AppTextStyles.caption),
        const SizedBox(height: 20),

        // Type selector
        Text('POST TYPE', style: AppTextStyles.overline),
        const SizedBox(height: 8),
        Row(
          children: _types.map((t) {
            final isActive = _type == t.$1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: t.$1 != 'devotional' ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _type = t.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color:        isActive ? t.$3.withOpacity(0.15) : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:  isActive ? t.$3 : AppColors.border,
                        width:  isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Text(t.$2,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize:   10,
                        fontWeight: FontWeight.w700,
                        color: isActive ? t.$3 : AppColors.muted,
                      )),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Text input
        Text('YOUR MESSAGE', style: AppTextStyles.overline),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color:        AppColors.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _error != null ? AppColors.danger : AppColors.border,
            ),
          ),
          child: TextField(
            controller:   _ctrl,
            maxLines:     5,
            maxLength:    500,
            style: GoogleFonts.nunito(color: AppColors.white, fontSize: 14, height: 1.6),
            decoration: InputDecoration(
              hintText:       'Share a prayer request, testimony, or word of encouragement…',
              hintStyle:      GoogleFonts.nunito(color: AppColors.muted, fontSize: 13, height: 1.5),
              border:         InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
              counterStyle:   GoogleFonts.nunito(color: AppColors.muted, fontSize: 10),
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ),

        // Error
        if (_error != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 14),
            const SizedBox(width: 6),
            Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
          ]),
        ],

        const SizedBox(height: 16),

        // Submit button
        GestureDetector(
          onTap: _posting ? null : _post,
          child: Container(
            width:   double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient:     AppColors.blueGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color:      AppColors.blue.withOpacity(0.3),
                  blurRadius: 12, offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _posting
                ? const Center(child: SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Post to Community',
                      style: AppTextStyles.bodyBold.copyWith(fontSize: 14)),
                  ]),
          ),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Empty / Loading / Error states
// ════════════════════════════════════════════════════════════════════════════
class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2.5));
}

class _CenteredError extends StatelessWidget {
  final String error;
  const _CenteredError({required this.error});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded, color: AppColors.muted, size: 48),
        const SizedBox(height: 12),
        Text('Connection error', style: AppTextStyles.heading3),
        const SizedBox(height: 6),
        Text(error, style: AppTextStyles.body2, textAlign: TextAlign.center),
      ]),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
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
          child: const Center(child: Text('🙏', style: TextStyle(fontSize: 34))),
        ),
        const SizedBox(height: 16),
        Text('No posts yet', style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        Text('Be the first to share a prayer\nor testimony with the community!',
          style: AppTextStyles.body2, textAlign: TextAlign.center),
      ]),
    ),
  );
}
