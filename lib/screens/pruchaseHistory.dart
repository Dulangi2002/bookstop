import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class purchaseHistory extends StatefulWidget {
  final String userEmail;
  const purchaseHistory({super.key, required this.userEmail});

  @override
  State<purchaseHistory> createState() => _purchaseHistoryState();
}

class _purchaseHistoryState extends State<purchaseHistory> {
  late String userEmail;
  List<Map<String, dynamic>> items = [];

  Future<void> fetchPurchaseHistory() async {
    try {
      List<Map<String, dynamic>> items = [];
      var documentReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Orders')
          .where(
            'orderStatus' == 'Delivered',
          )
          .get();

      documentReference.then((snapshot) {
        snapshot.docs.forEach((element) {
          items.add(element.data());
        });
        setState(() {});
      });
    } catch (e) {
      print('Error fetching cart: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPurchaseHistory();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase History'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]['title']),
            subtitle: Text(items[index]['price'].toString()),
          );
        },
      ),
    );
  }
}
