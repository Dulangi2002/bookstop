
import 'package:bookstop/screens/HomeScreen.dart';
import 'package:bookstop/screens/profilephoto.dart';
import 'package:bookstop/screens/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> signInUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No user found for that email."),
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Wrong password provided for that user."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Email",
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => signInUser(),
              child: Text("Sign In"),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => register()),
                );
              },
              child: Text("Don't have an account? Register here."),
            ),
          ],
        ),
      ),
    );
  }
}

profilePhoto() {
 //fetch the profile photo from firebase storage

  return Image.network(
      'https://firebasestorage.googleapis.com/v0/b/bookstop-8b9e9.appspot.com/o/profile%2Fprofile.png?alt=media&token=3b9b9b9a-5b0a-4b0e-8b0a-9b9b9b9b9b9b');

  // return Image.network(
}
