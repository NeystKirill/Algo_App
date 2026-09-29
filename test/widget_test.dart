import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:algo_learning_app/main.dart';

void main() {
  testWidgets('Home screen shows category list', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: AlgoLearningApp()));
    await tester.pumpAndSettle();

    expect(find.text('Algo & DS'), findsOneWidget);
    expect(find.text('Сортировки'), findsOneWidget);
  });
}
