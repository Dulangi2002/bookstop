//import 'dart:html';

import 'dart:io';

import 'package:bookstop/fetchProducts.dart';
import 'package:bookstop/screens/cart.dart';
import 'package:bookstop/screens/fetchData.dart';
import 'package:bookstop/screens/viewItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String userEmail;
  final ProductService _productService = ProductService();
  late List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    userEmail = FirebaseAuth.instance.currentUser!.email.toString();
  }

  Future<String> fetchProfilePhoto() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .get()
          .then((value) => value);
      return doc['profileimage'];
      if (doc['profileimage'] == null) {
        return "";
      } else {
        return doc['profileimage'];
      }
    } catch (error) {
      print("Error fetching profile photo: $error");
      return "";
    }
  }

  Future<void> _fetchProducts() async {
    List<Map<String, dynamic>> products = await _productService.fetchProducts();
    setState(() {
      this.products = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Row(
        children: [
         
          // Container(
          //   width: MediaQuery.of(context).size.width , // Set the width for the first container
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Text('User Email: $userEmail'),
          //       SizedBox(height: 20),
          //       ClipRRect(
          //         borderRadius: BorderRadius.circular(100),
          //         child: Container(
          //             height: 200,
          //             width: 200,
          //             child: FutureBuilder<String>(
          //               future: fetchProfilePhoto(),
          //               builder: (context, snapshot) {
          //                 if (snapshot.connectionState ==
          //                     ConnectionState.waiting) {
          //                   return CircularProgressIndicator();
          //                 } else if (snapshot.hasError) {
          //                   return Text(
          //                       'Error loading profile photo: ${snapshot.error}');
          //                 } else if (snapshot.hasData) {
          //                   return Image.network(snapshot.data.toString());
          //                 } else {
          //                   return Text(
          //                       'No profile photo available'); // Placeholder message
          //                 }
          //               },
          //             )),
          //       ),
          //     ],
          //   ),
          // ),
          Container(
            width: MediaQuery.of(context).size.width, // Set the width for the second container
            child: Column(
              children: [
  
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      
                      return ListTile(
                        title: Text(products[index]
                            ['title']), // Displaying product title
                        subtitle: Text(products[index]['price']
                            .toString()), // Displaying product price
                        leading: SizedBox(
                          width: 50, // Set the desired width
                          child: Image.asset(
                              'assets/images/${products[index]['image']}'),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewItem(
                                  product: products[index],
                                ),
                              ),
                            );
                          },
                          child: Text('View'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
