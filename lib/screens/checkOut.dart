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
      CollectionReference ordersCollection =
          documentReference.collection('Orders');

      CollectionReference PurchaseHistoryCollection =
          documentReference.collection('PurchaseHistory');

      QuerySnapshot ordersSnapshot = await ordersCollection.get();

      for (var order in ordersSnapshot.docs) {
        // Add the order to the purchase history collection
        await PurchaseHistoryCollection.add(order.data());

        // Delete the order from the orders collection

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => summary(
              orderID: order.id,
              userEmail: userEmail,
              country: '',
              city: '',
              street: '',
              province: '',
            ),
          ),
        );
      }

      ;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase successful'),
        ),
      );
    } catch (e) {
      print('Error fetching location details: $e');
      // Handle the error if necessary.
    }
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
