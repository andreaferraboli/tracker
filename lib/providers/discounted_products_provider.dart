import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/discounted_product.dart';

class DiscountedProductsNotifier extends StateNotifier<List<DiscountedProduct>> {
  DiscountedProductsNotifier() : super([]);

  void loadDiscountedProducts(List<DiscountedProduct> products) {
    state = products;
  }

  Future<void> fetchDiscountedProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('discounted_products')
            .doc(user.uid)
            .get();

        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          if (data['discounted_products'] != null) {
            final List<dynamic> productsData = data['discounted_products'];
            final products = productsData
                .map((product) => DiscountedProduct.fromJson(product))
                .toList();
            state = products;
          }
        }
      } catch (e) {
        // Handle error
        print('Error fetching discounted products: $e');
      }
    }
  }

  Future<void> addDiscountedProduct(DiscountedProduct product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final docRef = FirebaseFirestore.instance
            .collection('discounted_products')
            .doc(user.uid);

        final currentProducts = [...state, product];
        await docRef.set({
          'discounted_products': currentProducts.map((p) => p.toJson()).toList(),
        });

        state = currentProducts;
      } catch (e) {
        print('Error adding discounted product: $e');
      }
    }
  }

  Future<void> removeDiscountedProduct(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final docRef = FirebaseFirestore.instance
            .collection('discounted_products')
            .doc(user.uid);

        final currentProducts =
            state.where((p) => p.productId != productId).toList();
        await docRef.set({
          'discounted_products': currentProducts.map((p) => p.toJson()).toList(),
        });

        state = currentProducts;
      } catch (e) {
        print('Error removing discounted product: $e');
      }
    }
  }
}

final discountedProductsProvider =
    StateNotifierProvider<DiscountedProductsNotifier, List<DiscountedProduct>>(
        (ref) {
  return DiscountedProductsNotifier();
});
