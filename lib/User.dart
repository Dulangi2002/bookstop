import 'package:flutter/material.dart';

class User {
  String email;
  String country;
  String city;
  String street;
  String province;
  String profileimage;

  User(

      {
      required this.email,
        
      required this.country,
      required this.city,
      required this.street,
      required this.province,
      required this.profileimage});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'country': country,
      'city': city,
      'street': street,
      'province': province,
      'profileimage': profileimage
    };
  }
/*
  factory User.fromMap(Map<String, dynamic> json) {
    return User(
        email: json['email'],
        country: json['country'],
        city: json['city'],
        street: json['street'],
        province: json['province'],
        profileimage: json['profileimage']);
  }
/*
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        email: json['email'],
        country: json['country'],
        city: json['city'],
        street: json['street'],
        province: json['province'],
        profileimage: json['profileimage']);
  }**/

  toList() {}*/


    static User fromJson(Map<String, dynamic> json) =>  User(
        email: json['email'],
        country: json['country'],
        city: json['city'],
        street: json['street'],
        province: json['province'],
        profileimage: json['profileimage']
      );


}
