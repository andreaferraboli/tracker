import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker/models/product_list_item.dart';
import 'package:tracker/models/product.dart';

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

  @override
  void initState() {
    super.initState();
    // deleteAllProducts();
    // _checkConnection();
    _fetchProducts("andrea_ferraboli"); // Recupera i prodotti dal database
  }

  Future<void> uploadProductToFirestore(String userId) async {
    // Definisci il prodotto da aggiungere
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

    // Riferimento al documento dell'utente basato sul suo id
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('products').doc(userId);

    try {
      // Aggiorna il documento esistente aggiungendo il prodotto all'array "products"
      await userDocRef.update({
        "products": FieldValue.arrayUnion([product])
      });
      print('Prodotto aggiunto con successo!');
    } catch (e) {
      print('Errore durante l\'aggiunta del prodotto: $e');
    }
  }

//funzione per cancellare tutti i documenti in products
  Future<void> deleteAllProducts() async {
    CollectionReference productsRef =
        FirebaseFirestore.instance.collection('products');
    QuerySnapshot querySnapshot = await productsRef.get();
    querySnapshot.docs.forEach((doc) {
      doc.reference.delete();
    });
  }

  void _checkConnection() {
    // Firestore non ha un metodo per controllare la connessione come Realtime Database.
    print('Firestore non fornisce un controllo diretto della connessione.');
    setState(() {
      isConnected = true; // Assumiamo di essere sempre connessi a Firestore.
    });
  }

  Future<void> _fetchProducts(String userId) async {
    // Riferimento al documento dell'utente basato sul suo id
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('products').doc(userId);

    userDocRef.snapshots().listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        // Recupera l'array "products" dal documento
        final List<dynamic> productsArray = snapshot['products'] ?? [];
        final List<ProductListItem> productWidgets = [];

        // Itera sui prodotti per creare un widget ProductList per ciascuno
        for (var product in productsArray) {
          productWidgets.add(
            ProductListItem(product: Product.fromJson(product)),
          );
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
              'Saldo Totale: €$totalBalance',
              style: const TextStyle(fontSize: 24),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              uploadProductToFirestore(
                  "andrea_ferraboli"); // Chiamata alla funzione quando si preme il pulsante
            },
            child: const Text('Aggiungi Prodotto'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: purchasedProducts.length,
              itemBuilder: (context, index) {
                return purchasedProducts[
                    index]; // Corretto il ritorno del widget
              },
            ),
          )
        ],
      ),
    );
  }
}
