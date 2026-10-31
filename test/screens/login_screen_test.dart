import 'package:flutter_test/flutter_test.dart';
import 'package:windgate_museum_app/auth/auth_repository.dart';
import 'package:windgate_museum_app/screens/auth/login_screen.dart';
import 'package:windgate_museum_app/screens/auth/sign_up_screen.dart';

import '../fakes/fake_auth_repository.dart';
import '../helpers.dart';

void main() {
  late FakeAuthRepository auth;

  setUp(() => auth = FakeAuthRepository());

  Future<void> pumpLogin(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(wrapInApp(LoginScreen(authRepository: auth)));
  }

  testWidgets('shows email, password, Log In and Sign Up', (tester) async {
    await pumpLogin(tester);

    expect(find.byKey(LoginScreen.emailFieldKey), findsOneWidget);
    expect(find.byKey(LoginScreen.passwordFieldKey), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);
    expect(find.text('SIGN UP'), findsOneWidget);
  });

  testWidgets('empty form shows errors and does not call Firebase', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tapAndSettle(tester, find.byKey(LoginScreen.loginButtonKey));

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(auth.signInCalls, 0);
  });

  testWidgets('invalid email format is caught before submitting', (
    tester,
  ) async {
    await pumpLogin(tester);

    await enterField(tester, LoginScreen.emailFieldKey, 'not-an-email');
    await enterField(tester, LoginScreen.passwordFieldKey, 'password123');
    await tapAndSettle(tester, find.byKey(LoginScreen.loginButtonKey));

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(auth.signInCalls, 0);
  });

  testWidgets('non-staff email is rejected', (tester) async {
    await pumpLogin(tester);

    await enterField(tester, LoginScreen.emailFieldKey, 'someone@gmail.com');
    await enterField(tester, LoginScreen.passwordFieldKey, 'password123');
    await tapAndSettle(tester, find.byKey(LoginScreen.loginButtonKey));

    expect(
      find.text('Use your museum staff email (@hendrix.edu)'),
      findsOneWidget,
    );
    expect(auth.signInCalls, 0);
  });

  testWidgets('short password is caught before submitting', (tester) async {
    await pumpLogin(tester);

    await enterField(tester, LoginScreen.emailFieldKey, 'jane@hendrix.edu');
    await enterField(tester, LoginScreen.passwordFieldKey, 'short');
    await tapAndSettle(tester, find.byKey(LoginScreen.loginButtonKey));

    expect(find.textContaining('at least'), findsOneWidget);
    expect(auth.signInCalls, 0);
  });

  testWidgets('valid form signs in with trimmed email', (tester) async {
    await pumpLogin(tester);

    await enterField(tester, LoginScreen.emailFieldKey, '  jane@hendrix.edu ');
    await enterField(tester, LoginScreen.passwordFieldKey, 'password123');
    await tapAndSettle(tester, find.byKey(LoginScreen.loginButtonKey));

    expect(auth.signInCalls, 1);
    expect(auth.lastEmail, 'jane@hendrix.edu');
    expect(auth.lastPassword, 'password123');
  });

  testWidgets('wrong login shows the error message', (tester) async {
    auth.signInError = const AuthException(
      'Incorrect email or password.',
      code: 'invalid-credential',
    );
    await pumpLogin(tester);

    await enterField(tester, LoginScreen.emailFieldKey, 'jane@hendrix.edu');
    await enterField(tester, LoginScreen.passwordFieldKey, 'wrongpass1');
    await tapAndSettle(tester, find.byKey(LoginScreen.loginButtonKey));

    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);
  });

  testWidgets('Sign Up button opens the sign up screen', (tester) async {
    await pumpLogin(tester);

    await tapAndSettle(tester, find.byKey(LoginScreen.signUpButtonKey));

    expect(find.byType(SignUpScreen), findsOneWidget);
  });
}
