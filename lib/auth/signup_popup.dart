import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flood_relief_system/User.dart';

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
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sign Up'),
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
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone',
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
        ElevatedButton(
            onPressed: () {
              Users user = Users(
                name: _nameController.text,
                email: _emailController.text,
                phoneno: _phoneController.text,
                createAt: DateTime.now(),
              );
              addUser(user, context);
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
      Navigator.of(context).pop();
    } catch (e) {
      // Error occurred during signup, handle the error
      print('Signup error: $e');
      // Show an error message to the user, or handle the error in your preferred way
    }
  }

  void addUser(Users user, BuildContext context) {
    final userRef = FirebaseFirestore.instance.collection('User').doc('FloodVictim');
    user.user_id = userRef.id;
    final data = user.toJson();
    userRef.set(data).whenComplete(() {
      print('User inserted.');
    });
  }
}
