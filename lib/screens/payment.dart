import 'dart:async';
import 'dart:math';

import 'package:bookstop/screens/summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Payment extends StatefulWidget {
  final String userEmail;
  final String country;
  final String city;
  final String street;
  final String province;
  Payment(
      {super.key,
      required this.userEmail,
      required this.country,
      required this.city,
      required this.street,
      required this.province});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  bool isAddCardClicked = false;
  bool isCardSelected = false;
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cardHolderNameController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  List<String> cardType = [
    'Visa',
    'MasterCard',
  ];
  String selectedCardType = '';
  String cardSelectedForPayment = ' ';
  List<Map<String, dynamic>> usersCards = [];

  @override
  void initState() {
    super.initState();
    fetchCardDetails();
  }

  Future<void> COD() async {
    try {} catch (error) {
      print("Error adding profile photo: $error");
    }
  }

  Future<void> addCard() async {
    try {
      String userEmail = widget.userEmail;
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Users').doc(userEmail);
      CollectionReference collectionReference =
          documentReference.collection('CardDetails');

      await collectionReference.add({
        'cardType': selectedCardType,
        'cardNumber': cardNumberController.text,
        'cardHolderName': cardHolderNameController.text,
        'expiryDate': expiryDateController.text,
        'cvv': cvvController.text,
      });
      cardNumberController.clear();
      cardHolderNameController.clear();
      expiryDateController.clear();
      cvvController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Card added successfully'),
        ),
      );
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding card'),
        ),
      );
    }
  }

  Future<List<DocumentSnapshot>> fetchCardDetails() async {
    try {
      String userEmail = widget.userEmail;
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Users').doc(userEmail);
      CollectionReference collectionReference =
          documentReference.collection('CardDetails');

      QuerySnapshot querySnapshot = await collectionReference.get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        usersCards.add(doc.data() as Map<String, dynamic>);
      }

      setState(() {
        usersCards = usersCards;
      });

      return querySnapshot.docs;
    } catch (error) {
      print(error);
      return [];
    }
  }

  Future<void> DeleteCard(String id) async {
    try {
      String userEmail = widget.userEmail;
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Users').doc(userEmail);
      CollectionReference collectionReference =
          documentReference.collection('CardDetails');

      await collectionReference.doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Card deleted successfully'),
        ),
      );
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting card'),
        ),
      );
    }
  }

  Future<void> Purchase() async {
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
        String country = widget.country;
        String city = widget.city;
        String street = widget.street;
        String province = widget.province;
        String cardNumber = cardSelectedForPayment;

        orderItems.add({
          'image': image,
          'title': title,
          'price': price,
          'quantity': quantity,
          'country': country,
          'city': city,
          'street': street,
          'province': province,
          'cardNumber': cardNumber,
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
              city: widget.city,
              country: widget.country,
              street: widget.street,
              orderID: orderID,
              province: widget.province,
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
  Widget _buildAddCardDialog(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Add a card',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: cardType.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(cardType[index]),
                      value: selectedCardType == cardType[index],
                      onChanged: (value) {
                        print(
                            'Selected card type: ${cardType[index]}'); 

                        setState(() {
                          selectedCardType = cardType[index];
                        });
                      },
                    );
                  },
                );
              },
            ),
            Container(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: TextFormField(
                cursorColor: Colors.black,
                cursorHeight: 20,
                controller: cardNumberController,
                inputFormatters: [
                  CardNumberInputFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: 'xxxx xxxx xxxx xxxx',
                  // errorText: validator(cardNumberController.text),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
                validator: (value) {
                  if (value!.isEmpty)
                    return 'Please enter a valid card number text';
                  else
                    return null;
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: TextFormField(
                controller: cardHolderNameController,
                decoration: InputDecoration(
                  labelText: 'Card Holder Name',
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: TextFormField(
                inputFormatters: [
                  ExpiryDateValidator(),
                ],
                controller: expiryDateController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: TextFormField(
                inputFormatters: [
                  CVVValidator(),
                ],
                controller: cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 2,
                      color: Colors.black,
                    ),
                  ),
                  labelStyle: TextStyle(
                    fontSize: 12,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (selectedCardType == '') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please select a card type'),
                ),
              );
              return;
            }
            if (cardNumberController.text.length < 16 ||
                expiryDateController.text.length < 4 ||
                cvvController.text.length < 3) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enter valid card details'),
                ),
              );
              return;
            }
            if (cardNumberController.text.isEmpty ||
                cardHolderNameController.text.isEmpty ||
                expiryDateController.text.isEmpty ||
                cvvController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enter all card details'),
                ),
              );
              return;
            }
            if (cardNumberController.text.length < 16) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enter a valid card number'),
                ),
              );
              return;
            }
            if (cvvController.text.length < 3) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enter a valid CVV'),
                ),
              );
              return;
            }
            if (expiryDateController.text.length < 4) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enter a valid expiry date'),
                ),
              );
              return;
            }

            addCard();
            setState(() {
              cardNumberController.clear();
              cardHolderNameController.clear();
              expiryDateController.clear();
              cvvController.clear();
              fetchCardDetails();
            });
            Navigator.pop(context);
          },
          child: Text('Create'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10, left: 15, right: 15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        fixedSize: Size(500, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        side: BorderSide(
                          width: 2,
                          color: Colors.black,
                        )),
                    onPressed: () {
                      setState(() {
                        isAddCardClicked = true;
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildAddCardDialog(context);
                        },
                      );
                    },
                    child: Text('Add a card'),
                  ),
                ),
                // Rest of your widget tree
              ],
            ),
            Container(
          

              height: 500,
              child: StatefulBuilder(
                
                  builder: (BuildContext context, StateSetter setState) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: usersCards.length,
                  itemBuilder: (context, index) {
                    return SingleChildScrollView(
                      child: Container(
                        height: 180,
                        margin: EdgeInsets.only(top: 10, bottom: 10 , left: 15, right: 15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ) ,
                        child: CheckboxListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (usersCards[index]['cardType'] == 'Visa')
                                Container(
                                  child: Image.asset(
                                    'assets/images/visa.jpg',
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                              if (usersCards[index]['cardType'] == 'MasterCard')
                                Image.asset(
                                  'assets/images/mastercard.jpg',
                                  width: 60,
                                  height: 60,
                                ),
                              Text(usersCards[index]['cardNumber']),
                              Text(
                                usersCards[index]['expiryDate'],
                              ),
                            ],
                          ),
                          value: cardSelectedForPayment ==
                              usersCards[index]['cardNumber'],
                          onChanged: (value) {
                            print(
                                'Selected card number: ${usersCards[index]['cardNumber']}'); // Print the selected card number to the console
                      
                            setState(() {
                              cardSelectedForPayment =
                                  usersCards[index]['cardNumber'];
                              isCardSelected = true;
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              }),
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
                    fixedSize: Size(500, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    side: BorderSide(
                      width: 2,
                      color: Colors.black,
                    )),
                onPressed: () {
                  if (isCardSelected == false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select a card'),
                      ),
                    );
                    return;
                  }
                  Purchase();
                },
                child: Text('Purchase'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

validator(String text) {
  if (text.isEmpty) {
    return 'Please enter a valid card number';
  } else {
    return null;
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String formattedText = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (formattedText.length > 16) {
      return oldValue;
    }
    List<String> chunks = [];
    for (int i = 0; i < formattedText.length; i += 4) {
      int end = i + 4;
      if (end >= formattedText.length) {
        end = formattedText.length;
      }
      chunks.add(formattedText.substring(i, end));
    }

    formattedText = chunks.join(' ');

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class ExpiryDateValidator extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String formattedText = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (formattedText.length > 4) {
      return oldValue;
    }

    List<String> chunks = [];

    for (int i = 0; i < formattedText.length; i += 2) {
      int end = i + 2;
      if (end >= formattedText.length) {
        end = formattedText.length;
      }
      chunks.add(formattedText.substring(i, end));
    }

    formattedText = chunks.join('/');
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class CVVValidator extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String formattedText = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (formattedText.length > 3) {
      return oldValue;
    }

    List<String> chunks = [];

    for (int i = 0; i < formattedText.length; i += 1) {
      int end = i + 1;
      if (end >= formattedText.length) {
        end = formattedText.length;
      }
      chunks.add(formattedText.substring(i, end));
    }

    formattedText = chunks.join('');
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
