import 'dart:convert';
import 'package:bookstop/screens/Login.dart';
import 'package:bookstop/screens/profilephoto.dart';
import 'package:bookstop/screens/signIn.dart';
import 'package:bookstop/screens/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bookstop/screens/locationdetails.dart';
import 'package:http/http.dart' as http;

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  final emailcontroller = TextEditingController();
  final passwordController = TextEditingController();
  bool isValidEmail(String email) {
    // Use a regular expression for basic email validation
    // This regex might not cover all edge cases, but it's a simple example
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> register() async {
    String email = emailcontroller.text.trim();
    String password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide email and password'),
        ),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 6 characters'),
        ),
      );
      return;
    }
//chwck if email is valid
    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address'),
        ),
      );
      return;
    }

//check if user exists
    try {
      final user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileImage(),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      var message = 'An error occured, please check your credentials';

      if (error.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (error.message != null) {
        message = error.message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (error) {
      print(error);
    }
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
         
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  cursorHeight: 20,
                  controller: emailcontroller,
                  decoration: InputDecoration(
                    enabledBorder:
                        OutlineInputBorder(borderSide: BorderSide(width: 2)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.black,
                      ),
                    ),
                    labelText: 'Username',
                    labelStyle: TextStyle(
                      fontSize: 12,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 15),
                child: TextFormField(
                  cursorColor: Colors.black,
                  controller: passwordController,
                  decoration: InputDecoration(
                    enabledBorder:
                        OutlineInputBorder(borderSide: BorderSide(width: 2)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.black,
                      ),
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      fontSize: 12,
                    ),
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
                      )),
                  //add the same styling as the input fields

                  onPressed: () {
                    register();
                  },
                  child: Text('Register'),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                height: 50,
                child: TextButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                    overlayColor:
                        MaterialStateProperty.all<Color>(Colors.transparent),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => login()),
                    );
                  },
                  child: Text(
                    'Already have an account? Sign in',
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
    )));
  }
}
