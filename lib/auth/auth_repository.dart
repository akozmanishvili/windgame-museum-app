import 'app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<void> signIn({required String email, required String password});

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();
}

class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;

  final String? code;

  @override
  String toString() => code == null ? message : '$message ($code)';
}
