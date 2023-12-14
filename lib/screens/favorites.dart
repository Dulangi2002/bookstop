import 'package:bookstop/screens/profile.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'cart.dart';

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

  Future<void> deleteFavorite(String title) async {
    try {
      var documentReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Favorites')
          .doc(title)
          .delete();
      documentReference.then((value) {
        print('Favorite deleted');
        setState(() {
          items.removeWhere((element) => element['title'] == title);
        });
      });
    } catch (e) {
      print('Error deleting favorite: $e');
    }
  }

  Future<void> addToCart(
      String title, double price , String productImage
      ) async {
    try {
      var documentReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Cart')
          .doc(title)
          .get();

      documentReference.then((snapshot) async {
        if (snapshot.exists) {
          print('Item already exists in cart');
        } else {
          var documentReference = FirebaseFirestore.instance
              .collection('Users')
              .doc(userEmail)
              .collection('Cart')
              .doc(title)
              .set({
            'title': title,
            'quantity': 1,
            'productImage': productImage,
            'price': price,
          });
          documentReference.then((value) {
            print('Item added to cart');
          });
        }
      });
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: [
                      Container(
                        margin: EdgeInsets.only(right: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/${items[index]['productImage']}',
                            fit: BoxFit.cover,
                            width: 100,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${items[index]['title']}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${items[index]['author']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                width: MediaQuery.of(context).size.width * 0.4,
                                margin: EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color.fromARGB(255, 1, 1, 1),
                                  
                                ),
                                

                                child: Row(
                                  children: [
                                    Text(
                                      'Rs. ${items[index]['price']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => {
                                        addToCart(
                                          items[index]['title'],
                                          items[index]['price'].toDouble(),
                                          items[index]['productImage'].toString(),
                                        ),
                                        deleteFavorite(items[index]['title']),
                                      },
                                      icon: Icon(BootstrapIcons.cart , color: Colors.white,),
                                    ),
                                  ],
                                ),
                              ),
                               IconButton(
                                onPressed: () => {
                                  deleteFavorite(items[index]['title']),
                                },
                                      icon: Icon(BootstrapIcons.trash),
                              ),
                            ],
                          ),
                        
                        ],
                      ),
                    ]),
                  );
                },
              ),
            ],
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
