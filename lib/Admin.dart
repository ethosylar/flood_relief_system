import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flood_relief_system/User.dart';

Admin adminFromJson(String str) => Admin.fromJson(json.decode(str));
String adminToJson(Admin data) => json.encode(data.toJson());

class Admin extends Users {
  //String? admin_id;
  //String? admin_fullname;
  String? admin_position;
  String? admin_bodyid;
  String? admin_type;

  Admin({
    String? user_id,
    String? email,
    String? password,
    DateTime? createAt,
    String? name,
    String? phoneno,
    String? userType,
    //this.admin_id,
    //this.admin_fullname,
    this.admin_position,
    this.admin_bodyid,
    this.admin_type,
  }) : super(user_id: user_id, email: email,  createAt: createAt, phoneno: phoneno, name: name);

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
    user_id: json["user_id"],
    email: json["email"],
    createAt: json["createAt"],
    name: json["name"],
    phoneno: json["phone"],
    userType: json["userType"],
    admin_position: json["admin_position"],
    admin_bodyid: json["admin_bodyid"],
    admin_type: json["admin_type"],

  );

  Map<String, dynamic> toJson() => {
    "user_id": user_id,
    "name": name,
    "email": email,
    "createAt": createAt,
    "phone": phoneno,
    "userType": userType,
    "admin_position": admin_position,
    "admin_bodyid": admin_bodyid,
    "admin_type": admin_type,
  };
}