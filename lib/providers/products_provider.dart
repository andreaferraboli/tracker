import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import 'dart:convert';

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
  Future<void> postProducts(productsJson) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(user.uid)
          .set({'products': jsonDecode(productsJson)});
    } catch (e) {
      // Handle error
      print('Error posting products: $e');
    }
  }
}
Future<String> getProductsAsJson() async {
    final products = state;
    final productsJson = products.map((product) => product.toJson()).toList();
    return jsonEncode(productsJson);
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

  String exportToJson() {
    final List<Map<String, dynamic>> jsonList =
        state.map((product) => product.toJson()).toList();
    return json.encode(jsonList);
  }

  void importFromJson(String jsonString) {
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<Product> products =
          jsonList.map((json) => Product.fromJson(json)).toList();
      state = products;
      _syncToFirebase();
    } catch (e) {
      print('Error importing products from JSON: $e');
    }
  }

  Future<void> _syncToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(user.uid)
            .set({
          'products': state.map((product) => product.toJson()).toList(),
        });
      } catch (e) {
        print('Error syncing products to Firebase: $e');
      }
    }
  }
}

final productsProvider =
    StateNotifierProvider<ProductsNotifier, List<Product>>((ref) {
  return ProductsNotifier();
});
