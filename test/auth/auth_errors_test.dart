import 'package:flutter_test/flutter_test.dart';
import 'package:windgate_museum_app/auth/auth_errors.dart';

void main() {
  test('all wrong-login codes give the same message', () {
    for (final code in [
      'invalid-credential',
      'INVALID_LOGIN_CREDENTIALS',
      'wrong-password',
      'user-not-found',
    ]) {
      expect(messageForAuthErrorCode(code), 'Incorrect email or password.',
          reason: code);
    }
  });

  test('existing account on sign up', () {
    expect(messageForAuthErrorCode('email-already-in-use'),
        contains('already exists'));
  });

  test('no internet', () {
    expect(messageForAuthErrorCode('network-request-failed'),
        contains('internet'));
  });

  test('unknown code still shows a message with the code', () {
    expect(messageForAuthErrorCode('something-new'), contains('something-new'));
  });
}
