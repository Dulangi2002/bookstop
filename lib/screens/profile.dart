import 'package:bookstop/screens/HomeScreen.dart';
import 'package:bookstop/screens/cart.dart';
import 'package:bookstop/screens/favorites.dart';
import 'package:bookstop/screens/pruchaseHistory.dart';
import 'package:bookstop/screens/signIn.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  final String userEmail;
  final TextEditingController emailcontroller;
  final TextEditingController passwordcontroller;
  Profile({Key? key, required this.userEmail})
      : emailcontroller = TextEditingController(text: userEmail),
        passwordcontroller = TextEditingController(text: userEmail),
        super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String userEmail;

  final ImagePicker _picker = ImagePicker();
  List<CameraDescription> cameras = [];

  late SharedPreferences _prefs;
  String _imagePath = '';

  File? image;

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    userEmail = widget.userEmail;
    fetchProfilePhoto();
  }

  Future<String> fetchProfilePhoto() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .get()
          .then((value) => value);
      String profileImage = doc['profileimage'];
      setState(() {
        
        image = File(profileImage); 
      });
      
      return profileImage;

    } catch (error) {
      print("Error fetching profile photo: $error");
      return "";
    }
  }

  Future<void> editEmail(String newEmail) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String currentEmail = user.email!;
        print(currentEmail);

        await user.updateEmail(newEmail);
        DocumentReference documentReference =
            FirebaseFirestore.instance.collection('Users').doc(currentEmail);
        DocumentReference newReference =
            FirebaseFirestore.instance.collection('Users').doc(newEmail);

        CollectionReference cartReference = FirebaseFirestore.instance
            .collection('Users')
            .doc(currentEmail)
            .collection('Cart');

        CollectionReference favoritesReference = FirebaseFirestore.instance
            .collection('Users')
            .doc(currentEmail)
            .collection('Favorites');

        CollectionReference ordersReference = FirebaseFirestore.instance
            .collection('Users')
            .doc(currentEmail)
            .collection('Orders');

        CollectionReference cardDetailsReference = FirebaseFirestore.instance
            .collection('Users')
            .doc(currentEmail)
            .collection('CardDetails');

        CollectionReference userDetailsReference = FirebaseFirestore.instance
            .collection('Users')
            .doc(currentEmail)
            .collection('Userdetails');

        QuerySnapshot querySnapshot = await cartReference.get();
        querySnapshot.docs.forEach((document) {
          newReference.collection('Cart').doc(document.id).set(
                document.data() as Map<String, dynamic>,
              );
        });

        QuerySnapshot querySnapshot2 = await favoritesReference.get();
        querySnapshot2.docs.forEach((document) {
          newReference.collection('Favorites').doc(document.id).set(
                document.data() as Map<String, dynamic>,
              );
        });

        QuerySnapshot querySnapshot3 = await ordersReference.get();
        querySnapshot3.docs.forEach((document) {
          newReference.collection('Orders').doc(document.id).set(
                document.data() as Map<String, dynamic>,
              );
        });

        QuerySnapshot querySnapshot4 = await cardDetailsReference.get();
        querySnapshot4.docs.forEach((document) {
          newReference.collection('CardDetails').doc(document.id).set(
                document.data() as Map<String, dynamic>,
              );
        });

        QuerySnapshot querySnapshot5 = await userDetailsReference.get();
        querySnapshot5.docs.forEach((document) {
          newReference.collection('Userdetails').doc(document.id).set(
                document.data() as Map<String, dynamic>,
              );
        });

        DocumentSnapshot<Object?> value = await documentReference.get();
        if (value.exists) {
          newReference.set(value.data()!);
        }

        await documentReference.delete();

        setState(() {
          userEmail = newEmail;
        });
      }
    } catch (e) {
      print('Error updating email: $e');
    }
  }

  Future<void> addprofilephoto() async {
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a profile photo'),
        ),
      );
      return;
    }

    try {
      String userEmail = FirebaseAuth.instance.currentUser!.email.toString();
      await FirebaseStorage.instance
          .ref('profilephoto/$userEmail')
          .putFile(image!);
      String downloadURL = await FirebaseStorage.instance
          .ref('profilephoto/$userEmail')
          .getDownloadURL();
      print(downloadURL);

      await FirebaseFirestore.instance.collection('Users').doc(userEmail).set(
        {'profileimage': downloadURL},
      );


      //show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile photo added successfully'),
        ),
      );
      
    } catch (error) {
      print("Error adding profile photo: $error");
    }
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    // Retrieve the image path from shared preferences
    _imagePath = _prefs.getString('imagePath') ?? '';
    if (_imagePath.isNotEmpty) {
      // If there's an image path, load the image file using the path
      setState(() {
        image = File(_imagePath);
      });
    }
  }

  Future<void> _initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  }

  Future pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;

    final imageTemporary = File(image.path);
    setState(() => this.image = imageTemporary);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              margin: EdgeInsets.only(top: 60),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  imageProfile(),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only( left: 15, right: 15),
              margin: EdgeInsets.only(top: 10, left: 15, right: 15),
              foregroundDecoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(0),
              ),
              
              height: 60,
              width: 500,
              child: Row(
                children: [
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      
                    ),
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
                                  await editEmail(userEmail);

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
            ),
            Container(
              margin: EdgeInsets.only(top: 10, left: 15, right: 15),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      
                    ),
                    alignment: Alignment.centerLeft,
                    fixedSize: Size(500, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    side: BorderSide(
                      width: 2,
                      color: Colors.black,
                    )),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PurchaseHistory(
                        userEmail: userEmail,
                      ),
                    ),
                  );
                },
                child: Text('Purchase History'),
              ),
            )
          ]),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.house),
              label: 'Home',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.heart),
              label: 'Favorites',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.cart),
              label: 'Cart',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(BootstrapIcons.person),
              label: 'Profile',
              backgroundColor: Colors.black,
            ),
          ],
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => favorites(userEmail: userEmail),
                ),
              );
            }
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyCart(
                    userEmail: userEmail,
                  ),
                ),
              );
            }
            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Profile(
                    userEmail: userEmail,
                  ),
                ),
              );
            }
          },
        ));
  }

  Widget imageProfile() {
    return Column(
      children: <Widget>[
       
        CircleAvatar(
          backgroundColor: Colors.grey[400],
          radius: 80.0,
          backgroundImage: image != null
              ? Image.network(
                  image!.path,
                  fit: BoxFit.cover,
                ).image // Use FileImage if image is not null
              
              : AssetImage('assets/images/profile.jpg') as ImageProvider,
        ),
        Positioned(
          child: Container(
            margin: EdgeInsets.only(top: 10, left: 15, right: 15),
            width: 120,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.black87,
            ),
            child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: ((builder) => bottomSheet()),
                  );
                },
                child: Container(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 28.0,
                  ),
                )),
          ),
        ),
      ],
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 200.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Choose Profile Photo',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          if (image != null)
            ElevatedButton(
              onPressed: addprofilephoto,
              child: Text('Save'),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                icon: Icon(Icons.camera),
                onPressed: () {
                  pickImage(ImageSource.camera);
                },
                label: Text('Camera'),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.image),
                onPressed: () {
                  pickImage(ImageSource.gallery);
                },
                label: Text('Gallery'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
