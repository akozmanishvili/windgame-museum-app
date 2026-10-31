import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windgate_museum_app/auth/auth_repository.dart';
import 'package:windgate_museum_app/screens/auth/sign_up_screen.dart';

import '../fakes/fake_auth_repository.dart';
import '../helpers.dart';

void main() {
  late FakeAuthRepository auth;

  setUp(() => auth = FakeAuthRepository());

  Future<void> openSignUp(WidgetTester tester) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      wrapInApp(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SignUpScreen(authRepository: auth),
                  ),
                ),
                child: const Text('root'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('root'));
    await tester.pumpAndSettle();
  }

  Future<void> fillForm(
    WidgetTester tester, {
    String name = 'Jane Doe',
    String email = 'jane.doe@hendrix.edu',
    String password = 'password123',
    String? confirm,
  }) async {
    await enterField(tester, SignUpScreen.nameFieldKey, name);
    await enterField(tester, SignUpScreen.emailFieldKey, email);
    await enterField(tester, SignUpScreen.passwordFieldKey, password);
    await enterField(
      tester,
      SignUpScreen.confirmPasswordFieldKey,
      confirm ?? password,
    );
  }

  Future<void> submit(WidgetTester tester) =>
      tapAndSettle(tester, find.byKey(SignUpScreen.submitButtonKey));

  testWidgets('has a back button to return to login', (tester) async {
    await openSignUp(tester);

    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(SignUpScreen), findsNothing);
  });

  testWidgets('empty form shows all required-field errors', (tester) async {
    await openSignUp(tester);

    await submit(tester);

    expect(find.text('Enter your name'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(find.text('Re-enter your password'), findsOneWidget);
    expect(auth.signUpCalls, 0);
  });

  testWidgets('non-staff email cannot sign up', (tester) async {
    await openSignUp(tester);

    await fillForm(tester, email: 'jane@gmail.com');
    await submit(tester);

    expect(
      find.text('Use your museum staff email (@hendrix.edu)'),
      findsOneWidget,
    );
    expect(auth.signUpCalls, 0);
  });

  testWidgets('mismatched passwords are caught', (tester) async {
    await openSignUp(tester);

    await fillForm(tester, confirm: 'different123');
    await submit(tester);

    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(auth.signUpCalls, 0);
  });

  testWidgets('valid form creates the account and closes the screen', (
    tester,
  ) async {
    await openSignUp(tester);

    await fillForm(tester, name: '  Jane Doe ', email: ' jane.doe@hendrix.edu');
    await submit(tester);

    expect(auth.signUpCalls, 1);
    expect(auth.lastName, 'Jane Doe');
    expect(auth.lastEmail, 'jane.doe@hendrix.edu');
    expect(auth.lastPassword, 'password123');
    expect(find.byType(SignUpScreen), findsNothing);
  });

  testWidgets('Firebase error is shown and the screen stays open', (
    tester,
  ) async {
    auth.signUpError = const AuthException(
      'An account already exists for that email. Try logging in.',
      code: 'email-already-in-use',
    );
    await openSignUp(tester);

    await fillForm(tester);
    await submit(tester);

    expect(find.textContaining('already exists'), findsOneWidget);
    expect(find.byType(SignUpScreen), findsOneWidget);
  });
}
