import 'package:flutter_test/flutter_test.dart';
import 'package:windgate_museum_app/auth/auth_config.dart';
import 'package:windgate_museum_app/auth/validators.dart';

void main() {
  group('Validators.email', () {
    test('empty email asks for an email', () {
      expect(Validators.email(''), 'Enter your email');
      expect(Validators.email('   '), 'Enter your email');
      expect(Validators.email(null), 'Enter your email');
    });

    test('badly formatted email is rejected', () {
      for (final bad in ['jane', 'jane@', '@hendrix.edu', 'jane@hendrix', 'ja ne@hendrix.edu']) {
        expect(Validators.email(bad), 'Enter a valid email address', reason: bad);
      }
    });

    test('well formatted email passes', () {
      expect(Validators.email('jane.doe@hendrix.edu'), isNull);
      expect(Validators.email('  jane.doe@hendrix.edu  '), isNull);
    });
  });

  group('Validators.staffEmail', () {
    test('non-staff domain is rejected', () {
      expect(Validators.staffEmail('jane@gmail.com'), contains('staff email'));
    });

    test('staff domain passes, ignoring case and spaces', () {
      expect(Validators.staffEmail(' Jane.Doe@Hendrix.EDU '), isNull);
    });

    test('format errors come before domain errors', () {
      expect(Validators.staffEmail('jane'), 'Enter a valid email address');
    });
  });

  group('AuthConfig.isAllowedStaffEmail', () {
    test('rejects look-alike domains', () {
      expect(AuthConfig.isAllowedStaffEmail('a@hendrix.edu.evil.com'), isFalse);
      expect(AuthConfig.isAllowedStaffEmail('a@nothendrix.edu'), isFalse);
      expect(AuthConfig.isAllowedStaffEmail('a@sub.hendrix.edu'), isFalse);
      expect(AuthConfig.isAllowedStaffEmail('hendrix.edu'), isFalse);
      expect(AuthConfig.isAllowedStaffEmail('a@'), isFalse);
    });

    test('accepts the staff domain', () {
      expect(AuthConfig.isAllowedStaffEmail('a@hendrix.edu'), isTrue);
    });
  });

  group('Validators.password', () {
    test('empty password', () {
      expect(Validators.password(''), 'Enter your password');
      expect(Validators.password(null), 'Enter your password');
    });

    test('too short password', () {
      final short = 'a' * (AuthConfig.minPasswordLength - 1);
      expect(Validators.password(short), contains('at least'));
    });

    test('long enough password passes', () {
      final ok = 'a' * AuthConfig.minPasswordLength;
      expect(Validators.password(ok), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('must match', () {
      expect(Validators.confirmPassword('abcdefgh', 'abcdefgX'),
          'Passwords do not match');
      expect(Validators.confirmPassword('abcdefgh', 'abcdefgh'), isNull);
    });

    test('must not be empty', () {
      expect(Validators.confirmPassword('', 'abcdefgh'), 'Re-enter your password');
    });
  });

  group('Validators.name', () {
    test('blank name is rejected', () {
      expect(Validators.name('   '), 'Enter your name');
    });

    test('real name passes', () {
      expect(Validators.name('Jane Doe'), isNull);
    });
  });
}
