import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth    _auth   = FirebaseAuth.instance;
  final GoogleSignIn    _google = GoogleSignIn();
  final FirestoreService _db    = FirestoreService.instance;

  // ── Current user stream ───────────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User?         get currentUser      => _auth.currentUser;

  // ══════════════════════════════════════════════════════════════════════════
  // GOOGLE SIGN IN
  // ══════════════════════════════════════════════════════════════════════════
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await _google.signIn();
      if (gUser == null) return AuthResult.cancelled();

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken:     gAuth.idToken,
      );

      final UserCredential userCred =
          await _auth.signInWithCredential(credential);
      final User fbUser = userCred.user!;

      // Save to Firestore
      final isNew = userCred.additionalUserInfo?.isNewUser ?? false;
      final userModel = UserModel(
        uid:         fbUser.uid,
        name:        fbUser.displayName ?? 'Believer',
        email:       fbUser.email       ?? '',
        phone:       fbUser.phoneNumber,
        photoUrl:    fbUser.photoURL,
        createdAt:   isNew ? DateTime.now() : (await _db.getUser(fbUser.uid))?.createdAt ?? DateTime.now(),
        lastLogin:   DateTime.now(),
        isVerified:  fbUser.emailVerified,
        loginMethod: 'google',
      );

      await _db.saveUser(userModel);
      return AuthResult.success(userModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_authError(e.code));
    } catch (e) {
      return AuthResult.error('Something went wrong. Please try again.');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PHONE OTP
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> sendOtp({
    required String phone,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    required void Function(PhoneAuthCredential) onAutoVerify,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber:       phone,
      timeout:           const Duration(seconds: 60),
      verificationCompleted: onAutoVerify,
      verificationFailed: (FirebaseAuthException e) {
        onError(_authError(e.code));
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<AuthResult> verifyOtp({
    required String verificationId,
    required String otp,
    required String phone,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode:        otp,
      );
      final UserCredential userCred =
          await _auth.signInWithCredential(credential);
      final User fbUser = userCred.user!;

      final isNew = userCred.additionalUserInfo?.isNewUser ?? false;
      final existing = isNew ? null : await _db.getUser(fbUser.uid);

      final userModel = UserModel(
        uid:         fbUser.uid,
        name:        existing?.name ?? 'Believer',
        email:       existing?.email ?? '',
        phone:       phone,
        photoUrl:    existing?.photoUrl,
        createdAt:   existing?.createdAt ?? DateTime.now(),
        lastLogin:   DateTime.now(),
        isVerified:  true,
        loginMethod: 'phone',
      );

      await _db.saveUser(userModel);
      return AuthResult.success(userModel);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_authError(e.code));
    } catch (e) {
      return AuthResult.error('Verification failed. Please try again.');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SIGN OUT
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _google.signOut(),
    ]);
  }

  // ── Error messages ────────────────────────────────────────────────────────
  String _authError(String code) {
    switch (code) {
      case 'invalid-phone-number':    return 'Invalid phone number format.';
      case 'invalid-verification-code': return 'Wrong OTP. Please try again.';
      case 'code-expired':            return 'OTP expired. Request a new one.';
      case 'too-many-requests':       return 'Too many attempts. Try later.';
      case 'network-request-failed':  return 'No internet connection.';
      case 'account-exists-with-different-credential':
        return 'Account exists with another sign-in method.';
      case 'sign_in_canceled':        return 'Sign in cancelled.';
      default:                        return 'Authentication failed. Please try again.';
    }
  }
}

// ── Auth Result model ─────────────────────────────────────────────────────
class AuthResult {
  final bool        success;
  final UserModel?  user;
  final String?     error;
  final bool        cancelled;

  const AuthResult._({
    required this.success,
    this.user,
    this.error,
    this.cancelled = false,
  });

  factory AuthResult.success(UserModel user) =>
      AuthResult._(success: true, user: user);
  factory AuthResult.error(String msg) =>
      AuthResult._(success: false, error: msg);
  factory AuthResult.cancelled() =>
      AuthResult._(success: false, cancelled: true);
}
