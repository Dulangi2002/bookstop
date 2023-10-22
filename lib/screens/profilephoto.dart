import 'package:bookstop/screens/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({super.key});

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  final ImagePicker _picker = ImagePicker();
  List<CameraDescription> cameras = [];

  late SharedPreferences _prefs;
  String _imagePath = '';

  File? image;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initPrefs();
  }

  Future<void> addprofilephoto() async {
    try {
      String userEmail = FirebaseAuth.instance.currentUser!.email.toString();
      await FirebaseStorage.instance
          .ref('profilephoto/$userEmail')
          .putFile(image!);
      String downloadURL = await FirebaseStorage.instance
          .ref('profilephoto/$userEmail')
          .getDownloadURL();
      print(downloadURL);

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .set(
        {'profileimage': downloadURL},
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
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
      appBar: AppBar(
        title: Text('Profile Photo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            imageProfile(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget imageProfile() {
    return Stack(
      children: <Widget>[
        CircleAvatar(
          radius: 80.0,
          backgroundImage: image != null ? FileImage(image!) : null,
          child: image == null
              ? Icon(
                  Icons.account_circle,
                  color: Color(0xFF81361E),
                  size: 60,
                )
              : null,
        ),
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: ((builder) => bottomSheet()),
              );
            },
            child: Icon(
              Icons.camera_alt,
              color: Colors.teal,
              size: 28.0,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            addprofilephoto();
          },
          child: Text('Next'),
        ),
      ],
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
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
