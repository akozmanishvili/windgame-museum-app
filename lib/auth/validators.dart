import 'auth_config.dart';

class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your email';
    if (!_emailPattern.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? staffEmail(String? value) {
    final formatError = email(value);
    if (formatError != null) return formatError;
    if (!AuthConfig.isAllowedStaffEmail(value!)) {
      return 'Use your museum staff email (${AuthConfig.allowedDomainsLabel})';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Enter your password';
    if (v.length < AuthConfig.minPasswordLength) {
      return 'Password must be at least ${AuthConfig.minPasswordLength} characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Re-enter your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? name(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Enter your name';
    return null;
  }
}
