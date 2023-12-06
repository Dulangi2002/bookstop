import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String title;
  final int price;
  final String image;
  final String category;
  final Timestamp? launchDate;
  final String description;
  final String author;

  Product(
      {
      required this.title,
      required this.price,
      required this.image,
      required this.category,
      required this.launchDate,
      required this.description,
      required this.author
      }

      );

  // Additional constructor or factory method to convert from Firestore data
  factory Product.fromFirestore(Map<String, dynamic> data) {
    return Product(
        title: data['title'],
        price: data['price'],
        image: data['image'],
        category: data['category'],
        launchDate: data['launchDate'],
        description: data['description'],
        author: data['author']
        );
  }
}

class ProductService {
  final CollectionReference<Map<String, dynamic>> productsCollection =
      FirebaseFirestore.instance.collection('Products');

  Future<List<Product>> fetchProducts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await productsCollection.get();

      return querySnapshot.docs
          .map((document) => Product.fromFirestore(document.data()))
          .toList();
    } catch (error) {
      print("Error fetching products: $error");
      return [];
    }
  }

  Future<List<Product>> getFantasyReads() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await productsCollection
              .where('category', isEqualTo: 'fantasy')
              .get();

      return querySnapshot.docs
          .map((document) => Product.fromFirestore(document.data()))
          .toList();
    } catch (error) {
      print("Error fetching fantasy reads: $error");
      return [];
    }
  }

  Future<List<Product>> getNewestAdditions() async {
    late DateTime current = DateTime.now();
    late DateTime thisMonth = DateTime(current.year, current.month, 1);
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await productsCollection
              .where('launchDate', isGreaterThanOrEqualTo: thisMonth)
              .get();

      return querySnapshot.docs
          .map((document) => Product.fromFirestore(document.data()))
          .toList();
    } catch (error) {
      print("Error fetching newest additions: $error");
      return [];
    }
  }
}
