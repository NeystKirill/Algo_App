import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:algo_learning_app/features/algorithms/algorithms_provider.dart';
import 'package:algo_learning_app/features/algorithms/registry.dart';
import 'package:algo_learning_app/features/home/home_screen.dart';

void main() {
  // The app is gated behind auth (login/register → profile → the app
  // itself), so HomeScreen is only ever reached once signed in. Pumping it
  // directly — rather than through AlgoLearningApp's router — keeps this
  // test focused on the home screen and avoids needing a real Supabase
  // client just to get past the auth gate.
  testWidgets('Home screen shows category list', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [algorithmsProvider.overrideWithValue(algorithmRegistry)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Algo & DS'), findsOneWidget);
    expect(find.text('Сортировки'), findsOneWidget);
  });
}
