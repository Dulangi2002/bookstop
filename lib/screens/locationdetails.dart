import 'package:bookstop/User.dart';
import 'package:bookstop/screens/checkOut.dart';
import 'package:bookstop/screens/payment.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:bookstop/screens/profilephoto.dart';
import 'package:image_picker/image_picker.dart';

class LocationDetails extends StatefulWidget {
  const LocationDetails({Key? key}) : super(key: key);

  @override
  State<LocationDetails> createState() => _LocationDetailsState();
}

class Location {
  String country;
  String city;
  String street;
  String province;

  Location({
    required this.country,
    required this.city,
    required this.street,
    required this.province,
  });
}

class _LocationDetailsState extends State<LocationDetails> {
  TextEditingController countryController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController provinceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLocationDetail();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Location services disabled'),
          content: Text('Please enable location services.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Map<String, dynamic> createLocationData() {
    return {
      'country': countryController.text,
      'city': cityController.text,
      'street': streetController.text,
      'province': provinceController.text,
    };
  }

  Future<void> addUserLocationDetails() async {
    try {
      String userEmail = FirebaseAuth.instance.currentUser!.email.toString();

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Userdetails')
          .doc('locationdetails')
          .set(createLocationData());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location details added successfully'),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Payment(
            userEmail: userEmail,
            country: countryController.text,
            city: cityController.text,
            street: streetController.text,
            province: provinceController.text,
          ),
        ),
      );
    } catch (error) {
      print(error);
    }
  }

  Future<void> proceed() async {
    try {
      String userEmail = FirebaseAuth.instance.currentUser!.email.toString();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Payment(
            userEmail: userEmail,
            country: countryController.text,
            city: cityController.text,
            street: streetController.text,
            province: provinceController.text,
          ),
        ),
      );
    } catch (error) {
      print(error);
    }
  }

  Future<void> fetchLocationDetail() async {
    try {
      String userEmail = FirebaseAuth.instance.currentUser!.email.toString();

      DocumentReference docRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .collection('Userdetails')
          .doc('locationdetails');

      DocumentSnapshot doc = await docRef.get().then((value) => value);
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      setState(() {
        countryController.text = data['country'];
        cityController.text = data['city'];
        streetController.text = data['street'];
        provinceController.text = data['province'];
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('Location Details'),
        title: Text('Location Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please enter the delivery address',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Form(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: TextFormField(
                      cursorColor: Colors.black,
                      cursorHeight: 20,
                      controller: countryController,
                      decoration: InputDecoration(
                        labelText: 'Country',
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.black,
                          ),
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: TextFormField(
                      cursorColor: Colors.black,
                      cursorHeight: 20,
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: 'City',
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.black,
                          ),
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: TextFormField(
                      controller: streetController,
                      decoration: InputDecoration(
                        labelText: 'Street',
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.black,
                          ),
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: TextFormField(
                      cursorColor: Colors.black,
                      cursorHeight: 20,
                      controller: provinceController,
                      decoration: InputDecoration(
                        labelText: 'Province',
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.black,
                          ),
                        ),
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
                      onPressed: () {
                        _determinePosition().then((position) async {
                          // Use the position data here
                          print(position.latitude);
                          print(position.longitude);
                  
                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                                  position.latitude, position.longitude);
                  
                          setState(() {
                            countryController.text = placemarks.first.country!;
                            cityController.text = placemarks.first.locality!;
                            streetController.text = placemarks.first.street!;
                            provinceController.text =
                                placemarks.first.administrativeArea!;
                          });
                  
                          print(placemarks);
                        }).catchError((error) {
                          print(error);
                        });
                      },
                      child: Text('Get Location'),
                    ),
                  ),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     addUserLocationDetails();
                  //   },
                  //   child: Text('Save address'),
                  // ),
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
                      onPressed: () {
                        if (countryController.text == '' ||
                            cityController.text == '' ||
                            streetController.text == '' ||
                            provinceController.text == '') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter all the fields'),
                            ),
                          );
                        }
                        proceed();
                      },
                      child: Text('Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
