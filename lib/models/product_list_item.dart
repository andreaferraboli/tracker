import 'package:flutter/material.dart';
import 'package:tracker/models/product.dart';
import 'package:tracker/routes/product_screen.dart';
import 'package:tracker/services/category_services.dart';

class ProductListItem extends StatefulWidget {
  final Product product; // Singolo oggetto Product
  final void Function(double, bool)
      onTotalPriceChange; // Funzione per aggiornare il prezzo totale

  const ProductListItem(
      {super.key, required this.product, required this.onTotalPriceChange});

  @override
  _ProductListItemState createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  int buyQuantity = 0; // Quantità del prodotto da gestire nello stato

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(product: widget.product),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        elevation: 3,
        child: Container(
          width: 300, // Larghezza fissa per la card
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              // Usa l'icona caricata direttamente dalla categoria
              widget.product.imageUrl != null &&
                      widget.product.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.product.imageUrl,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) {
                        return CategoryServices.iconFromCategory(
                            widget.product.category);
                      },
                    )
                  : CategoryServices.iconFromCategory(widget.product.category),
              const SizedBox(width: 15), // Spaziatura tra immagine e testo
              // Dettagli del prodotto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.product.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.product.category,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 106, 106, 106),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '€${widget.product.price.toStringAsFixed(2)}, Totale €${(widget.product.price * buyQuantity).toStringAsFixed(2)}',
                      style: const TextStyle(
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material(
                            shape: const CircleBorder(),
                            // Forma a cerchio
                            color: Theme.of(context).primaryColor,
                            // Colore di sfondo primary del tema
                            child: IconButton(
                              icon:
                                  const Icon(Icons.remove, color: Colors.white),
                              iconSize: 30.0,
                              // Aumenta dimensione icona
                              padding: const EdgeInsets.all(10.0),
                              // Padding per rendere il bottone circolare
                              onPressed: () {
                                if (buyQuantity > 0) {
                                  setState(() {
                                    buyQuantity--;
                                  });
                                  widget.onTotalPriceChange(
                                      widget.product.price, false);
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text('$buyQuantity',
                                style: const TextStyle(fontSize: 20.0)),
                          ),
                          Material(
                            shape: const CircleBorder(),
                            // Forma a cerchio
                            color: Theme.of(context).primaryColor,
                            // Colore di sfondo primary del tema
                            child: IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              iconSize: 30.0,
                              // Aumenta dimensione icona
                              padding: const EdgeInsets.all(10.0),
                              // Padding per rendere il bottone circolare
                              onPressed: () {
                                setState(() {
                                  buyQuantity++;
                                });
                                widget.onTotalPriceChange(
                                    widget.product.price, true);
                              },
                            ),
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
      ),
    );
  }
}
