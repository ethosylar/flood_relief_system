import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flood_relief_system/interface.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'authenticationService.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the signup page
            Navigator.pushNamed(context, '/signup');
          },
          child: Text('Sign Up'),
        ),
      ),
    );
  }
}

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Perform signup logic here
            Navigator.pushNamed(context, '/home');
          },
          child: Text('Sign Up'),
        ),
      ),
    );
  }
}


