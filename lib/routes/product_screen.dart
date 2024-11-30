import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/l10n/app_localizations.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/providers/discounted_products_provider.dart';
import 'package:tracker/routes/add_product_screen.dart';
import 'package:tracker/services/toast_notifier.dart';

class ProductScreen extends ConsumerWidget {
  final Product product;

  const ProductScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final discountedProducts = ref.watch(discountedProductsProvider);
    final discountedVersion = discountedProducts
        .where((p) => p.productId == product.productId)
        .firstOrNull;

    void deleteProduct() async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('products').doc(user.uid);

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
          if (!context.mounted) return;
          ToastNotifier.showSuccess(context,
              AppLocalizations.of(context)!.productDeletedSuccessfully);

          Navigator.of(context).pop();
        } catch (e) {
          ToastNotifier.showError(
              'Errore durante l\'eliminazione del prodotto: $e');
        }
      }
    }

    return Scaffold(
      appBar: isIOS
          ? CupertinoNavigationBar(
              middle: Text(product.productName),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddProductScreen(product: product),
                        ),
                      );
                    },
                    child: const Icon(CupertinoIcons.pencil),
                  ),
                  GestureDetector(
                    onTap: deleteProduct,
                    child: const Icon(CupertinoIcons.trash, color: Colors.red),
                  ),
                ],
              ),
            )
          : AppBar(
              titleSpacing: 0,
              centerTitle: true,
              title: Text(product.productName),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddProductScreen(product: product),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: deleteProduct,
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
                    '${AppLocalizations.of(context)!.productName}: ${product.productName}',
                    style: isIOS
                        ? CupertinoTheme.of(context).textTheme.textStyle
                        : Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(product.imageUrl)
                      : Text(AppLocalizations.of(context)!.noImageAvailable),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '${AppLocalizations.of(context)!.quantity}: ${product.quantity}',
                    style: isIOS
                        ? CupertinoTheme.of(context).textTheme.textStyle
                        : Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        '${AppLocalizations.of(context)!.price}: €${product.price.toStringAsFixed(2)}',
                        style: isIOS
                            ? CupertinoTheme.of(context).textTheme.textStyle
                            : Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (discountedVersion != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.discount,
                              color: Colors.green,
                              size: 14,
                            ),
                            Text(
                              ': €${discountedVersion.discountedPrice.toStringAsFixed(2)}-${((product.price - discountedVersion.discountedPrice) / product.price * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        '${AppLocalizations.of(context)!.unitPrice}: €${(product.price / (product.quantity > 0 ? product.quantity : 1)).toStringAsFixed(3)}',
                        style: isIOS
                            ? CupertinoTheme.of(context).textTheme.textStyle
                            : Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (discountedVersion != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.discount,
                              color: Colors.green,
                              size: 14,
                            ),
                            Text(
                              ': €${(discountedVersion.discountedPrice / (product.quantity > 0 ? product.quantity : 1)).toStringAsFixed(3)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                    ],
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
                    '${AppLocalizations.of(context)!.totalWeight} (kg/l): ${product.totalWeight}',
                    style: isIOS
                        ? CupertinoTheme.of(context).textTheme.textStyle
                        : Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const Spacer(flex: 1),
                Expanded(
                    flex: 2,
                    child: Column(children: [
                      Text(
                        '${AppLocalizations.of(context)!.pricePerKg}: €${(product.price / (product.totalWeight > 0 ? product.totalWeight : 1)).toStringAsFixed(3)}',
                        style: isIOS
                            ? CupertinoTheme.of(context).textTheme.textStyle
                            : Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (discountedVersion != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.discount,
                              color: Colors.green,
                              size: 14,
                            ),
                            Text(
                              ': €${(discountedVersion.discountedPrice / (product.totalWeight > 0 ? product.totalWeight : 1)).toStringAsFixed(3)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                    ])),
                const Spacer(flex: 1),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${AppLocalizations.of(context)!.unitWeight}: ${(product.totalWeight / (product.quantity > 0 ? product.quantity : 1) * 1000).toStringAsFixed(3)} g',
                    style: isIOS
                        ? CupertinoTheme.of(context).textTheme.textStyle
                        : Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.category}: ${AppLocalizations.of(context)!.translateCategory(product.category)}',
                  style: isIOS
                      ? CupertinoTheme.of(context).textTheme.textStyle
                      : Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '${AppLocalizations.of(context)!.store}: ${AppLocalizations.of(context)!.getStorageTitle(product.store)}',
                  style: isIOS
                      ? CupertinoTheme.of(context).textTheme.textStyle
                      : Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.quantityOwned}: ${product.quantityOwned}',
                      style: isIOS
                          ? CupertinoTheme.of(context).textTheme.textStyle
                          : Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (discountedVersion != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.discount,
                            color: Colors.green,
                            size: 14,
                          ),
                          Text(
                            ': ${discountedVersion.discountedQuantityOwned}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.quantityUnitOwned}: ${product.quantityUnitOwned}',
                      style: isIOS
                          ? CupertinoTheme.of(context).textTheme.textStyle
                          : Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (discountedVersion != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.discount,
                            color: Colors.green,
                            size: 14,
                          ),
                          Text(
                            ': ${discountedVersion.discountedQuantityUnitOwned}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.quantityWeightOwned}: ${product.quantityWeightOwned}',
                  style: isIOS
                      ? CupertinoTheme.of(context).textTheme.textStyle
                      : Theme.of(context).textTheme.bodyLarge,
                ),
                if (discountedVersion != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.discount,
                        color: Colors.green,
                        size: 14,
                      ),
                      Text(
                        ': ${discountedVersion.discountedQuantityWeightOwned.toStringAsFixed(3)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(
                color: Theme.of(context).textTheme.bodyLarge!.color ??
                    Colors.black,
                width: 1,
              ),
              columnWidths: const {
                0: FlexColumnWidth(),
                1: FixedColumnWidth(100),
              },
              children: [
                TableRow(
                  children: [
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.macronutrients,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.valuesPer100g,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                ...product.macronutrients.entries.map(
                  (entry) => TableRow(
                    children: [
                      Center(
                          child: Text(AppLocalizations.of(context)!
                              .getNutrientString(entry.key))),
                      Center(child: Text('${entry.value}g')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${AppLocalizations.of(context)!.expirationDate}: ${product.expirationDate}',
              style: isIOS
                  ? CupertinoTheme.of(context).textTheme.textStyle
                  : Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '${AppLocalizations.of(context)!.supermarket}: ${product.supermarket}',
              style: isIOS
                  ? CupertinoTheme.of(context).textTheme.textStyle
                  : Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '${AppLocalizations.of(context)!.purchaseDate}: ${product.purchaseDate}',
              style: isIOS
                  ? CupertinoTheme.of(context).textTheme.textStyle
                  : Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              '${AppLocalizations.of(context)!.barcode}: ${product.barcode}',
              style: isIOS
                  ? CupertinoTheme.of(context).textTheme.textStyle
                  : Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
