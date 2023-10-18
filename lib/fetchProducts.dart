import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
 final CollectionReference<Map<String, dynamic>> productsCollection =
      FirebaseFirestore.instance.collection('Products');

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await productsCollection.get();

    List<Map<String, dynamic>> products = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> document
        in querySnapshot.docs) {
      products.add(document.data());
    }
    return products;
  }
}


