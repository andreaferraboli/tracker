import 'package:flutter/material.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/services/category.dart';

class ProductListItem extends StatefulWidget {
  final Product product; // Singolo oggetto Product
  final void Function(double, bool) onTotalPriceChange; // Funzione per aggiornare il prezzo totale

  ProductListItem({required this.product, required this.onTotalPriceChange});

  @override
  _ProductListItemState createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  int buyQuantity = 0; // Quantità del prodotto da gestire nello stato

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
            // Usa l'icona caricata direttamente dalla categoria
            CategoryIcon.iconFromCategory(widget.product.category),
            SizedBox(width: 15), // Spaziatura tra immagine e testo
            // Dettagli del prodotto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.product.productName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.product.category,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Prezzo: €${widget.product.totalPrice.toStringAsFixed(2)}',
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
                Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          iconSize: 30.0, // Aumenta dimensione icona
                          color: Colors.blue, // Colore di sfondo blu
                          onPressed: () {
                            if (buyQuantity > 0) {
                              setState(() {
                                buyQuantity--;
                              });
                              widget.onTotalPriceChange(widget.product.price, false);
                            }
                          },
                        ),
                        Text('$buyQuantity'),
                        IconButton(
                          icon: Icon(Icons.add),
                          iconSize: 30.0, // Aumenta dimensione icona
                          color: Colors.blue, // Colore di sfondo blu
                          onPressed: () {
                            setState(() {
                              buyQuantity++;
                            });
                            widget.onTotalPriceChange(widget.product.price, true);
                          },
                        ),
                      ],
                    ),
                    Text('Posseduto: ${widget.product.quantity}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
