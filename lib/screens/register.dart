import 'dart:convert';
import 'const.dart';
import 'package:bookstop/screens/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:bookstop/screens/locationdetails.dart';
import 'package:bookstop/const.dart';
import 'package:http/http.dart' as http;

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  void registerUser() async {
    print("function is working");
    //creating an object that pass to the backend
    if (emailcontroller.text.isNotEmpty && passwordController.text.isNotEmpty) {
      var reqbody = {
        "email": emailcontroller.text,
        "password": passwordController.text,
      };

      print(reqbody);

      var response = await http.post(
        Uri.parse(registration),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqbody),
      );

      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse['status']);
    }
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
        body: OrientationBuilder(builder: (context, orientation) {
   
          return _buildPortraitLayout();
        
        }
      

      ),

    );
  }






  


Widget _buildPortraitLayout() {

    
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 50),
              height: 300,
              width: 200,
              child: ClipRect(
                //borderRadius: BorderRadius.all( Radius.circular(100)),
                child: Image.asset(
                  'assets/images/book4.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
              ),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                  color: Colors.white,
                )),
                child: TextFormField(
                  controller: emailcontroller,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      fontSize: 12,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
              ),
              child: TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    fontSize: 12,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () {

                  String email = emailcontroller.text.trim();
                  String password = passwordController.text.trim();
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: email, password: password)
                      .then((value) {
                    print(value.user!.uid);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationDetails(),
                      ),
                    );
                    
                    
                  }).catchError((error) {
                    print(error);
                  });
                  
                  /*
                  String email = emailcontroller.text.trim();
                  String password = passwordController.text.trim();
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: email, password: password)
                      .then((value) {
                    print(value.user!.uid);
                    navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => locationdetails(),
                      ),
                    );
                    
                    
                  }).catchError((error) {
                    print(error);
                  });
*/

                  //registerUser();

                  
                  
                },
                child: Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(155, 205, 210, 1),
                )),

            /*ElevatedButton(
              onPressed: () {
                /*  var data = {
                  "name": emailcontroller.text,
                };*/
               print("fhdfh");
                registerUser();
              },
              child: Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(155, 205, 210, 1),
              ),
            )*/
          ],
        )
      );
      
}
}





