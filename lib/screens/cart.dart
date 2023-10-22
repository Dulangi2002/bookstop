import 'dart:ffi';

import 'package:bookstop/Cart.dart';
import 'package:bookstop/screens/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bookstop/screens/checkOut.dart';

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

  Future<void> decreaseQuantity(String title, int quantity , double price) async {
    try {
      var documentReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Cart')
          .doc(title)
          .update({'quantity': quantity , 'price': price});

      documentReference.then((value) {
        print('Quantity updated');
      });
    } catch (e) {
      print('Error updating quantity: $e');
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
      var documentReference = FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Orders')
          .doc();

      calculateCartTotal().then((value) {
        setState(() {
          total = value;
        });
      });

      documentReference.set({
        'items': items,
        'total': total,
        'orderDate': DateTime.now(),
      });

      var documentReference2 = FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Cart')
          .get();

      documentReference2.then((snapshot) {
        snapshot.docs.forEach((element) {
          element.reference.delete();
        });
      });

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
        title: Text(widget.userEmail),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //  Container(
            //    child: Text(
            //      'Total: \$${total.toStringAsFixed(2)}',
            //      style: TextStyle(
            //        fontWeight: FontWeight.bold,
            //        fontSize: 24,
            //      ),
            //    ),
            //    padding: EdgeInsets.all(16),
            //  ),

            // funtion inside future builder

//             FutureBuilder<double>(
//   future: FirebaseFirestore.instance
//       .collection('Users')
//       .doc(userEmail)
//       .collection('Cart')
//       .get()
//       .then((snapshot) {
//     double total = 0;
//     snapshot.docs.forEach((element) {
//       total += element.data()['price'] * element.data()['quantity'];
//     });
//     return total;
//   }),
//   builder: (context, snapshot) {
//     if (snapshot.connectionState == ConnectionState.waiting) {
//       return CircularProgressIndicator();
//     } else {
//       double total = snapshot.data ?? 0;
//       return Text('Total: \$${total.toStringAsFixed(2)}');
//     }
//   },
// )

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
            if (items.length > 0)
              ElevatedButton(
                onPressed: () {
                  placeOrder();
                },
                child: Text('Place Order'),
              ),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          items[index]['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity: ${items[index]['quantity']}'),
                            Text('Price: ${items[index]['price']}'),
                          ],
                        ),
                        trailing: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/${items[index]['productImage']}',
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      items[index]['quantity']++;
                                      items[index]['price'] = items[index]
                                              ['price'] *
                                          items[index]['quantity'];
                                    });
                                    increaseQuantity(
                                        items[index]['title'],
                                        items[index]['quantity'].toInt(),
                                        items[index]['price']);
                                  },
                                  icon: Icon(Icons.add),
                                ),
                                Text(items[index]['quantity'].toString()),
                                
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (items[index]['quantity'] > 1) {
                                        items[index]['quantity']--;
                                        items[index]['price'] = items[index]
                                              ['price'] *
                                          items[index]['quantity'];
                                      }
                                    });
                                    decreaseQuantity(items[index]['title'],
                                        items[index]['quantity'].toInt() ,
                                         items[index]['price']);
                                  },
                                  icon: Icon(Icons.remove),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                deleteItem(items[index]['title']);
                                setState(() {
                                  items.removeAt(index);
                                });
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCartTotalUI(double total) {
    return Text('Total: \$${total.toStringAsFixed(2)}');
  }
}
