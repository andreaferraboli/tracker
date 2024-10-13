import 'package:flutter/material.dart';
import 'package:tracker/models/product.dart';

class ProductListItem extends StatelessWidget {
  final Product product; // Singolo oggetto Product

  ProductListItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      elevation: 3,
      child: Container(
        width: 300, // Larghezza fissa per la card
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: [
            // Immagine del prodotto
            Image.network(
              'https://via.placeholder.com/150?text=${product.category}',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 15), // Spaziatura tra immagine e testo
            // Dettagli del prodotto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.productName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    product.category,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Prezzo: €${product.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Controlli per aggiungere/rimuovere quantità
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (product.quantity > 0) {
                      // logica per ridurre quantità
                    }
                  },
                ),
                Text(product.quantity.toString()),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // logica per aumentare quantità
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
