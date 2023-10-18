import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FetchUserData {
  static Future<String> fetchUserEmail() async {
    String userEmail = FirebaseAuth.instance.currentUser!.email.toString();
    return userEmail;
  }

  static Future<String> fetchProfilePhoto() async {
    String userEmail = FirebaseAuth.instance.currentUser!.email.toString();
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userEmail)
        .get();
    String profilePhoto = doc['profileimage'];
    return profilePhoto;
    if (profilePhoto == null) {
      return 'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png';
    } else {
      return profilePhoto;
    }
  }
}
