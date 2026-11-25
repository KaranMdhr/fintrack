import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/core/storage/preferences_provider.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/widgets/app_bottom_bar.dart';
import 'package:expense_tracker/features/auth/providers/auth_providers.dart';
import 'package:expense_tracker/features/auth/screens/login_screen.dart';
import 'package:expense_tracker/features/dashboard/screens/dashboard_screen.dart';
import 'package:expense_tracker/features/expenses/models/expense.dart';
import 'package:expense_tracker/features/expenses/providers/expense_providers.dart';
import 'package:expense_tracker/features/expenses/screens/expense_form_screen.dart';
import 'package:expense_tracker/features/expenses/screens/expenses_screen.dart';
import 'package:expense_tracker/features/settings/screens/settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final DateTime now = DateTime.now();
  final List<Expense> expenses = <Expense>[
    Expense(
      id: '1',
      amount: 1234.56,
      category: 'Food',
      date: DateTime(now.year, now.month, 2),
      note: 'Weekly groceries',
    ),
    Expense(
      id: '2',
      amount: 78.25,
      category: 'Transport',
      date: DateTime(now.year, now.month, 5),
      note: 'Train pass',
    ),
    Expense(
      id: '3',
      amount: 450,
      category: 'Shopping',
      date: DateTime(now.year, now.month, 9),
      note: 'New desk lamp',
    ),
    Expense(
      id: '4',
      amount: 92.4,
      category: 'Bills',
      date: DateTime(now.year, now.month, 12),
      note: 'Internet',
    ),
  ];

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    required double width,
    double height = 844,
  }) async {
    tester.view.physicalSize = Size(width * 2, height * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(null),
          authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
          expensesProvider.overrideWith(
            (ref) => Stream<List<Expense>>.value(expenses),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: screen),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('bottom bar keeps intrinsic height on mobile', (tester) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: AppBottomBar(index: 0, onTap: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Rect rect = tester.getRect(find.byType(AppBottomBar));
    expect(rect.height, lessThan(160));
    expect(rect.bottom, closeTo(844, 1));
  });

  for (final double width in <double>[320, 360, 390, 430]) {
    testWidgets('dashboard fits at ${width.toInt()}px', (tester) async {
      await pumpScreen(tester, const DashboardScreen(), width: width);
      expect(tester.takeException(), isNull);
    });

    testWidgets('activity fits at ${width.toInt()}px', (tester) async {
      await pumpScreen(tester, const ExpensesScreen(), width: width);
      expect(tester.takeException(), isNull);
    });

    testWidgets('settings fits at ${width.toInt()}px', (tester) async {
      await pumpScreen(tester, const SettingsScreen(), width: width);
      expect(tester.takeException(), isNull);
    });

    testWidgets('expense form fits at ${width.toInt()}px', (tester) async {
      await pumpScreen(tester, const ExpenseFormScreen(), width: width);
      expect(tester.takeException(), isNull);
    });

    testWidgets('login fits at ${width.toInt()}px', (tester) async {
      await pumpScreen(tester, const LoginScreen(), width: width);
      expect(tester.takeException(), isNull);
    });
  }
}
