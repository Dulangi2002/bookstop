import 'package:bookstop/screens/pruchaseHistory.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final String userEmail;
  final TextEditingController emailcontroller;
  Profile({Key? key, required this.userEmail})
      : emailcontroller = TextEditingController(text: userEmail),
        super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String userEmail;

  @override
  void initState() {
    super.initState();
    userEmail = widget.userEmail;
  } 

  Future<void> EditEmail() async {
    try {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Users').doc(userEmail);

      String newEmail = widget.emailcontroller.text.trim();
      documentReference.update(
        {
          'email': newEmail,
        },
      );
      setState(() {
        userEmail = newEmail;
      });
    } catch (e) {
      print('Error deleting favorite: $e');
    }
  }

  Future<void> ChangePassword() async {
    try {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Users').doc(userEmail);
      String newPassword = widget.emailcontroller.text.trim();
      documentReference.update(
        {
          'password': newPassword,
        },
      );
      setState(() {
        userEmail = newPassword;
      });
    } catch (e) {
      print('Error deleting favorite: $e');
    }
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        Row(
          children: [
            Text(
              userEmail,
            ),
            IconButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Edit Email'),
                      content: TextField(
                        onChanged: (value) {
                          userEmail = value;
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await EditEmail();
                            Navigator.pop(context);
                          },
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(BootstrapIcons.pen))
          ],
        ),

        Row(
          children: [
            Text(
              'Password',
            ),
            IconButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Change Password'),
                      content: TextField(
                        onChanged: (value) {
                          userEmail = value;
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await ChangePassword();
                            Navigator.pop(context);
                          },
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(BootstrapIcons.pen))
          ],
        ),  

        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => purchaseHistory(userEmail: widget.userEmail,),
              ),
            );
          },
          child: Text('Purchase History'),
        )

      ]),
    ));
  }
}
