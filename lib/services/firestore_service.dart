import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collection references ─────────────────────────────────────────────────
  CollectionReference get _users => _db.collection('users');

  // ── Create / Update user ──────────────────────────────────────────────────
  Future<void> saveUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toFirestore(), SetOptions(merge: true));
  }

  // ── Update last login ─────────────────────────────────────────────────────
  Future<void> updateLastLogin(String uid) async {
    await _users.doc(uid).update({
      'lastLogin': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ── Get user ──────────────────────────────────────────────────────────────
  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // ── Stream user (realtime) ────────────────────────────────────────────────
  Stream<UserModel?> userStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // ── Update profile ────────────────────────────────────────────────────────
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  // ── Check user exists ─────────────────────────────────────────────────────
  Future<bool> userExists(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.exists;
  }
}
