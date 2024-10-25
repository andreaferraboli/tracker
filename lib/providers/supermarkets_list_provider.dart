import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupermarketsNotifier extends StateNotifier<List<String>> {
  SupermarketsNotifier() : super([]);

  void addSupermarket(String supermarket) {
    state = [...state, supermarket];
  }

  void removeSupermarket(String supermarket) {
    state = state.where((item) => item != supermarket).toList();
  }
}

final supermarketsListProvider = StateNotifierProvider<SupermarketsNotifier, List<String>>((ref) {
  return SupermarketsNotifier();
});