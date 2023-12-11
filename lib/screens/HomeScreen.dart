//import 'dart:html';

import 'dart:io';

import 'package:bookstop/fetchProducts.dart';
import 'package:bookstop/screens/cart.dart';
import 'package:bookstop/screens/favorites.dart';
import 'package:bookstop/screens/fetchData.dart';
import 'package:bookstop/screens/profile.dart';
import 'package:bookstop/screens/viewItem.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

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
  late List<Map<String, dynamic>> fantasyreads = [];
  late List<Map<String, dynamic>> newestadditions = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    FetchFantasyReads();
    FetchNewestAdditions();
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
    List<Product> fetchedProducts = await _productService.fetchProducts();

    fetchedProducts.forEach((product) {
      products.add({
        'title': product.title,
        'price': product.price,
        'image': product.image,
        'category': product.category,
        'description': product.description,
        'author': product.author,
        'launchDate': product.launchDate
      });
    });
  }

  Future<void> FetchNewestAdditions() async {
    List<Product> fetchedNewestAdditions =
        await _productService.getNewestAdditions();

    fetchedNewestAdditions.forEach((product) {
      newestadditions.add({
        'title': product.title,
        'price': product.price,
        'image': product.image,
        'category': product.category,
        'description': product.description,
        'author': product.author,
        'launchDate': product.launchDate
      });
    });

    setState(() {
      newestadditions = newestadditions.take(5).toList();
    });
  }

  Future<void> FetchFantasyReads() async {
    List<Product> fetchedFantasyReads = await _productService.getFantasyReads();
    fetchedFantasyReads.forEach((product) {
      fantasyreads.add({
        'title': product.title,
        'price': product.price,
        'image': product.image,
        'category': product.category,
        'description': product.description,
        'author': product.author,
        'launchDate': product.launchDate
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                // Other widgets

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 15.0, top: 20.0, bottom: 20.0),
                    child: Text(
                      'Browse through our digital shelves',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Container(
                  height: 350,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewItem(
                                    product: products[index],
                                  ),
                                ),
                              );
                            },
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/images/${products[index]['image']}',
                                      width: 160,
                                      height: 250,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      products[index]['title'],
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,

                                        // Add other style properties as needed
                                      ),
                                    ),
                                  ),

                                  Container(
                                    child: Text(
                                      

                                      products[index]['price'].toString(),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        

                                      ),
                                    ),
                                  ),
                                
                                ]),
                              ),
                            ),
                          ));
                    },
                  ),
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 15.0, top: 20.0, bottom: 20.0),
                    child: Text(
                      'Explore our fantasy collection',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Container(
                  height: 350,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: fantasyreads.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewItem(
                                    product: fantasyreads[index],
                                  ),
                                ),
                              );
                            },
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.asset(
                                        'assets/images/${fantasyreads[index]['image']}',
                                        width: 160,
                                        height: 250,
                                        fit: BoxFit.cover,
                                      )),
                                  Container(
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      fantasyreads[index]['title'],
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,

                                      ),
                                    ),
                                  ),

                                  Container(
                                    child: Text(
                                      fantasyreads[index]['price'].toString(),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,

                                      ),
                                    ),
                                  ),

                              
                                ]),
                              ),
                            ),
                          ));
                    },
                  ),
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 15.0, top: 20.0, bottom: 20.0),
                    child: Text(
                      'Newest Additions',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Container(
                  height: 350,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: newestadditions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewItem(
                                  product: newestadditions[index],
                                ),
                              ),
                            );
                          },
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  // Text(newestadditions[index]['title']),
                                  // Text(newestadditions[index]['price'].toString()),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/images/${newestadditions[index]['image']}',
                                      width: 160,
                                      height: 250,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      newestadditions[index]['title'],
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,

                                      ),
                                    ),
                                  ),

                                  Container(
                                    child: Text(
                                      newestadditions[index]['price']
                                          .toString(),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,

                                      ),
                                    ),
                                  ),

                                
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.house),
              label: 'Home',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.heart),
              label: 'Favorites',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.cart),
              label: 'Cart',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.person),
              label: 'Profile',
              backgroundColor: Colors.black,
            ),
          ],
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => favorites(userEmail: userEmail),
                ),
              );
            }
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyCart(
                    userEmail: userEmail,
                  ),
                ),
              );
            }
            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(
                    userEmail: userEmail,
                  ),
                ),
              );
            }
          },
        ));
  }
}
