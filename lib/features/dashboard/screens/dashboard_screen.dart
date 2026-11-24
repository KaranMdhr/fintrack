import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_toggle_button.dart';
import '../../../core/utils/error_messages.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../auth/providers/auth_providers.dart';
import '../../expenses/models/expense.dart';
import '../../expenses/providers/expense_providers.dart';
import '../widgets/balance_hero.dart';
import '../widgets/category_donut_card.dart';
import '../widgets/month_pace_card.dart';
import '../widgets/period_selector.dart';
import '../widgets/recent_activity_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  bool get _isCurrentMonth {
    final DateTime now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Expense>> expenses = ref.watch(expensesProvider);
    final user = ref.watch(authStateProvider).asData?.value;
    final String rawName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : user?.email?.split('@').first ?? 'there';
    final String name = _capitalize(rawName);

    return expenses.when(
      loading: () => const _DashboardLoading(),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: GlassPanel(
              borderRadius: AppRadii.lg,
              child: ErrorBanner(
                message: firestoreErrorMessage(error),
                onRetry: () => ref.invalidate(expensesProvider),
              ),
            ),
          ),
        ),
      ),
      data: (items) {
        final List<Expense> monthExpenses = items
            .where(_isInSelectedMonth)
            .toList();
        final DateTime previousMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month - 1,
        );
        final double previousTotal = _monthTotal(items, previousMonth);
        final double total = monthExpenses.fold<double>(
          0,
          (sum, expense) => sum + expense.amount,
        );
        final Map<String, double> totals = <String, double>{};
        for (final Expense expense in monthExpenses) {
          totals.update(
            expense.category,
            (value) => value + expense.amount,
            ifAbsent: () => expense.amount,
          );
        }
        MapEntry<String, double>? topCategory;
        for (final MapEntry<String, double> entry in totals.entries) {
          if (topCategory == null || entry.value > topCategory.value) {
            topCategory = entry;
          }
        }

        final int daysInMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month + 1,
          0,
        ).day;
        final int daysElapsed = _isCurrentMonth
            ? DateTime.now().day
            : daysInMonth;
        final int activeDays = monthExpenses
            .map(
              (expense) => DateTime(
                expense.date.year,
                expense.date.month,
                expense.date.day,
              ),
            )
            .toSet()
            .length;
        final double largest = monthExpenses.fold<double>(
          0,
          (value, expense) => expense.amount > value ? expense.amount : value,
        );
        final List<double> cumulative = _cumulativeSpend(
          monthExpenses,
          daysElapsed,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth >= 780;
            final bool headerWide = constraints.maxWidth >= 620;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DashboardHeader(
                        greeting: _greeting(),
                        name: name,
                        month: _selectedMonth,
                        wide: headerWide,
                        onPrevious: () => _changeMonth(-1),
                        onNext: _isCurrentMonth ? null : () => _changeMonth(1),
                        onAdd: () => context.push('/expenses/add'),
                      ),
                      const SizedBox(height: 24),
                      if (wide)
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 7,
                                child: BalanceHero(
                                  total: total,
                                  count: monthExpenses.length,
                                  month: _selectedMonth,
                                  cumulative: cumulative,
                                  isCurrentMonth: _isCurrentMonth,
                                  previousTotal: previousTotal,
                                  fillHeight: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 4,
                                child: MonthPaceCard(
                                  total: total,
                                  activeDays: activeDays,
                                  daysElapsed: daysElapsed,
                                  daysInMonth: daysInMonth,
                                  largest: largest,
                                  topCategory: topCategory?.key,
                                  topCategoryAmount: topCategory?.value ?? 0,
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        BalanceHero(
                          total: total,
                          count: monthExpenses.length,
                          month: _selectedMonth,
                          cumulative: cumulative,
                          isCurrentMonth: _isCurrentMonth,
                          previousTotal: previousTotal,
                        ),
                        const SizedBox(height: 16),
                        MonthPaceCard(
                          total: total,
                          activeDays: activeDays,
                          daysElapsed: daysElapsed,
                          daysInMonth: daysInMonth,
                          largest: largest,
                          topCategory: topCategory?.key,
                          topCategoryAmount: topCategory?.value ?? 0,
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: CategoryDonutCard(
                                totals: totals,
                                total: total,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 6,
                              child: RecentActivityCard(
                                expenses: monthExpenses,
                                onViewAll: () => context.go('/activity'),
                                onAdd: () => context.push('/expenses/add'),
                                onExpenseTap: (expense) => context.push(
                                  '/expenses/${expense.id}/edit',
                                  extra: expense,
                                ),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        CategoryDonutCard(totals: totals, total: total),
                        const SizedBox(height: 16),
                        RecentActivityCard(
                          expenses: monthExpenses,
                          onViewAll: () => context.go('/activity'),
                          onAdd: () => context.push('/expenses/add'),
                          onExpenseTap: (expense) => context.push(
                            '/expenses/${expense.id}/edit',
                            extra: expense,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _isInSelectedMonth(Expense expense) {
    return expense.date.year == _selectedMonth.year &&
        expense.date.month == _selectedMonth.month;
  }

  double _monthTotal(List<Expense> items, DateTime month) {
    return items
        .where(
          (expense) =>
              expense.date.year == month.year &&
              expense.date.month == month.month,
        )
        .fold<double>(0, (sum, expense) => sum + expense.amount);
  }

  List<double> _cumulativeSpend(List<Expense> items, int days) {
    if (days <= 0) return <double>[];
    final List<double> daily = List<double>.filled(days, 0);
    for (final Expense expense in items) {
      final int day = expense.date.day;
      if (day >= 1 && day <= days) {
        daily[day - 1] += expense.amount;
      }
    }

    double running = 0;
    final List<double> cumulative = <double>[];
    for (final double value in daily) {
      running += value;
      cumulative.add(running);
    }
    return cumulative;
  }

  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.greeting,
    required this.name,
    required this.month,
    required this.wide,
    required this.onPrevious,
    required this.onNext,
    required this.onAdd,
  });

  final String greeting;
  final String name;
  final DateTime month;
  final bool wide;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OVERVIEW  /  ${AppFormatters.month(month).toUpperCase()}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$greeting, $name.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (wide
                                ? theme.textTheme.displaySmall
                                : theme.textTheme.headlineMedium)
                            ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your spending, without the noise.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const ThemeToggleButton(),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            PeriodSelector(
              month: month,
              onPrevious: onPrevious,
              onNext: onNext,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(wide ? 'Add expense' : 'Add'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 46),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BrandMark(size: 48),
          const SizedBox(height: 20),
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
