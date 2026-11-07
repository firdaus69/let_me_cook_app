import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:let_me_cook/app.dart';

import 'support/fake_api.dart';

Future<FakeApi> _pumpApp(WidgetTester tester, {FakeApi? api}) async {
  api ??= FakeApi();
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(overrides: api.overrides, child: const LetMeCookApp()),
  );
  await tester.pumpAndSettle();
  return api;
}

Future<void> _logIn(WidgetTester tester, {bool signUp = false}) async {
  await tester.tap(find.text('Profile'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
  await tester.pumpAndSettle();
  if (signUp) {
    await tester.tap(find.widgetWithText(TextButton, 'Sign up'));
    await tester.pumpAndSettle();
  }
  await tester.enterText(find.byType(TextFormField).at(0), 'chef@cook.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
  await tester.tap(
    find.widgetWithText(FilledButton, signUp ? 'Sign up' : 'Log in'),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Home shows the fridge card, suggestions and popular list', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('What are we cooking today?'), findsOneWidget);
    expect(find.text('Cook from your fridge'), findsOneWidget);
    expect(find.text('Suggested for you'), findsOneWidget);
    expect(find.text('5 picks based on Malaysia'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Cendol'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Popular in Malaysia'), findsOneWidget);
    expect(find.text('Chicken Rendang'), findsOneWidget);
  });

  testWidgets('Fridge flow: pick ingredients and see matching recipes', (
    tester,
  ) async {
    await _pumpApp(tester);

    await _tapVisible(tester, find.text('Open my fridge'));
    expect(find.text("What's in your fridge?"), findsOneWidget);
    expect(find.text('Pick at least 1 ingredient'), findsOneWidget);

    for (final name in ['Eggs', 'Onion', 'Chili']) {
      await _tapVisible(tester, find.text(name));
    }
    expect(find.text('3 ingredients selected'), findsOneWidget);

    await tester.tap(find.text('Find recipes'));
    await tester.pumpAndSettle();

    expect(find.text('Recipes you can make'), findsOneWidget);
    expect(find.text('Ready to cook'), findsOneWidget);
    expect(find.text('Telur Dadar Bawang'), findsOneWidget);
    expect(find.text('Almost there'), findsOneWidget);
  });

  testWidgets('Saving a popular recipe shows it in the Saved tab', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.scrollUntilVisible(
      find.text('Chicken Rendang'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await _tapVisible(tester, find.byTooltip('Save recipe').first);
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    expect(find.text('Chicken Rendang'), findsOneWidget);
  });

  testWidgets('Login from the Profile tab', (tester) async {
    await _pumpApp(tester);
    await _logIn(tester);

    expect(find.text('chef@cook.com'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('Wrong password shows the server error', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'chef@cook.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'short');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password'), findsOneWidget);
  });

  testWidgets('Recipes saved before signing up are kept on the server', (
    tester,
  ) async {
    final api = await _pumpApp(tester);

    await tester.scrollUntilVisible(
      find.text('Chicken Rendang'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await _tapVisible(tester, find.byTooltip('Save recipe').first);
    await _logIn(tester, signUp: true);

    expect(api.saved['chef@cook.com'], ['chicken-rendang']);
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Chicken Rendang'), findsOneWidget);
  });

  testWidgets('Home offers Retry when the server is unreachable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: FakeApi(offline: true).overrides,
        retry: (_, _) => null,
        child: const LetMeCookApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Popular in Malaysia'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining("Can't reach the server"), findsWidgets);
    expect(find.text('Retry'), findsWidgets);
  });
}
