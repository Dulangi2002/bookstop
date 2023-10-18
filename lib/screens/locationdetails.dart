import 'package:bookstop/User.dart';
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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
            .collection('Users').doc(userEmail).collection('Userdetails').doc('locationdetails').set(createLocationData());

    

      /*  .collection('Users')
          .doc(userEmail)
          .collection('UserLocationDetails')
          .add(createLocationData());*/










      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileImage(),
        ),
      );
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookstop'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              child: Column(
                children: [
                  TextFormField(
                    controller: countryController,
                    decoration: InputDecoration(
                      labelText: 'Country',
                    ),
                  ),
                  TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                    ),
                  ),
                  TextFormField(
                    controller: streetController,
                    decoration: InputDecoration(
                      labelText: 'Street',
                    ),
                  ),
                  TextFormField(
                    controller: provinceController,
                    decoration: InputDecoration(
                      labelText: 'Province',
                    ),
                  ),
                  ElevatedButton(
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
                  ElevatedButton(
                    onPressed: () {
                      addUserLocationDetails();
                    },
                    child: Text('Next'),
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
