import 'package:bookstop/screens/locationdetails.dart';
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
  const userEmail = 'userEmail'; // This should be your actual user's email address
  try {
    // Check if user has stored location details in the database
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('Users').doc(userEmail);
    CollectionReference collectionReference =
        documentReference.collection('LocationDetails'); // Use `documentReference` instead of `CollectionReference`

    DocumentSnapshot snapshot = await collectionReference.doc(userEmail).get();
    
    if (snapshot.exists) {
      print('User has stored location details');
      
      // Retrieve the details and pass it to the delivery screen
      Map<String, dynamic> locationDetails = snapshot.data() as Map<String, dynamic>;
      // Pass `locationDetails` data to the delivery screen or handle it as needed.
      
    } else {
      print('User has not stored location details');
      // Navigate to the location details screen
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


Future<void> PickUp() async{

  print(  'Delivery'  );




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
            Text('Choose checkout method'),
            Text(widget.userEmail),
             Column(
              children: [
                ElevatedButton(onPressed: 
                () =>{
                  Delivery(
                    context
                  )

                }
                , child: Text('Delivery')
                ),
                ElevatedButton(onPressed: 
                () =>{
                  PickUp()

                }
                , child: Text('Pickup')
                ),


              ],
             
            ),

            
          ],
        ),
      ),


    );
  }
}
