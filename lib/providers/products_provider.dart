import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';

class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier() : super([]);

  void addProduct(Product product) {
    state = [...state, product];
  }

  void removeProduct(String id) {
    state = state.where((product) => product.productId != id).toList();
  }

  void updateProduct(Product updatedProduct) {
    state = state.map((product) {
      return product.productId == updatedProduct.productId
          ? updatedProduct
          : product;
    }).toList();
  }

  void loadProducts(List<Product> products) {
    state = products;
  }

  Future<void> fetchProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(user.uid)
            .get();

        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          if (data['products'] != null) {
            final List<dynamic> productsData = data['products'];
            final products = productsData
                .map((product) => Product.fromJson(product))
                .toList();
            state = products;
          }
        }
      } catch (e) {
        // Handle error
        print('Error fetching products: $e');
      }
    }
  }
}

final productsProvider =
    StateNotifierProvider<ProductsNotifier, List<Product>>((ref) {
  return ProductsNotifier();
});
