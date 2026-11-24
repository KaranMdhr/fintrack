import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/currency/app_currency.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/category_style.dart';
import '../../../core/utils/error_messages.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/press_scale.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/expense.dart';
import '../providers/expense_providers.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, this.expense});

  final Expense? expense;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _category;
  late DateTime _date;

  bool _isSaving = false;
  String? _error;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final Expense? expense = widget.expense;
    _amountController = TextEditingController(
      text: expense == null ? '' : expense.amount.toStringAsFixed(2),
    );
    _noteController = TextEditingController(text: expense?.note ?? '');

    if (expense == null) {
      _category = AppConstants.defaultCategory;
    } else {
      _category = AppConstants.categories.contains(expense.category)
          ? expense.category
          : AppConstants.defaultCategory;
    }

    _date = _dateOnly(expense?.date ?? DateTime.now());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String? _validateAmount(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter an amount.';

    final double? amount = double.tryParse(text);
    if (amount == null) return 'Enter a valid number.';
    if (amount <= 0) return 'Amount must be greater than 0.';

    if (text.contains('.') && text.split('.').last.length > 2) {
      return 'Use at most 2 decimal places.';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final DateTime lastDate = _dateOnly(DateTime.now());
    final DateTime initialDate = _date.isAfter(lastDate) ? lastDate : _date;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: lastDate,
    );

    if (picked == null) return;
    setState(() => _date = _dateOnly(picked));
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final String? uid = ref.read(authRepositoryProvider).currentUser?.uid;
    if (uid == null) {
      setState(() => _error = 'Your session expired. Please sign in again.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final Expense expense = Expense(
      id: widget.expense?.id ?? '',
      amount: double.parse(_amountController.text.trim()),
      category: _category,
      date: _date,
      note: _noteController.text.trim(),
    );

    try {
      final repo = ref.read(expenseRepositoryProvider);
      if (_isEditing) {
        await repo.updateExpense(uid, expense);
      } else {
        await repo.addExpense(uid, expense);
      }

      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/activity');
      }
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = firestoreErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppCurrency currency = ref.watch(currencyProvider);
    final bool wide = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        PressScale(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/activity');
                            }
                          },
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHigh
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Text(
                            _isEditing ? 'EDITING ENTRY' : 'NEW ENTRY',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: 9,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      _isEditing ? 'Refine the details.' : 'A new entry.',
                      style:
                          (wide
                                  ? theme.textTheme.displaySmall
                                  : theme.textTheme.headlineMedium)
                              ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Small records create a clear picture.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GlassPanel(
                      padding: const EdgeInsets.all(26),
                      borderRadius: AppRadii.xl,
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _amountController,
                              enabled: !_isSaving,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textInputAction: TextInputAction.next,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w600,
                                letterSpacing: -1,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                prefixText: '${currency.symbol} ',
                                prefixStyle: theme.textTheme.headlineSmall
                                    ?.copyWith(
                                      fontFamily: 'SpaceGrotesk',
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              validator: _validateAmount,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _category,
                              enabled: !_isSaving,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              items: AppConstants.categories
                                  .map(
                                    (category) => DropdownMenuItem<String>(
                                      value: category,
                                      child: Row(
                                        children: [
                                          Icon(
                                            CategoryStyle.icon(category),
                                            size: 18,
                                            color: CategoryStyle.color(
                                              category,
                                              theme.brightness,
                                            ),
                                          ),
                                          const SizedBox(width: 9),
                                          Text(category),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _category = value);
                              },
                              validator: (value) =>
                                  value == null ? 'Choose a category.' : null,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _isSaving ? null : _pickDate,
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date',
                                  prefixIcon: Icon(
                                    Icons.calendar_today_outlined,
                                  ),
                                ),
                                child: Text(
                                  AppFormatters.shortDate(_date),
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _noteController,
                              enabled: !_isSaving,
                              maxLines: 3,
                              maxLength: 200,
                              textInputAction: TextInputAction.newline,
                              decoration: const InputDecoration(
                                labelText: 'Note (optional)',
                                alignLabelWithHint: true,
                                prefixIcon: Icon(Icons.notes_outlined),
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 8),
                              ErrorBanner(message: _error),
                            ],
                            const SizedBox(height: 18),
                            FilledButton.icon(
                              onPressed: _isSaving ? null : _save,
                              icon: _isSaving
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded, size: 19),
                              label: Text(
                                _isSaving
                                    ? 'Saving...'
                                    : (_isEditing
                                          ? 'Save changes'
                                          : 'Add expense'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Your data stays private to your account.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
