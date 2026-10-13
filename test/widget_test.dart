import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:algo_learning_app/features/algorithms/algorithms_provider.dart';
import 'package:algo_learning_app/features/algorithms/registry.dart';
import 'package:algo_learning_app/features/auth/auth_provider.dart';
import 'package:algo_learning_app/main.dart';

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthSessionState build() => const AuthSessionSignedOut();
}

void main() {
  testWidgets('Home screen shows category list', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          algorithmsProvider.overrideWithValue(algorithmRegistry),
          authProvider.overrideWith(_FakeAuthNotifier.new),
        ],
        child: AlgoLearningApp(algorithms: algorithmRegistry),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Algo & DS'), findsOneWidget);
    expect(find.text('Сортировки'), findsOneWidget);
  });
}
