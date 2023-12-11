import 'dart:math';

import 'package:bookstop/screens/locationdetails.dart';
import 'package:bookstop/screens/summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class CheckOut extends StatefulWidget {
  final String userEmail;
  CheckOut({super.key, required this.userEmail});

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> Delivery(BuildContext context) async {
    const userEmail = 'userEmail';
    try {
      // Check if user has stored location details in the database
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Users').doc(userEmail);
      CollectionReference collectionReference = documentReference.collection(
          'LocationDetails'); // Use `documentReference` instead of `CollectionReference`

      DocumentSnapshot snapshot =
          await collectionReference.doc(userEmail).get();

      if (snapshot.exists) {
        print('User has stored location details');

        // Retrieve the details and pass it to the delivery screen
        Map<String, dynamic> locationDetails =
            snapshot.data() as Map<String, dynamic>;
      } else {
        print('User has not stored location details');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationDetails(),
          ),
        );
      }
    } catch (e) {
      print('Error fetching location details: $e');
      // Handle the error if necessary.
    }
  }

  Future<void> PickUp(BuildContext context) async {
    try {
      String userEmail = widget.userEmail;
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Users').doc(userEmail);
      CollectionReference cart = documentReference.collection('Cart');

      CollectionReference orders = documentReference.collection('Orders');

      QuerySnapshot cartSnapShot = await cart.get();

      List<Map<String, dynamic>> orderItems = [];

      for (QueryDocumentSnapshot cartItem in cartSnapShot.docs) {
        String image = cartItem['productImage'];
        String title = cartItem['title'];
        String price = cartItem['price'].toString();
        String quantity = cartItem['quantity'].toString();
       

        orderItems.add({
          'image': image,
          'title': title,
          'price': price,
          'quantity': quantity,
          'country': '',
          'city': '',
          'street': '',
          'province': '',
          'cardNumber': '',
        });
      }

      print(orderItems);

      String orderID = '$userEmail/' + generateRandomId(10);
      double orderTotal = 0;

      for (Map<String, dynamic> orderItem in orderItems) {
        orderTotal += double.parse(orderItem['price']) *
            double.parse(orderItem['quantity']);
      }

      DocumentReference newOrder = await orders.add({
        'orderID': orderID,
        'orderItems': orderItems,
        'createdAt': FieldValue.serverTimestamp(),
        'orderTotal': orderTotal,
      });

      for (QueryDocumentSnapshot cartItem in cartSnapShot.docs) {
        await cartItem.reference.delete();
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return summary(
              city: '',
              country: '',
              street: '',
              orderID: orderID,
              province: '',
              userEmail: widget.userEmail,
            );
          },
        ),
      );
    } catch (error) {
      print(error);
    }
  }

    String generateRandomId(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();

    return String.fromCharCodes(
      List.generate(
          length, (index) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Out'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                'Choose checkout method'),
            Container(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20, left: 15, right: 15),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            fixedSize: Size(250, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            side: BorderSide(
                              width: 2,
                              color: Colors.black,
                            )),
                        onPressed: () => {Delivery(context)},
                        child: Text('Delivery')),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, left: 15, right: 15),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            fixedSize: Size(250, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            side: BorderSide(
                              width: 2,
                              color: Colors.black,
                            )),
                        onPressed: () => {
                              PickUp(
                                context,
                              )
                            },
                        child: Text('Pickup')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
