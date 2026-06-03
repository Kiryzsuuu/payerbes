import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/logger_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const _webClientId =
      '818865828200-REPLACE_WITH_WEB_CLIENT_ID.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn =
      kIsWeb ? GoogleSignIn(clientId: _webClientId) : GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool _loading = false;
  String? _error;
  bool get loading => _loading;
  String? get error => _error;

  // ── Google Sign-In ──────────────────────────────────────
  Future<bool> signInWithGoogle() async {
    if (kIsWeb) {
      _loading = true;
      _error = null;
      notifyListeners();
      try {
        final provider = GoogleAuthProvider();
        final result = await _auth.signInWithPopup(provider);
        AppLogger.login(result.user?.email ?? '-', 'Google (Web Popup)');
        _loading = false;
        notifyListeners();
        return true;
      } on FirebaseAuthException catch (e) {
        _error = e.message;
        _loading = false;
        notifyListeners();
        return false;
      }
    }

    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _loading = false;
        notifyListeners();
        return false;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      AppLogger.login(result.user?.email ?? '-', 'Google');
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Email & Password ────────────────────────────────────
  Future<bool> signInWithEmail(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      AppLogger.login(email, 'Email & Password');
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyError(e.code);
      AppLogger.info('Login GAGAL: $email | Alasan: ${e.code}');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithEmail(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      AppLogger.register(email);
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyError(e.code);
      AppLogger.info('Register GAGAL: $email | Alasan: ${e.code}');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.sendPasswordResetEmail(email: email);
      AppLogger.resetPassword(email);
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyError(e.code);
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshUser() async {
    await _auth.currentUser?.reload();
    notifyListeners();
  }

  Future<void> signOut() async {
    final email = _auth.currentUser?.email ?? '-';
    if (!kIsWeb) await _googleSignIn.signOut();
    await _auth.signOut();
    AppLogger.logout(email);
    notifyListeners();
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Password salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan.';
      case 'weak-password':
        return 'Password minimal 6 karakter.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      default:
        return 'Terjadi kesalahan. Coba lagi.';
    }
  }
}
