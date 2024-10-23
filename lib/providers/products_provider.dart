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
      return product.productId == updatedProduct.productId ? updatedProduct : product;
    }).toList();
  }
  void loadProducts(List<Product> products) {
    state = products;
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>((ref) {
  return ProductsNotifier();
});