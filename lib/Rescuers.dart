import 'package:firebase_database/firebase_database.dart';
import 'package:flood_relief_system/User.dart';

class Rescuers extends Users {
  String? rescuers_id;
  String? rescuers_fullname;
  String? rescuers_telno;
  String? rescuers_bodyid;

  Rescuers({
    String? user_id,
    String? email,
    String? password,
    DateTime? createAt,
    String? name,
    String? phoneno,
    this.rescuers_id,
    this.rescuers_fullname,
    this.rescuers_telno,
    this.rescuers_bodyid,
  }) : super(user_id: user_id, email: email, createAt: createAt, phoneno: phoneno, name: name);

  factory Rescuers.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<String, dynamic>?;
    return Rescuers(
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