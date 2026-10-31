import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windgate_museum_app/theme/app_theme.dart';

Widget wrapInApp(Widget child) {
  return MaterialApp(theme: AppTheme.dark(), home: child);
}

void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
}

Future<void> enterField(WidgetTester tester, Key key, String text) {
  return tester.enterText(find.byKey(key), text);
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
