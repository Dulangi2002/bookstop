import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class favorites extends StatefulWidget {
  final String userEmail;

  const favorites({super.key, required this.userEmail});

  @override
  State<favorites> createState() => _favoritesState();
}

class _favoritesState extends State<favorites> {
  late String userEmail;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    userEmail = widget.userEmail;
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    try {
      var documentReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Favorites')
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body:SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]['title']),
                  subtitle: Text(items[index]['author']),
                  trailing: Text(items[index]['price']),
                );
              },
            ),
          ],
        ),
      )
    
    );
  }
}
