import 'dart:ffi';

import 'package:bookstop/screens/HomeScreen.dart';
import 'package:bookstop/screens/favorites.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bookstop/screens/checkOut.dart';
import 'package:bookstop/screens/profile.dart';


class MyCart extends StatefulWidget {
  final String userEmail; 

  MyCart({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  late String userEmail;
  List<Map<String, dynamic>> items = [];
  late double total;

  @override
  void initState() {
    super.initState();
    userEmail = widget.userEmail;
    fetchCart();
    calculateCartTotal().then((value) => setState(() {
          total = value;
        }));
  }

  Future<void> fetchCart() async {
    try {
      var documentReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Cart')
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

  Future<void> increaseQuantity(
      String title, int quantity, double price) async {
    try {
      var documentReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Cart')
          .doc(title)
          .update({'quantity': quantity, 'price': price});

      documentReference.then((value) {
        print('Quantity updated');
      });
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  Future<void> decreaseQuantity(
      String title, int quantity, double price) async {
    try {
      var documentReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Cart')
          .doc(title);

      double newPrice = price / quantity * (quantity - 1);
      await documentReference.update({'quantity': quantity, 'price': newPrice});

      print('Quantity and price updated');
    } catch (e) {
      print('Error updating quantity and price: $e');
    }
  }

  Future<void> deleteItem(String title) async {
    try {
      var documentReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Cart')
          .doc(title)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item deleted from cart'),
        ),
      );
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  Future<double> calculateCartTotal() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Cart')
          .get();

      double total = 0;
      snapshot.docs.forEach((element) {
        total += element.data()['price'];
      });

      return total;
    } catch (e) {
      print('Error calculating total: $e');
      return 0;
    }
  }

  Future<void> placeOrder() async {
    try {
      // var documentReference = FirebaseFirestore.instance
      //     .collection('Users')
      //     .doc(userEmail)
      //     .collection('Orders')
      //     .doc();

      // calculateCartTotal().then((value) {
      //   setState(() {
      //     total = value;
      //   });
      // });

      // documentReference.set({
      //   'items': items,
      //   'total': total,
      //   'orderDate': DateTime.now(),
      // });

      // var documentReference2 = FirebaseFirestore.instance
      //     .collection('Users')
      //     .doc(userEmail)
      //     .collection('Cart')
      //     .get();

      

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Proceeding to checkout'),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckOut(
            userEmail: userEmail,
          ),
        ),
      );
    } catch (e) {
      print('Error placing order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<double>(
              future: calculateCartTotal(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  double total = snapshot.data ?? 0;
                  return buildCartTotalUI(total);
                }
              },
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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
                  child: Row(
                    children: [
                      Row(
                        children: [
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
                                items[index]['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text('Quantity: ${items[index]['quantity']}'),
                              Text('Price: ${items[index]['price']}'),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.only(left: 8, right: 8),
                                    
                                      margin: EdgeInsets.only(top: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color:
                                            const Color.fromARGB(255, 1, 1, 1),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                items[index]['quantity']++;
                                                items[index]['price'] =
                                                    items[index]['price'] *
                                                        items[index]
                                                            ['quantity'];
                                              });
                                              increaseQuantity(
                                                  items[index]['title'],
                                                  items[index]['quantity']
                                                      .toInt(),
                                                  items[index]['price']);
                                            },
                                            icon: Icon(Icons.add , color: Colors.white,),
                                          ),
                                          Text(items[index]['quantity']
                                              .toString(),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              )
                                              ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if (items[index]['quantity'] >
                                                    1) {
                                                  items[index]['quantity']--;
                                                }
                                              });
                                              decreaseQuantity(
                                                  items[index]['title'],
                                                  items[index]['quantity']
                                                      .toInt(),
                                                  items[index]['price']);
                                            },
                                            icon: Icon(Icons.remove , color: Colors.white) ,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(BootstrapIcons.trash),
                                      onPressed: () {
                                        deleteItem(items[index]['title']);
                                        setState(() {
                                          items.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // ListTile(
                          //   contentPadding: EdgeInsets.all(16),
                          //   title: Text(
                          //     items[index]['title'],
                          //     style: TextStyle(
                          //       fontWeight: FontWeight.bold,
                          //       fontSize: 18,
                          //     ),
                          //   ),
                          //   subtitle: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text('Quantity: ${items[index]['quantity']}'),
                          //       Text('Price: ${items[index]['price']}'),
                          //     ],
                          //   ),
                          //   trailing: ClipRRect(
                          //     borderRadius: BorderRadius.circular(20),
                          //     child: Image.asset(
                          //       'assets/images/${items[index]['productImage']}',
                          //       fit: BoxFit.cover,
                          //       width: 50,
                          //       height: 50,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
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
             if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            }
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
        )
    );
  }

  Widget buildCartTotalUI(double total) {
    return Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total: \$${total.toStringAsFixed(2)}'),
            if (items.length > 0)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 0, 0, 0)),
                onPressed: () {
                  placeOrder();
                },
                child: Text('Place Order'),
              ),
          ],
        ));
  }
}
