import 'package:firebase_database/firebase_database.dart';
import 'package:flood_relief_system/User.dart';

class Admin extends Users {
  String? admin_id;
  String? admin_fullname;
  String? admin_position;
  String? admin_bodyid;

  Admin({
    String? user_id,
    String? email,
    String? password,
    DateTime? createAt,
    String? name,
    String? phoneno,
    this.admin_id,
    this.admin_fullname,
    this.admin_position,
    this.admin_bodyid,
  }) : super(user_id: user_id, email: email,  createAt: createAt, phoneno: phoneno, name: name);

  factory Admin.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<String, dynamic>?;
    return Admin(
      user_id: data?['user_id'] as String?,
      email: data?['email'] as String?,
      password: data?['password'] as String?,
      createAt: DateTime.parse(data?['createAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'email': email,
      'createAt': createAt?.toIso8601String(),
    };
  }
}