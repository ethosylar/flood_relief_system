import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flood_relief_system/auth/signup_popup.dart';
import 'package:flood_relief_system/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../AdminHomePage.dart';
import '../RescuerHomePage.dart';


class LoginPopup extends StatefulWidget {
  @override
  _LoginPopupState createState() => _LoginPopupState();
}

class _LoginPopupState extends State<LoginPopup> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Login'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _navigateToSignupPage(); // Call the method to navigate to the signup page
          },
          child: Text('Sign Up'),
        ),
        ElevatedButton(
          onPressed: () {
            _loginWithEmailAndPassword();
          },
          child: Text('Login'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }

  void _loginWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Successful login, do something (e.g., navigate to the next screen)
      print('Login successful!');
      print('User: ${userCredential.user?.email}');
      checkUserType();
    } catch (e) {
      // Error occurred during login, handle the error
      print('Login error: $e');
      // Show an error message to the user, or handle the error in your preferred way
    }
  }

  void checkUserType() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();

      if (userSnapshot.exists) {
        String userType = userSnapshot.get('userType');

        // Check the user type and perform actions accordingly
        switch (userType) {
          case 'FloodVictim':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (BuildContext context) => HomePage()),
            );
            break;
          case 'Rescuer':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (BuildContext context) => RescuerPage()),
            );
            break;
          case 'Admin':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (BuildContext context) => AdminPage()),
            );
            break;
          default:
          // Unknown user type or handling for other user types
            break;
        }
      }
    }
  }

  void _navigateToSignupPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignupPopup(),
      ),
    );
  }

  void navigateToRespectivePage(String userType, BuildContext context) {

  }
}
