import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flood_relief_system/Admin.dart';
import 'package:flood_relief_system/RescuerLocation.dart';
import 'package:flood_relief_system/auth/signup_popup.dart';
import 'package:flood_relief_system/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../AdminHomePage.dart';
import '../FloodVictim.dart';
import '../Rescuers.dart';
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
        BuildContext context = this.context;

        // Check the user type and perform actions accordingly
        switch (userType) {
          case 'FloodVictim':
            final data = userSnapshot.data() as Map<String, dynamic>;
            FloodVictim fv = FloodVictim.fromJson(data);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (BuildContext context) => HomePage()),
            );
            break;
          case 'Rescuer':
            final data = userSnapshot.data() as Map<String, dynamic>;
            Rescuers rs = Rescuers.fromJson(data);
            _addRescuerLocationToDatabase(context,rs);
            break;
          case 'Admin':
            final data = userSnapshot.data() as Map<String, dynamic>;
            Admin ad = Admin.fromJson(data);
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

  Future<void> _addRescuerLocationToDatabase(BuildContext context, Rescuers rs) async {
    // Retrieve the current location of the Rescuer
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    User? user = FirebaseAuth.instance.currentUser;

    // Get the UID of the logged-in Rescuer
    if (user != null) {
      String rescuerUid = user.uid;
      DateTime datetime = DateTime.now();
      final DateFormat formatter = DateFormat('yyyy-MM-dd-HH:mm:ss');
      final String formatted = formatter.format(datetime);
      String rescuerIdLocation = rescuerUid + formatted;

      // Update the Rescuer's location in the Firestore database
      CollectionReference rescuersCollection = FirebaseFirestore.instance.collection('help_rescuers');
      final rescuerDocRef = rescuersCollection.doc(rescuerUid);
      RescuersLocation rl = RescuersLocation(
        rescuers_id: rescuerUid,
        rescuer_id_location: rescuerIdLocation,
        location_res_lat: position.latitude,
        location_res_long: position.longitude,
        datetime: datetime,
        status: "ONLINE",
      );
      await rescuerDocRef.set(rl.toJson());
      final data = rs.toJson();

      Navigator.pushNamed(
        context, '../RescuerHomePage',
        arguments: {
          data,
        }
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
