import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/routes/product_screen.dart';
import 'package:tracker/services/category_services.dart';
import 'package:tracker/services/toast_notifier.dart';

import '../models/expense.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  Future<void> deleteExpense(Expense expense) async {
    // Recupera l'ID dell'utente
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final expensesDocRef =
        FirebaseFirestore.instance.collection('expenses').doc(userId);

    // Ottiene il documento delle spese
    final expensesDoc = await expensesDocRef.get();

    // Verifica se il documento esiste e contiene dati
    if (!expensesDoc.exists || expensesDoc.data() == null) return;

    // Recupera la lista delle spese
    final expenses = (expensesDoc.data()!['expenses'] as List)
        .map((expense) => Expense.fromJson(expense))
        .toList();

    // Rimuove la spesa specifica
    expenses.removeWhere((e) => e.id == expense.id);

    // Aggiorna il documento delle spese
    await expensesDocRef
        .update({'expenses': expenses.map((e) => e.toJson()).toList()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.expenseDetailTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.confirm),
                    content: Text(
                        AppLocalizations.of(context)!.confirmDeleteExpense),
                    actions: <Widget>[
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.no),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.yes),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await deleteExpense(expense);
                Navigator.of(context).pop(expense);
                ToastNotifier.showSuccess(
                  context,
                  AppLocalizations.of(context)!.expenseDeleted,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!.supermarket}: ${expense.supermarket}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context)!.date}: ${expense.date}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context)!.totalAmount}: €${expense.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.details,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: expense.products.length,
                itemBuilder: (context, index) {
                  final item = expense.products[index];
                  return GestureDetector(
                    onTap: () async {
                      DocumentReference productDocRef = FirebaseFirestore
                          .instance
                          .collection('products')
                          .doc(FirebaseAuth.instance.currentUser!.uid);

                      DocumentSnapshot snapshot = await productDocRef.get();
                      var existingProduct, product;
                      if (snapshot.exists) {
                        final List<dynamic> productsList =
                            snapshot['products'] ?? [];
                        existingProduct = productsList.firstWhere(
                            (p) =>
                                p['productId'] ==
                                expense.products[index].idProdotto,
                            orElse: () => null);
                        product = Product.fromJson(existingProduct);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductScreen(product: product),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    child: CategoryServices.iconFromCategory(
                                        item.category),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${AppLocalizations.of(context)!.quantity}: ${item.quantity} x €${item.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '€/Kg: ${item.pricePerKg}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '€${(item.quantity * item.price).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
