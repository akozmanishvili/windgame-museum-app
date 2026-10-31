import 'dart:async';

import 'package:windgate_museum_app/auth/app_user.dart';
import 'package:windgate_museum_app/auth/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? initialUser}) : _current = initialUser;

  AppUser? _current;
  final StreamController<AppUser?> _changes =
      StreamController<AppUser?>.broadcast();

  AuthException? signInError;
  AuthException? signUpError;

  int signInCalls = 0;
  int signUpCalls = 0;
  int signOutCalls = 0;
  String? lastEmail;
  String? lastPassword;
  String? lastName;

  void _emit(AppUser? user) {
    _current = user;
    _changes.add(user);
  }

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _current;
    yield* _changes.stream;
  }

  @override
  AppUser? get currentUser => _current;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
    lastEmail = email;
    lastPassword = password;
    final error = signInError;
    if (error != null) throw error;
    _emit(AppUser(uid: 'uid-$email', email: email, displayName: 'Test Staff'));
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    signUpCalls++;
    lastName = name;
    lastEmail = email;
    lastPassword = password;
    final error = signUpError;
    if (error != null) throw error;
    _emit(AppUser(uid: 'uid-$email', email: email, displayName: name));
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    _emit(null);
  }
}

const testStaff = AppUser(
  uid: 'uid-1',
  email: 'jane.doe@hendrix.edu',
  displayName: 'Jane Doe',
);
