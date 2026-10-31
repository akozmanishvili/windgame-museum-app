import 'auth_config.dart';

String messageForAuthErrorCode(String code) {
  switch (code) {
    case 'invalid-email':
      return "That email address doesn't look right.";

    case 'invalid-credential':
    case 'INVALID_LOGIN_CREDENTIALS':
    case 'wrong-password':
    case 'user-not-found':
      return 'Incorrect email or password.';
    case 'user-disabled':
      return 'This account has been disabled. Contact the museum admin.';
    case 'email-already-in-use':
      return 'An account already exists for that email. Try logging in.';
    case 'weak-password':
      return 'That password is too weak. Use at least '
          '${AuthConfig.minPasswordLength} characters.';
    case 'too-many-requests':
      return 'Too many attempts. Wait a few minutes and try again.';
    case 'network-request-failed':
      return 'No internet connection. Check your connection and try again.';
    case 'operation-not-allowed':
      return 'Email/password sign-in is not turned on in Firebase yet.';
    default:
      return 'Something went wrong ($code). Please try again.';
  }
}
