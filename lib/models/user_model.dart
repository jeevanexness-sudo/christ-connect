import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String? denomination;
  final String? location;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool isVerified;
  final String loginMethod; // 'google' | 'phone' | 'email'

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.denomination,
    this.location,
    required this.createdAt,
    required this.lastLogin,
    this.isVerified = false,
    required this.loginMethod,
  });

  // ── From Firestore ────────────────────────────────────────────────────────
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid:         doc.id,
      name:        data['name']        ?? '',
      email:       data['email']       ?? '',
      phone:       data['phone'],
      photoUrl:    data['photoUrl'],
      denomination: data['denomination'],
      location:    data['location'],
      createdAt:   (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin:   (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified:  data['isVerified'] ?? false,
      loginMethod: data['loginMethod'] ?? 'email',
    );
  }

  // ── To Firestore ──────────────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'name':        name,
      'email':       email,
      'phone':       phone,
      'photoUrl':    photoUrl,
      'denomination': denomination,
      'location':    location,
      'createdAt':   Timestamp.fromDate(createdAt),
      'lastLogin':   Timestamp.fromDate(lastLogin),
      'isVerified':  isVerified,
      'loginMethod': loginMethod,
    };
  }

  // ── CopyWith ──────────────────────────────────────────────────────────────
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? denomination,
    String? location,
    DateTime? lastLogin,
    bool? isVerified,
  }) {
    return UserModel(
      uid:         uid,
      name:        name        ?? this.name,
      email:       email       ?? this.email,
      phone:       phone       ?? this.phone,
      photoUrl:    photoUrl    ?? this.photoUrl,
      denomination: denomination ?? this.denomination,
      location:    location    ?? this.location,
      createdAt:   createdAt,
      lastLogin:   lastLogin   ?? this.lastLogin,
      isVerified:  isVerified  ?? this.isVerified,
      loginMethod: loginMethod,
    );
  }

  // ── Display helpers ───────────────────────────────────────────────────────
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String get displayName => name.isNotEmpty ? name : 'Believer';

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, email: $email)';
}
