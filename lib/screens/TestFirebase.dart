import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirestoreFetch extends StatefulWidget {
  @override
  _TestFirestoreFetchState createState() => _TestFirestoreFetchState();
}
class User {
  final String email;
  final String country;
  final String city;
  final String street;
  final String province;
  final String profileImage;

  User({
    required this.email,
    required this.country,
    required this.city,
    required this.street,
    required this.province,
    required this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      country: json['country'],
      city: json['city'],
      street: json['street'],
      province: json['province'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'country': country,
      'city': city,
      'street': street,
      'province': province,
      'profileImage': profileImage,
    };
  }
}

class _TestFirestoreFetchState extends State<TestFirestoreFetch> {



  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = _auth.currentUser as User?;
    setState(() {});
  }

  Stream<List<String>> getUserEmails() {
    final snapshots = FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: _currentUser?.email)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc['email'] as String)
            .toList());

    return snapshots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Test'),
      ),
      body: Center(
        child: _currentUser == null
            ? CircularProgressIndicator()
            : StreamBuilder<List<String>>(
                stream: getUserEmails(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return Text('No data available');
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data!
                        .map((email) => ListTile(
                              title: Text(email),
                            ))
                        .toList(),
                  );
                },
              ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TestFirestoreFetch(),
  ));
}
