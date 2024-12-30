import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/services/toast_notifier.dart';
import 'dart:convert';

class SupermarketsNotifier extends StateNotifier<List<String>> {
  SupermarketsNotifier() : super([]) {
    // Chiama la funzione di fetch all'inizializzazione
  }

  // Funzione per recuperare la lista dei supermercati da Firebase
  Future<void> _fetchSupermarkets() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final List<String> supermarkets =
            List<String>.from(userDoc.data()?['supermarkets'] ?? []);
        state = supermarkets; // Imposta lo stato con la lista recuperata
      }
    } catch (e) {
      ToastNotifier.showError("Errore nel recupero dei supermercati: $e");
    }
  }
// Funzione per esportare la lista dei supermercati in formato JSON
  Future<String> getSupermarketsAsJson() async {
    final supermarketsJson = state.map((supermarket) => jsonEncode(supermarket)).toList();
    return jsonEncode(supermarketsJson);
  }
  // Funzione per aggiungere un supermercato
  void addSupermarket(String supermarket) async {
    state = [...state, supermarket];
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    await userDocRef.update({
      "supermarkets": FieldValue.arrayUnion([supermarket]),
    });
  }

  // Funzione per aggiungere più supermercati
  void addAllSupermarkets(List<String> supermarkets) async {
    state = supermarkets;
  }

  // Funzione per rimuovere un supermercato
  void removeSupermarket(String supermarket) async {
    state = state.where((item) => item != supermarket).toList();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    await userDocRef.update({
      "supermarkets": FieldValue.arrayRemove([supermarket]),
    });
  }

  void resetSupermarkets() {
    state = [];
  }

  void loadSupermarkets() {
    _fetchSupermarkets();
  }

  String exportToJson() {
    return json.encode(state);
  }

  void importFromJson(String jsonString) {
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<String> supermarkets = jsonList.cast<String>();
      state = supermarkets;
      _updateFirestore();
    } catch (e) {
      print('Error importing supermarkets from JSON: $e');
    }
  }

  Future<void> _updateFirestore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await userDocRef.update({
        "supermarkets": state,
      });
    } catch (e) {
      print('Error updating supermarkets in Firestore: $e');
    }
  }
}

final supermarketsListProvider =
    StateNotifierProvider<SupermarketsNotifier, List<String>>((ref) {
  return SupermarketsNotifier();
});
