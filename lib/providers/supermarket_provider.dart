import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
