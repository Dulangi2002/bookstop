//import 'dart:html';

import 'dart:io';

import 'package:bookstop/Cart.dart';
import 'package:bookstop/fetchProducts.dart';
import 'package:bookstop/screens/cart.dart';
import 'package:bookstop/screens/fetchData.dart';
import 'package:bookstop/screens/viewItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final File profileImage;

  const HomeScreen({
    required this.profileImage,
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
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userEmail)
        .get();

    String profilePhoto = doc['profileimage'] ??
        'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png';
    return profilePhoto;
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
          



          // ElevatedButton(
          //     onPressed: () {
          //       var userEmail = FirebaseAuth.instance.currentUser!.email;
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => CartScreen(
          //             userEmail: userEmail.toString(),
          //           ),
          //         ),
          //       );
          //     },
          //     child: Text('View Cart')),
          Container(
            width: MediaQuery.of(context).size.width /
                2, // Set the width for the first container
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('User Email: $userEmail'),
                SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    height: 200,
                    width: 200,
                    child: Image.file(
                      widget.profileImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width /
                2, // Set the width for the second container
            child: Column(
              children: [
                Text('Products'),
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
