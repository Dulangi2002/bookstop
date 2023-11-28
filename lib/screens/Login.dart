import 'dart:io';
import 'dart:math';
import 'package:bookstop/screens/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import './register.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  Future<String?> fetchProfileImage() async {
    try {
      String userEmail = FirebaseAuth.instance.currentUser!.email.toString();
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .get();

      // Use null-aware operator to handle null value
      String? profilePhoto = doc['profileimage'] as String?;

      return profilePhoto;
    } catch (e) {
      print('Error fetching profile image: $e');
      return null;
    }
  }

  Future<void> login() async {
    String email = emailcontroller.text.trim();
    String password = passwordcontroller.text.trim();
    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Provide credentials'),
            content: Text('Please enter your email'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    } else if (password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Provide credentials'),
            content: Text('Please enter your password'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    } else {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        String? profileImagePath = await fetchProfileImage();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'user-not-found') {
            print('No user found for that email.');
          } else if (e.code == 'wrong-password') {
            print('Wrong password provided for that user.');
          }
        }
        print('Error: $e');
      }
    }
  }

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
          width: MediaQuery.of(context).size.width,
          height: 800,
              
              child:
            
          
            Column(
              mainAxisAlignment: MainAxisAlignment.center,

             children:[
              Container(
                  margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
             
                   
                        // padding: EdgeInsets.only(left: 20 , bottom: 20  , right: 20 , top: 60),

                        child: TextFormField(
                          cursorColor: Colors.black,
                          cursorHeight: 20,
                          controller: emailcontroller,
                       
                          decoration: InputDecoration(
                           enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black , width: 2),
                            ),


                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black , width: 2),
                            ),
                            labelText: 'Email address',
                            labelStyle: TextStyle(fontSize: 12),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                           

                         
                          ),
                        ),
                      ),
                      
                      Container(
                        margin: EdgeInsets.only(
                            top: 10, left: 15, right: 15, bottom: 15),  
                        child: TextFormField(
                          
                          cursorColor: Colors.black,

                          controller: passwordcontroller,
                          
                          decoration: InputDecoration(
                           enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black , width: 2),
                            ),
                             focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2 , color: Colors.black , ),
                    ),
                            labelText: 'Password',
                            labelStyle: TextStyle(fontSize: 12),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          
                          ),
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
                           fixedSize: Size(500, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                  
                    ),
                     side: BorderSide(
                        width: 2,
                        color: Colors.black,
                      )
                  ),
                            onPressed: login,
                            child: Text(
                              'Sign in',
                          
                            ),
                          ),
                        ),
                      
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        width: 200,
                        height: 50,
                        child: TextButton(
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            overlayColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => register()),
                            );
                          },
                          child: Text(
                            'Not registered yet? Sign up',
                            style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],                      
            ),        
          ),  
        );
  }
}
  
      

