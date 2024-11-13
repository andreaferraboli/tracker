import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupermarketsNotifier extends StateNotifier<List<String>> {
  SupermarketsNotifier() : super([]) {// Chiama la funzione di fetch all'inizializzazione
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
      print("Errore nel recupero dei supermercati: $e");
    }
  }

  // Funzione per aggiungere un supermercato
  void addSupermarket(String supermarket) async {
    state = [...state, supermarket];
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await userDocRef.update({
      "supermarkets": FieldValue.arrayUnion([supermarket]),
    });
  }

  // Funzione per rimuovere un supermercato
  void removeSupermarket(String supermarket) async {
    state = state.where((item) => item != supermarket).toList();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
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
}

final supermarketsListProvider =
StateNotifierProvider<SupermarketsNotifier, List<String>>((ref) {
  return SupermarketsNotifier();
});
