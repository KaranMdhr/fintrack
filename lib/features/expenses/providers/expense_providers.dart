import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/expense_repository.dart';
import '../models/expense.dart';

final Provider<ExpenseRepository> expenseRepositoryProvider =
    Provider<ExpenseRepository>(
      (ref) => ExpenseRepository(FirebaseFirestore.instance),
    );

final StreamProvider<List<Expense>> expensesProvider =
    StreamProvider<List<Expense>>((ref) {
      final String? uid = ref.watch(authStateProvider).value?.uid;
      if (uid == null) return Stream<List<Expense>>.value(const <Expense>[]);
      return ref.watch(expenseRepositoryProvider).watchExpenses(uid);
    });
