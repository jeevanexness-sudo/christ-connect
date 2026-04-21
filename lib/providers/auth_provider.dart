import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService      _authSvc = AuthService.instance;
  final FirestoreService _dbSvc   = FirestoreService.instance;

  AuthStatus _status  = AuthStatus.unknown;
  UserModel? _user;
  String?    _error;
  bool       _loading = false;

  // ── Getters ───────────────────────────────────────────────────────────────
  AuthStatus get status     => _status;
  UserModel? get user       => _user;
  String?    get error      => _error;
  bool       get isLoading  => _loading;
  bool       get isLoggedIn => _status == AuthStatus.authenticated;

  AuthProvider() {
    _init();
  }

  // ── Init — listen to Firebase auth state ──────────────────────────────────
  void _init() {
    _authSvc.authStateChanges.listen((User? fbUser) async {
      if (fbUser == null) {
        _status = AuthStatus.unauthenticated;
        _user   = null;
      } else {
        _status  = AuthStatus.loading;
        notifyListeners();
        _user   = await _dbSvc.getUser(fbUser.uid);
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
    });
  }

  // ── Google Sign In ────────────────────────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    final result = await _authSvc.signInWithGoogle();
    _setLoading(false);

    if (result.success) {
      _user   = result.user;
      _status = AuthStatus.authenticated;
      _error  = null;
      notifyListeners();
      return true;
    } else if (!result.cancelled) {
      _error = result.error;
      notifyListeners();
    }
    return false;
  }

  // ── Phone OTP ─────────────────────────────────────────────────────────────
  String? _verificationId;

  Future<String?> sendOtp(String phone) async {
    _setLoading(true);
    String? errorMsg;

    await _authSvc.sendOtp(
      phone: phone,
      onCodeSent: (vid) {
        _verificationId = vid;
        _setLoading(false);
      },
      onError: (msg) {
        errorMsg = msg;
        _error   = msg;
        _setLoading(false);
      },
      onAutoVerify: (credential) async {
        await _verifyWithCredential(credential, phone);
      },
    );
    return errorMsg;
  }

  Future<bool> verifyOtp(String otp, String phone) async {
    if (_verificationId == null) {
      _error = 'Session expired. Request OTP again.';
      notifyListeners();
      return false;
    }
    _setLoading(true);
    final result = await _authSvc.verifyOtp(
      verificationId: _verificationId!,
      otp:   otp,
      phone: phone,
    );
    _setLoading(false);

    if (result.success) {
      _user   = result.user;
      _status = AuthStatus.authenticated;
      _error  = null;
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> _verifyWithCredential(
      PhoneAuthCredential credential, String phone) async {
    final result = await _authSvc.verifyOtp(
      verificationId: credential.verificationId ?? '',
      otp:   credential.smsCode ?? '',
      phone: phone,
    );
    if (result.success) {
      _user   = result.user;
      _status = AuthStatus.authenticated;
      _error  = null;
      notifyListeners();
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _authSvc.signOut();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    _error  = null;
    notifyListeners();
  }

  // ── Update user profile ───────────────────────────────────────────────────
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return;
    await _dbSvc.updateProfile(_user!.uid, data);
    _user = await _dbSvc.getUser(_user!.uid);
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
