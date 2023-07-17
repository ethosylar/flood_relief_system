import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flood_relief_system/splashscreens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main () async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFirstLaunch(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          bool isFirstLaunch = snapshot.data ?? true;
          if (isFirstLaunch) {
            _clearFirebaseAuth();
          }
          return MaterialApp(
            title: 'My App',
            home: splash(),
          );
        }
      },
    );
  }

  Future<bool> _isFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    return isFirstLaunch;
  }

  Future<void> _clearFirebaseAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);

    // Clear Firebase Authentication data
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
  }
}