import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/services/icons_helper.dart';
import 'dart:convert';

final storesProvider =
    StateNotifierProvider<StoresNotifier, List<Map<String, dynamic>>>((ref) {
  return StoresNotifier();
});

class StoresNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  StoresNotifier() : super([]);

  // Carica gli store iniziali
  void loadStores(List<Map<String, dynamic>> stores) {
    state = stores;
  }

  // Aggiunge un nuovo store e aggiorna Firestore
  Future<void> addStore(String name, IconData icon) async {
    final newStore = {'name': name, 'icon': IconsHelper.iconName(icon)};
    state = [...state, newStore];
    await _updateFirestore();
  }

  // Aggiorna un store esistente e sincronizza con Firestore
  Future<void> updateStore(int index, String newName, IconData newIcon) async {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          {'name': newName, 'icon': IconsHelper.iconName(newIcon)}
        else
          state[i]
    ];
    await _updateFirestore();
  }

  // Rimuove uno store e aggiorna Firestore
  Future<void> removeStore(int index) async {
    state = [...state]..removeAt(index);
    await _updateFirestore();
  }
Future<String> getStoresAsJson() async {
    final storesJson = state.map((store) => jsonEncode(store)).toList();
    return jsonEncode(storesJson);
  }

  // Elimina tutti gli store e sincronizza con Firestore
  Future<void> clearStores() async {
    state = [];
    await _updateFirestore();
  }

  // Metodo privato per aggiornare Firestore
  Future<void> _updateFirestore() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final storesToSave = state
        .map((store) => {'name': store['name'], 'icon': store['icon']})
        .toList();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'stores': storesToSave});
  }

  String exportToJson() {
    return json.encode(state);
  }

  void importFromJson(String jsonString) {
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<Map<String, dynamic>> stores = jsonList
          .map((json) => Map<String, dynamic>.from(json))
          .toList();
      state = stores;
      _updateFirestore();
    } catch (e) {
      print('Error importing stores from JSON: $e');
    }
  }
}
