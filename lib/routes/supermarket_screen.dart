import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupermarketScreen extends StatefulWidget {
  final String supermarketName;

  SupermarketScreen({required this.supermarketName});

  @override
  _SupermarketScreenState createState() => _SupermarketScreenState();
}

class _SupermarketScreenState extends State<SupermarketScreen> {
  double totalBalance = 0.0; // Potresti calcolare il saldo basato sui prodotti
  List<String> purchasedProducts = [];
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    uploadProductToFirestore();
    _fetchProducts(); // Recupera i prodotti dal database
  }

  Future<void> uploadProductToFirestore() async {
    Map<String, dynamic> product = {
      "productId": "12345",
      "productName": "Latte intero",
      "category": "Latticini",
      "price": 1.50,
      "quantity": 2,
      "unit": "litro",
      "totalPrice": 3.00,
      "supermarket": "Esselunga",
      "purchaseDate": "2024-10-12",
      "macronutrients": {
        "calories": 60,
        "protein": 3.2,
        "fat": 3.6,
        "carbohydrates": 4.7
      },
      "expirationDate": "2024-11-01",
      "barcode": "8001234567890"
    };

    CollectionReference productsRef = FirebaseFirestore.instance.collection('products');

    await productsRef.add(product).then((_) {
      print('Prodotto aggiunto con successo!');
    }).catchError((error) {
      print('Errore nel caricamento del prodotto: $error');
    });
  }

  void _checkConnection() {
    // Firestore non ha un metodo per controllare la connessione come Realtime Database.
    print('Firestore non fornisce un controllo diretto della connessione.');
    setState(() {
      isConnected = true; // Assumiamo di essere sempre connessi a Firestore.
    });
  }

  Future<void> _fetchProducts() async {
    CollectionReference productsRef = FirebaseFirestore.instance.collection('products');
    productsRef.snapshots().listen((QuerySnapshot snapshot) {
      final List<String> productNames = [];
      for (var doc in snapshot.docs) {
        productNames.add(doc['productName']);
      }
      setState(() {
        purchasedProducts = productNames;
      });
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
              'Saldo Totale: €$totalBalance',
              style: TextStyle(fontSize: 24),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Funzione per aggiungere un nuovo prodotto
            },
            child: Text('Aggiungi Prodotto'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: purchasedProducts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(purchasedProducts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
