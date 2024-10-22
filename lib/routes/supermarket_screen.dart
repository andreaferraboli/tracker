import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/models/product_list_item.dart';
import 'package:tracker/routes/add_product_screen.dart';

class SupermarketScreen extends StatefulWidget {
  final String supermarketName;

  const SupermarketScreen({super.key, required this.supermarketName});

  @override
  _SupermarketScreenState createState() => _SupermarketScreenState();
}

class _SupermarketScreenState extends State<SupermarketScreen> {
  double totalBalance = 0.0; // Potresti calcolare il saldo basato sui prodotti
  List<ProductListItem> purchasedProducts = [];
  bool isConnected = false;

  void _updateTotalBalance(double price, bool isAdding) {
    setState(() {
      if (isAdding) {
        totalBalance += price;
      } else {
        totalBalance -= price;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // deleteAllProducts();
    // _checkConnection();
    // uploadProductsFromJsonToFirestore(FirebaseAuth.instance.currentUser!.uid, 'assets/json/esselunga_output.json');
    // uploadProductsFromJsonToFirestore(FirebaseAuth.instance.currentUser!.uid, 'assets/json/output.json');
    _fetchProducts(FirebaseAuth.instance.currentUser!.uid,
        widget.supermarketName); // Recupera i prodotti dal database
  }

  Future<void> uploadProductsFromJsonToFirestore(
      String userId, String jsonFilePath) async {
    // Leggi il file JSON
    String jsonString =
        await DefaultAssetBundle.of(context).loadString(jsonFilePath);
    List<dynamic> products = json.decode(jsonString);

    // Riferimento al documento dell'utente basato sul suo id
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('products').doc(userId);

    try {
      // Aggiorna il documento esistente aggiungendo i prodotti all'array "products"
      await userDocRef.update({"products": FieldValue.arrayUnion(products)});
      print('Prodotti aggiunti con successo!');
    } catch (e) {
      print('Errore durante l\'aggiunta dei prodotti: $e');
    }
  }

//funzione per cancellare tutti i documenti in products
  Future<void> deleteAllProducts() async {
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('products')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    try {
      await userDocRef.update({"products": FieldValue.delete()});
      print('Prodotti eliminati con successo!');
    } catch (e) {
      print('Errore durante l\'eliminazione dei prodotti: $e');
    }
    try {
      userDocRef = FirebaseFirestore.instance
          .collection('products')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      userDocRef.set({
        "products": [],
      });
    } catch (e) {
      print('Errore durante l\'impostazione dei prodotti: $e');
    }
  }

  void _checkConnection() {
    // Firestore non ha un metodo per controllare la connessione come Realtime Database.
    print('Firestore non fornisce un controllo diretto della connessione.');
    setState(() {
      isConnected = true; // Assumiamo di essere sempre connessi a Firestore.
    });
  }

  Future<void> _fetchProducts(String userId, String supermarketName) async {
    // Riferimento al documento dell'utente basato sul suo id
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('products').doc(userId);

    userDocRef.snapshots().listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        // Recupera l'array "products" dal documento
        final List<dynamic> productsArray = snapshot['products'] ?? [];
        final List<ProductListItem> productWidgets = [];

        // Itera sui prodotti per creare un widget ProductList per ciascuno
        if (productsArray.isNotEmpty &&
            productsArray[0]['productName'] != null) {
          for (var product in productsArray) {
            if (product['supermarket'] == supermarketName) {
              productWidgets.add(
                ProductListItem(
                    product: Product.fromJson(product),
                    onTotalPriceChange: _updateTotalBalance),
              );
            }
          }
        }

        // Aggiorna lo stato del widget per mostrare la lista dei prodotti
        setState(() {
          purchasedProducts = productWidgets;
        });
      } else {
        print('Nessun documento trovato per l\'utente.');
      }
    }, onError: (error) {
      print('Errore nel recupero dei prodotti: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supermarketName),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Saldo Totale: €${totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddProductScreen(
                              supermarketName: widget.supermarketName,
                            )),
                  );
                },
                child: const Text('Aggiungi Prodotto'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green, // Imposta il colore di sfondo del bottone
                ),
                onPressed: () {
                  // Logica per salvare la spesa
                },
                child: const Text('Salva Spesa'),
              ),
            ],
          ),
          Expanded(
            child: purchasedProducts.isNotEmpty
                ? ListView.builder(
                    itemCount: purchasedProducts.length,
                    itemBuilder: (context, index) {
                      return purchasedProducts[
                          index]; // Corretto il ritorno del widget
                    },
                  )
                : Center(
                    child: Text(
                      'Non ci sono prodotti salvati disponibili',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
