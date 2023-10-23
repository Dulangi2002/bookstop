import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Payment extends StatefulWidget {
  final String userEmail;
  Payment({super.key, required this.userEmail});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  bool isAddCardClicked = false;
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cardHolderNameController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  List<bool> isCheckedList = []; 
  late Future<List<DocumentSnapshot>> cardDetails; 
  @override
  void initState() {
    super.initState();
    cardDetails = fetchCardDetails();
    isCheckedList = List<bool>.filled(
        0, false, growable: true);
    



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
        'cardNumber': cardNumberController.text,
        'cardHolderName': cardHolderNameController.text,
        'expiryDate': expiryDateController.text,
        'cvv': cvvController.text,
      });
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
      return querySnapshot.docs; // Return the list of card details documents
    } catch (error) {
      print(error);
      return []; // Return an empty list in case of an error
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
      CollectionReference ordersCollection =
          documentReference.collection('Orders');

      CollectionReference PurchaseHistoryCollection =
          documentReference.collection('PurchaseHistory');

      QuerySnapshot ordersSnapshot = await ordersCollection.get();

      for (QueryDocumentSnapshot order in ordersSnapshot.docs) {
        await PurchaseHistoryCollection.add({
          'productName': order['productName'],
          'productPrice': order['productPrice'],
          'productQuantity': order['productQuantity'],
          'productImage': order['productImage'],
        });

        await ordersCollection.doc(order.id).delete();
      }
      ;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase successful'),
        ),
      );
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error purchasing: $error'),
        ),
      );
    }
  }

  @override
  Widget _buildAddCardDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Add Card'),
      content: Column(
        children: [
          SizedBox(height: 20),
          TextFormField(
            controller: cardNumberController,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(19),
              CardNumberInputFormatter(),
            ],
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: 'xxxx xxxx xxxx xxxx',
              errorText: validator(cardNumberController.text),
            ),
            validator: (value) {
              if (value!.isEmpty)
                return 'Please enter a valid card number text';
              else
                return null;
            },
          ),
          TextFormField(
            controller: cardHolderNameController,
            decoration: InputDecoration(
              labelText: 'Card Holder Name',
            ),
          ),
          TextFormField(
            controller: expiryDateController,
            decoration: InputDecoration(
              labelText: 'Expiry Date',
            ),
          ),
          TextFormField(
            controller: cvvController,
            decoration: InputDecoration(
              labelText: 'CVV',
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            addCard();
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
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Payment'),
            Column(
              children: [
                ElevatedButton(
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
                // Rest of your widget tree
              ],
            ),
            Column(
              //display the cards
              children: [
              SizedBox(
                child: FutureBuilder<List<DocumentSnapshot>>(
                    future: cardDetails,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Show loading indicator while fetching data
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}'); // Show error message if fetching fails
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        // If data is available, build the ListView with card details
                        return Container(
                          height: 200,
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                                        DocumentSnapshot documentSnapshot = snapshot.data![index];
                                        bool isChecked = isCheckedList.length > index ? isCheckedList[index] : false;
                                      
                                        return Card(
                                          child: CheckboxListTile(
                                            checkColor: Colors.white,
                                            fillColor: MaterialStateProperty.resolveWith(getColor),
                                            title: Text(documentSnapshot['cardNumber']),
                                            subtitle: Text(documentSnapshot['cardHolderName']),
                                            value: isChecked,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isCheckedList[index] = value!;
                                              });
                                            },
                                            controlAffinity: ListTileControlAffinity.trailing,
                                            secondary: IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                              DeleteCard(documentSnapshot.id);
                                              },
                                            ),
                                          ),
                                        );
                            },
                          ),
                        );
                      } else {
                        return Text('No card details available.'); // Show message if there are no card details
                      }
                    },
                  ),
              ),
              ],
            ),
            (isCheckedList.length > 0 && isCheckedList.contains(true))
                ? ElevatedButton(
                    onPressed: () {
                      Purchase();
                    },
                    child: Text('Purchase'),
                  )
                : SizedBox(), 
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
    String formattedText = newValue.text.replaceAll(RegExp(r'\s'), '');
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
