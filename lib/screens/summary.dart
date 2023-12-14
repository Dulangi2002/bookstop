import 'dart:ffi';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:bookstop/screens/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart' as printing;

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
  final pdf = pw.Document();

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
  int maskedDigits = totalDigits - visibleDigits;

  if (maskedDigits < 4) {
    maskedDigits = 0; // Ensure it doesn't go below 0
  }

  String maskedPart = '*' * maskedDigits;

  String visiblePart =
      cardNumber.substring(maskedDigits, totalDigits);

  return maskedPart + visiblePart;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10, left: 15, right: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (widget.country != null ||
              widget.city != null ||
              widget.street != null ||
              widget.province != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.country != null) Text('Country: ${widget.country}'),
                if (widget.city != null) Text('City: ${widget.city}'),
                if (widget.street != null) Text('Street: ${widget.street}'),
                if (widget.province != null)
                  Text('Province: ${widget.province}'),
              ],
            ),
          Text(
            'Order summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(children: [
            ListView.builder(
                shrinkWrap: true,
                itemCount: orderDetails.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/${orderDetails[index]['image']}',
                          width: 100,
                          height: 100,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${orderDetails[index]['title']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'LKR ${orderDetails[index]['price']}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
          ]),
          Text(
            'Payment details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            child: Column(
              children: [
                Text(
                  'Total: LKR ' + total,
                ),
                Text(
                  'Card Number: ' + cardnumber,
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
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
          Container(
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
              ),
            ),
            onPressed: () async {
              // Generate the PDF content
              final pdf = pw.Document();
              pdf.addPage(
                pw.Page(
                  pageFormat: PdfPageFormat.a4,
                  build: (pw.Context context) {
                    return pw.Center(
                      child: pw.Text(
                          'Order Summary\n\n' + // Add your order details here
                              'Total: LKR $total\n' +
                              'Card Number: ${maskCardNumber(cardnumber)}'),
                    );
                  },
                ),
              );

              // Save the PDF file
              final output = await getTemporaryDirectory();
              final pdfFile = File('${output.path}/order_summary.pdf');
              await pdfFile.writeAsBytes(await pdf.save());
            },
            child: Text('Download Receipt'),
          ))
        ]),
      ),
    );
  }
}
