import 'package:flood_relief_system/FloodVictim.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flood_relief_system/User.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';

class SignupPopup extends StatefulWidget {
  const SignupPopup({Key? key}) : super(key: key);

  @override
  _SignupPopupState createState() => _SignupPopupState();
}

class _SignupPopupState extends State<SignupPopup> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _icnoController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error while getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sign Up'),
      content:
      SingleChildScrollView(
      child:Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
            ),
          ),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone',
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11), // Set the maximum length of the phone number
            ],
          ),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Full Address',
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
          TextField(
            controller: _icnoController,
            decoration: InputDecoration(
              labelText: 'IC Number',
            ),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
          ),
          if (_currentPosition != null)
            Text(
              'Current Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
            ),
        ],
      ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              _signUpWithEmailAndPassword();
            },
            child: Text('Sign Up')),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _nameController.text = '';
            _emailController.text = '';
            _phoneController.text = '';
            _passwordController.text = '';
            _addressController.text = '';
            _icnoController.text = '';
          },
          child: const Text('Reset'),
        ),
      ],

    );
  }

  void _signUpWithEmailAndPassword() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Successful signup, do something (e.g., navigate to the next screen)
      print('Signup successful!');
      print('User: ${userCredential.user?.email}');

      FloodVictim fv = FloodVictim(
        name: _nameController.text,
        email: _emailController.text,
        phoneno: _phoneController.text,
        createAt: DateTime.now(),
        fv_address: _addressController.text,
        fv_icno: _icnoController.text,
        fv_long: _currentPosition!.latitude,
        fv_lat: _currentPosition!.longitude,
      );

      await addUser(fv);
      Navigator.of(context).pop();
    } catch (e) {
      // Error occurred during signup, handle the error
      print('Signup error: $e');
      // Show an error message to the user, or handle the error in your preferred way
    }
  }

  Future<void> addUser(FloodVictim fv) async {
    final userRef = FirebaseFirestore.instance.collection('User');
    final uuid = Uuid();
    fv.user_id = uuid.v4();
    fv.userType = "FloodVictim";
    /*
    userRef.set(data).whenComplete(() {
      print('User inserted.');
    });*/
    await userRef.add(fv.toJson());
  }
}
