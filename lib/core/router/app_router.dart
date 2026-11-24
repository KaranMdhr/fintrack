import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/expenses/models/expense.dart';
import '../../features/expenses/screens/expense_form_screen.dart';
import '../../features/expenses/screens/expense_not_found_screen.dart';
import '../../features/expenses/screens/expenses_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../screens/not_found_screen.dart';
import '../widgets/app_shell.dart';
import 'go_router_refresh_stream.dart';

final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  final AuthRepository auth = ref.watch(authRepositoryProvider);
  final GoRouterRefreshStream refresh = GoRouterRefreshStream(
    auth.authStateChanges(),
  );
  ref.onDispose(refresh.dispose);

  final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final bool signedIn = auth.currentUser != null;
      final bool isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!signedIn) return isAuthRoute ? null : '/login';
      if (isAuthRoute) return '/';
      if (state.matchedLocation == '/dashboard') return '/';
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/activity',
                builder: (context, state) => const ExpensesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/expenses/add',
        builder: (context, state) => const ExpenseFormScreen(),
      ),
      GoRoute(
        path: '/expenses/:id/edit',
        builder: (context, state) {
          final Object? extra = state.extra;
          if (extra is Expense) return ExpenseFormScreen(expense: extra);
          return const ExpenseNotFoundScreen();
        },
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
    ],
    errorBuilder: (context, state) => NotFoundScreen(
      title: 'This page drifted away.',
      message: "We couldn't find ${state.uri}.",
      buttonLabel: 'Back to overview',
      onPressed: () => context.go('/'),
    ),
  );

  ref.onDispose(router.dispose);
  return router;
});
