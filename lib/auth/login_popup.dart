import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flood_relief_system/auth/signup_popup.dart';
import 'package:flood_relief_system/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

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
            _addRescuerLocationToDatabase;
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

  Future<void> _addRescuerLocationToDatabase() async {
    // Retrieve the current location of the Rescuer
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    User? user = FirebaseAuth.instance.currentUser;

    // Get the UID of the logged-in Rescuer
    if (user != null) {
      String rescuerUid = user.uid;

      // Update the Rescuer's location in the Firestore database
      CollectionReference rescuersCollection = FirebaseFirestore.instance.collection('Rescuers');
      await rescuersCollection.doc(rescuerUid).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => RescuerPage()),
      );
    } else {
      // User is not logged in, show a prompt to log in
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Not Logged In'),
            content: Text('Please log in to add your location.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }


  }
}
