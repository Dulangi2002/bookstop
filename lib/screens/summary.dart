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
  List<Map<String, dynamic>> orderDetails = [];
  late String total = '';
  late String cardnumber = '';
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

      QuerySnapshot querySnapshot = await collectionReference
          .where(
            'orderID',
            isEqualTo: widget.orderID,
          )
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> orderItems = [];

        querySnapshot.docs.forEach((doc) {
          Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
          List<Map<String, dynamic>> items =
              List<Map<String, dynamic>>.from(orderData['orderItems'] ?? []);
          total = orderData['orderTotal'].toString();
          cardnumber = orderData['cardnumber'].toString();

          orderItems.addAll(items);
        });

        setState(() {
          orderDetails = orderItems;
        });

        print(orderDetails);
        print(total);
      } else {
        print('User has not stored order details');
      }
    } catch (e) {
      print('Error fetching order details: $e');
    }
  }

  String maskCardNumber(String cardNumber) {
    int totalDigits = cardNumber.length;
    int visibleDigits = 4;

    String maskedPart = '*' * (totalDigits - visibleDigits);
    String visiblePart = cardnumber.substring(totalDigits - visibleDigits);

    return maskedPart + visiblePart;
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
              Text('Delivery details'),
              if (widget.country != null) Text('Country: ${widget.country}'),
              if (widget.city != null) Text('City: ${widget.city}'),
              if (widget.street != null) Text('Street: ${widget.street}'),
              if (widget.province != null) Text('Province: ${widget.province}'),
            ],
          ),
        Text('Order summary'),
        Column(children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: orderDetails.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Image.asset(
                      'assets/images/${orderDetails[index]['image']}',
                      width: 100,
                      height: 100,
                    ),
                    Column(
                      children: [
                        Text(
                          '${orderDetails[index]['title']}',
                        ),
                        Text(
                          '${orderDetails[index]['price']}',
                        ),
                      ],
                    ),
                  ],
                );
              }),
        ]),
        Text('Payment details'),
        Container(
          child: Column(
            children: [
              Text('Payment details: '),
              Text(
                'Total: ' + total + ' LKR',
              ),
              Text(
                'Card Number: ' + maskCardNumber(cardnumber),
              ),
            ],
          ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  side: BorderSide(
                    width: 2,
                    color: Colors.black,
                  )),
              onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(),
                      ),
                    )
                  },
              child: Text(' Continue Shopping')),
        ),
      ]),
    );
  }
}
