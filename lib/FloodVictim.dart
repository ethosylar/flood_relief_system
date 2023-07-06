import 'package:firebase_database/firebase_database.dart';
import 'package:flood_relief_system/User.dart';

class FloodVictim extends Users {
  String? fv_id;
  String? fv_fullname;
  String? fv_telno;
  String? fv_address;
  String? fv_icno;

  FloodVictim({
    String? user_id,
    String? email,
    String? password,
    DateTime? createAt,
    String? name,
    String? phoneno,
    this.fv_id,
    this.fv_fullname,
    this.fv_telno,
    this.fv_address,
    this.fv_icno,
  }) : super(user_id: user_id, email: email,  createAt: createAt, phoneno: phoneno, name: name);

  factory FloodVictim.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<String, dynamic>?;
    return FloodVictim(
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