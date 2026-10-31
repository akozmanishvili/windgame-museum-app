import 'package:firebase_auth/firebase_auth.dart';

import 'app_user.dart';
import 'auth_config.dart';
import 'auth_errors.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  @override
  Stream<AppUser?> authStateChanges() => _auth.userChanges().map(_toAppUser);

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Future<void> signIn({required String email, required String password}) async {
    _checkStaffEmail(email);
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(messageForAuthErrorCode(e.code), code: e.code);
    }
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _checkStaffEmail(email);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(messageForAuthErrorCode(e.code), code: e.code);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  void _checkStaffEmail(String email) {
    if (!AuthConfig.isAllowedStaffEmail(email)) {
      throw AuthException(
        'Only museum staff emails (${AuthConfig.allowedDomainsLabel}) can use this app.',
        code: 'domain-not-allowed',
      );
    }
  }
}
