import 'package:tracker/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String PRODUCT_COLLECTION_REF = "products";

final _productsRef = FirebaseFirestore.instance.collection(PRODUCT_COLLECTION_REF).withConverter<Product>(
  fromFirestore: (snapshots, _) => Product.fromJson(snapshots.data()!),
  toFirestore: (product, _) => product.toJson(),
);

Stream<QuerySnapshot> getProducts() {
  return _productsRef.snapshots();
}

void addProduct(Product product) async {
  await _productsRef.add(product);
}

void updateProduct(String productId, Product product) async {
  await _productsRef.doc(productId).update(product.toJson());
}

void deleteProduct(String productId) async {
  await _productsRef.doc(productId).delete();
}