import 'dart:convert';
import 'dart:core';

import 'package:firebase_database/firebase_database.dart';
import 'package:flood_relief_system/User.dart';

FloodVictim fvFromJson(String str) => FloodVictim.fromJson(json.decode(str));
String fvToJson(FloodVictim data) => json.encode(data.toJson());

class FloodVictim extends Users {
  //String? fv_id;
  //String? fv_fullname;
  //String? fv_telno;
  String? fv_address;
  String? fv_icno;
  double? fv_lat;
  double? fv_long;

  FloodVictim({
    String? user_id,
    String? email,
    String? password,
    DateTime? createAt,
    String? name,
    String? phoneno,
    String? userType,
    //this.fv_id,
    //this.fv_fullname,
    this.fv_address,
    this.fv_icno,
    this.fv_lat,
    this.fv_long,
  }) : super(user_id: user_id, email: email,  createAt: createAt, phoneno: phoneno, name: name);

  factory FloodVictim.fromJson(Map<String, dynamic> json) => FloodVictim(
      user_id: json["user_id"],
      email: json["email"],
      createAt: json["createAt"],
      name: json["name"],
      phoneno: json["phone"],
      userType: json["userType"],
      fv_address: json["fv_address"],
      fv_icno: json["fv_icno"],
    fv_lat: json["fv_lat"],
    fv_long: json["fv_long"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": user_id,
    "name": name,
    "email": email,
    "createAt": createAt,
    "phone": phoneno,
    "userType": userType,
    "fv_address": fv_address,
    "fv_icno": fv_icno,
    "fv_lat": fv_lat,
    "fv_long": fv_long,
  };
}