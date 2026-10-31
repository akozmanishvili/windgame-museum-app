import 'package:flutter_test/flutter_test.dart';
import 'package:windgate_museum_app/app.dart';
import 'package:windgate_museum_app/auth/app_user.dart';
import 'package:windgate_museum_app/screens/auth/login_screen.dart';
import 'package:windgate_museum_app/screens/auth/sign_up_screen.dart';
import 'package:windgate_museum_app/screens/search/search_screen.dart';

import '../fakes/fake_auth_repository.dart';
import '../helpers.dart';

void main() {
  Future<FakeAuthRepository> startApp(
    WidgetTester tester, {
    AppUser? initialUser,
  }) async {
    usePhoneScreen(tester);
    final auth = FakeAuthRepository(initialUser: initialUser);
    await tester.pumpWidget(WindgateApp(authRepository: auth));
    await tester.pumpAndSettle();
    return auth;
  }

  testWidgets('logged out -> Login screen', (tester) async {
    await startApp(tester);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('already logged in -> straight to Search', (tester) async {
    await startApp(tester, initialUser: testStaff);
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.text('Welcome, Jane Doe'), findsOneWidget);
  });

  testWidgets('logging in moves from Login to Search', (tester) async {
    await startApp(tester);

    await enterField(tester, LoginScreen.emailFieldKey, 'jane@hendrix.edu');
    await enterField(tester, LoginScreen.passwordFieldKey, 'password123');
    await tapAndSettle(tester, find.byKey(LoginScreen.loginButtonKey));

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(SearchScreen), findsOneWidget);
  });

  testWidgets('Log Out on Search goes back to Login', (tester) async {
    final auth = await startApp(tester, initialUser: testStaff);

    await tapAndSettle(tester, find.byKey(SearchScreen.logoutButtonKey));

    expect(auth.signOutCalls, 1);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('signing up goes straight to Search', (tester) async {
    await startApp(tester);

    await tapAndSettle(tester, find.byKey(LoginScreen.signUpButtonKey));
    await enterField(tester, SignUpScreen.nameFieldKey, 'Jane Doe');
    await enterField(tester, SignUpScreen.emailFieldKey, 'jane@hendrix.edu');
    await enterField(tester, SignUpScreen.passwordFieldKey, 'password123');
    await enterField(
      tester,
      SignUpScreen.confirmPasswordFieldKey,
      'password123',
    );
    await tapAndSettle(tester, find.byKey(SignUpScreen.submitButtonKey));

    expect(find.byType(SignUpScreen), findsNothing);
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.text('Welcome, Jane Doe'), findsOneWidget);
  });
}
