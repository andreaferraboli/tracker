import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/routes/add_product_screen.dart';

class ProductScreen extends StatelessWidget {
  final Product product;

  const ProductScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {

    void _deleteProduct() async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference userDocRef = FirebaseFirestore.instance.collection('products').doc(user.uid);

        try {
          // Leggi il documento corrente
          DocumentSnapshot userDoc = await userDocRef.get();
          List<dynamic> products = userDoc['products'];

          // Trova il prodotto da rimuovere confrontando il productId
          products.removeWhere((p) => p['productId'] == product.productId);

          // Aggiorna il documento con l'array aggiornato
          await userDocRef.update({
            "products": products,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Prodotto eliminato con successo!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.of(context).pop();
        } catch (e) {
          print('Errore durante l\'eliminazione del prodotto: $e');
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(product.productName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(product: product),
                ),
              );
            },
          ),IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: (){_deleteProduct();},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Nome prodotto: ${product.productName}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(product.imageUrl)
                      : const Text('No image available'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Quantity: ${product.quantity}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Prezzo: €${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 2,
                  child: Text(
                    'C/U: €${(product.price / (product.quantity > 0 ? product.quantity : 1)).toStringAsFixed(3)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Peso totale (kg/litro): ${product.totalWeight}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 2,
                  child: Text(
                    '€/kg: €${(product.price / (product.totalWeight > 0 ? product.totalWeight : 1)).toStringAsFixed(3)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Peso unitario: ${(product.totalWeight / (product.quantity > 0 ? product.quantity : 1) * 1000).toStringAsFixed(3)} g',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Category: ${product.category}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(
                  color: Theme.of(context).textTheme.bodyLarge!.color ?? Colors.black,
                  width: 1),
              columnWidths: const {
                0: FlexColumnWidth(),
                1: FixedColumnWidth(100),
              },
              children: [
                TableRow(
                  children: [
                    Center(
                      child: Text(
                        'Macronutrients',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Center(
                      child: Text(
                        'Values(100g)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                ...product.macronutrients.entries.map(
                      (entry) => TableRow(
                    children: [
                      Center(child: Text('${entry.key}')),
                      Center(child: Text('${entry.value}g')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Expiration Date: ${product.expirationDate}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Supermarket: ${product.supermarket}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Purchase Date: ${product.purchaseDate}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Barcode: ${product.barcode}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
