import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupermarketNotifier extends StateNotifier<String> {
  SupermarketNotifier() : super('');

  void setSupermarket(String supermarket) {
    state = supermarket;
  }
}

final supermarketProvider =
    StateNotifierProvider<SupermarketNotifier, String>((ref) {
  return SupermarketNotifier();
});
