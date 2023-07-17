import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flood_relief_system/User.dart';

Rescuers rescuerFromJson(String str) => Rescuers.fromJson(json.decode(str));
String rescuerToJson(Rescuers data) => json.encode(data.toJson());

class Rescuers extends Users {
  //String? rescuers_id;
  //String? rescuers_fullname;
  //String? rescuers_telno;
  String? rescuers_bodyid;
  String? rescuers_position;
  String? rescuers_type;

  Rescuers({
    String? user_id,
    String? email,
    String? password,
    DateTime? createAt,
    String? name,
    String? phoneno,
    String? userType,
    //this.rescuers_id,
    //this.rescuers_fullname,
    //this.rescuers_telno,
    this.rescuers_bodyid,
    this.rescuers_position,
    this.rescuers_type,
  }) : super(user_id: user_id, email: email, createAt: createAt, phoneno: phoneno, name: name);

  factory Rescuers.fromJson(Map<String, dynamic> json) => Rescuers(
      user_id: json["user_id"],
      email: json["email"],
      createAt: json["createAt"],
      name: json["name"],
      phoneno: json["phone"],
      userType: json["userType"],
      rescuers_bodyid: json["rescuers_bodyid"],
      rescuers_position: json["rescuers_position"],
      rescuers_type: json["rescuers_type"],
      password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": user_id,
    "name": name,
    "email": email,
    "createAt": createAt,
    "phone": phoneno,
    "userType": userType,
    "rescuers_bodyid": rescuers_bodyid,
    "rescuers_position": rescuers_position,
    "rescuers_type": rescuers_type,
    "password": password,
  };
}