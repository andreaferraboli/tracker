import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/discounted_product.dart';

class DiscountedProductsNotifier
    extends StateNotifier<List<DiscountedProduct>> {
  DiscountedProductsNotifier() : super([]);

  Future<void> _syncToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('discounted_products')
            .doc(user.uid)
            .set({
          'discounted_products':
              state.map((product) => product.toJson()).toList(),
        });
      } catch (e) {
        print('Error syncing discounted products to Firebase: $e');
      }
    }
  }

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
        final currentProducts = [...state, product];
        state = currentProducts;
      } catch (e) {
        print('Error adding discounted product: $e');
      }
    }
  }

  Future<void> addDiscountedProducts(List<DiscountedProduct> products) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final currentProducts = [...state, ...products];
        state = currentProducts;
      } catch (e) {
        print('Error adding discounted products: $e');
      }
    }
  }

  Future<void> removeDiscountedProduct(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final currentProducts =
            state.where((p) => p.productId != productId).toList();
        state = currentProducts;
      } catch (e) {
        print('Error removing discounted product: $e');
      }
    }
  }

  Future<void> updateDiscountedProducts(
      List<DiscountedProduct> products) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final productIds = products.map((product) => product.productId).toSet();
        final currentProducts = state
            .map((p) => productIds.contains(p.productId)
                ? products
                    .firstWhere((product) => product.productId == p.productId)
                : p)
            .toList();

        state = currentProducts;
      } catch (e) {
        print('Error updating discounted products: $e');
      }
    }
  }

  Future<void> updateDiscountedProduct(DiscountedProduct product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final currentProducts = state
            .map((p) => p.productId == product.productId ? product : p)
            .toList();

        state = currentProducts;
      } catch (e) {
        print('Error updating discounted product: $e');
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
      final List<DiscountedProduct> products =
          jsonList.map((json) => DiscountedProduct.fromJson(json)).toList();
      state = products;
      _syncToFirebase();
    } catch (e) {
      print('Error importing discounted products from JSON: $e');
    }
  }
}

final discountedProductsProvider =
    StateNotifierProvider<DiscountedProductsNotifier, List<DiscountedProduct>>(
        (ref) {
  return DiscountedProductsNotifier();
});
