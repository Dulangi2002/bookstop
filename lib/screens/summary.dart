import 'dart:ffi';

import 'package:bookstop/screens/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class summary extends StatefulWidget {
  final String userEmail;
  final String country;
  final String city;
  final String street;
  final String province;
  final String orderID;
  summary(
      {super.key,
      required this.userEmail,
      required this.country,
      required this.city,
      required this.street,
      required this.province,
      required this.orderID});

  @override
  State<summary> createState() => _summaryState();
}

class _summaryState extends State<summary> {
  List items = [];
  

  @override
  void initState() {
    super.initState();
    FetchTheOrderDetails();
  }

  Future<void> FetchTheOrderDetails() async {
    try {
      String userEmail = widget.userEmail;
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Users').doc(userEmail);
      CollectionReference collectionReference =
          documentReference.collection('Orders');
      DocumentSnapshot snapshot =
          await collectionReference.doc(widget.orderID).get();
      if (snapshot.exists) {
        print('User has stored order details');
        Map<String, dynamic> orderDetails =
            snapshot.data() as Map<String, dynamic>;

        setState(() {
          items = orderDetails['items'];
        });
      } else {
        print('User has not stored order details');
        // Navigate to the order details screen
      }
    } catch (e) {
      print('Error fetching order details: $e');
    }
  }

  Future<void> deleteOrderDetails() async {
    try {
      String userEmail = widget.userEmail;
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Users').doc(userEmail);
      CollectionReference collectionReference =
          documentReference.collection('Orders');
      DocumentSnapshot snapshot =
          await collectionReference.doc(widget.orderID).get();
      if (snapshot.exists) {
        print('User has stored order details');
        Map<String, dynamic> orderDetails =
            snapshot.data() as Map<String, dynamic>;
        await collectionReference.doc(widget.orderID).delete();
        print('Order details deleted');
      } else {
        print('User has not stored order details');
        // Navigate to the order details screen
      }
    } catch (e) {
      print('Error fetching order details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
      ),
      body: Column(children: [
     
      if (widget.country != null ||
            widget.city != null ||
            widget.street != null ||
            widget.province != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.country != null)
                Text('Country: ${widget.country}'),
              if (widget.city != null)
                Text('City: ${widget.city}'),
              if (widget.street != null)
                Text('Street: ${widget.street}'),
              if (widget.province != null)
                Text('Province: ${widget.province}'),
            ],
          ),
        Text('Order Details'),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items[index]['title']),
                subtitle: Text('Price: ${items[index]['price']}'),
                trailing: Text('Quantity: ${items[index]['quantity']}'),
              );
            },
          ),
        ),
        ElevatedButton(
            onPressed: () =>
                {deleteOrderDetails(), 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                  )
                },
            child: Text(' Continue Shopping')),
      ]),
    );
  }
}
