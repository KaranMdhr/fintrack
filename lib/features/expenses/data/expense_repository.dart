import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';

class ExpenseRepository {
  ExpenseRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Expense> _expenses(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .withConverter<Expense>(
          fromFirestore: (snapshot, _) => Expense.fromDoc(snapshot),
          toFirestore: (expense, _) => expense.toMap(),
        );
  }

  Stream<List<Expense>> watchExpenses(String uid) {
    return _expenses(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> addExpense(String uid, Expense expense) async {
    await _expenses(uid).add(expense);
  }

  Future<void> updateExpense(String uid, Expense expense) async {
    await _expenses(uid).doc(expense.id).set(expense);
  }

  Future<void> deleteExpense(String uid, String expenseId) async {
    await _expenses(uid).doc(expenseId).delete();
  }

  Future<void> restoreExpense(String uid, Expense expense) async {
    await _expenses(uid).doc(expense.id).set(expense);
  }
}
