import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/currency/app_currency.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/error_messages.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/expense_repository.dart';
import '../models/expense.dart';
import '../providers/expense_providers.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/expense_tile.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final Set<String> _deletingIds = <String>{};
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Expense>> expenses = ref.watch(expensesProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 720;

        return expenses.when(
          loading: () => const _ActivityLoading(),
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
            final List<Expense> visible = items
                .where((expense) => !_deletingIds.contains(expense.id))
                .toList();
            final String? selectedCategory = _selectedCategory;
            final List<Expense> filtered = selectedCategory == null
                ? visible
                : visible
                      .where((expense) => expense.category == selectedCategory)
                      .toList();
            final double total = filtered.fold<double>(
              0,
              (sum, expense) => sum + expense.amount,
            );

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ActivityHeader(
                            count: filtered.length,
                            total: total,
                            category: selectedCategory,
                            wide: wide,
                            onAdd: () => context.push('/expenses/add'),
                          ),
                          const SizedBox(height: 18),
                          CategoryFilterBar(
                            selectedCategory: selectedCategory,
                            onSelected: (category) {
                              setState(() => _selectedCategory = category);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: filtered.isEmpty
                          ? (visible.isEmpty
                                ? const _EmptyState()
                                : _NoMatchesState(
                                    category: selectedCategory!,
                                    onClear: () {
                                      setState(() => _selectedCategory = null);
                                    },
                                  ))
                          : _GroupedExpenseList(
                              expenses: filtered,
                              onEdit: (expense) => context.push(
                                '/expenses/${expense.id}/edit',
                                extra: expense,
                              ),
                              onDismissed: _onDismissed,
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onDismissed(Expense expense) {
    setState(() => _deletingIds.add(expense.id));
    _deleteExpense(expense);
  }

  Future<void> _deleteExpense(Expense expense) async {
    final String? uid = ref.read(authRepositoryProvider).currentUser?.uid;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ExpenseRepository repo = ref.read(expenseRepositoryProvider);

    if (uid == null) {
      if (mounted) setState(() => _deletingIds.remove(expense.id));
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Your session expired. Please sign in again.'),
        ),
      );
      return;
    }

    try {
      await repo.deleteExpense(uid, expense.id);
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Expense deleted.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _undoDelete(messenger, repo, uid, expense),
          ),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _deletingIds.remove(expense.id));
      messenger.showSnackBar(
        SnackBar(content: Text(firestoreErrorMessage(error))),
      );
    }
  }

  Future<void> _undoDelete(
    ScaffoldMessengerState messenger,
    ExpenseRepository repo,
    String uid,
    Expense expense,
  ) async {
    try {
      await repo.restoreExpense(uid, expense);
      if (!mounted) return;
      setState(() => _deletingIds.remove(expense.id));
      messenger.showSnackBar(
        const SnackBar(content: Text('Expense restored.')),
      );
    } on Object catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(firestoreErrorMessage(error))),
      );
    }
  }
}

class _ActivityHeader extends ConsumerWidget {
  const _ActivityHeader({
    required this.count,
    required this.total,
    required this.category,
    required this.wide,
    required this.onAdd,
  });

  final int count;
  final double total;
  final String? category;
  final bool wide;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppCurrency currency = ref.watch(currencyProvider);
    final String formattedTotal = AppFormatters.currency(
      total,
      currency: currency,
    );
    final String countLabel = count == 1 ? 'ENTRY' : 'ENTRIES';
    final String hint = category == null
        ? '$formattedTotal tracked. Tap to edit, swipe to delete.'
        : '$formattedTotal tracked in $category.';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ACTIVITY  /  $count $countLabel',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your spending,\nline by line.',
                style:
                    (wide
                            ? theme.textTheme.displaySmall
                            : theme.textTheme.headlineMedium)
                        ?.copyWith(height: 0.98),
              ),
              const SizedBox(height: 6),
              Text(
                hint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
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
    );
  }
}

class _GroupedExpenseList extends StatelessWidget {
  const _GroupedExpenseList({
    required this.expenses,
    required this.onEdit,
    required this.onDismissed,
  });

  final List<Expense> expenses;
  final ValueChanged<Expense> onEdit;
  final ValueChanged<Expense> onDismissed;

  @override
  Widget build(BuildContext context) {
    final List<Object> rows = _buildRows(expenses);
    final ThemeData theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final Object row = rows[index];

        if (row is DateTime) {
          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 4 : 22, bottom: 8),
            child: Row(
              children: [
                Text(
                  AppFormatters.day(row).toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final Expense expense = row as Expense;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ExpenseTile(
            expense: expense,
            onTap: () => onEdit(expense),
            onDismissed: () => onDismissed(expense),
          ),
        );
      },
    );
  }

  List<Object> _buildRows(List<Expense> expenses) {
    final List<Object> rows = <Object>[];
    DateTime? currentDay;

    for (final Expense expense in expenses) {
      final DateTime day = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );

      if (currentDay == null || day != currentDay) {
        rows.add(day);
        currentDay = day;
      }
      rows.add(expense);
    }

    return rows;
  }
}

class _NoMatchesState extends StatelessWidget {
  const _NoMatchesState({required this.category, required this.onClear});

  final String category;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: GlassPanel(
            padding: const EdgeInsets.all(30),
            borderRadius: AppRadii.xl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.filter_alt_off_rounded,
                    size: 27,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'No $category expenses',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Try another category or clear the filter.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 17),
                  label: const Text('Clear filter'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: GlassPanel(
            padding: const EdgeInsets.all(30),
            borderRadius: AppRadii.xl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 29,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'A clean slate',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Add your first expense to start building your financial picture.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => context.push('/expenses/add'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add expense'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityLoading extends StatelessWidget {
  const _ActivityLoading();

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
