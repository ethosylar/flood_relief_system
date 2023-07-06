

import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService{
  final FirebaseAuth _firebaseAuth;
  AuthenticationService(this._firebaseAuth);
  Stream<User?> get authStateChange => _firebaseAuth.authStateChanges();

  Future<String?> signIn(
      {required String email, required String pass}) async{
    try{
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: pass);
      return "Sign in";
    }on FirebaseAuthException catch (e){
      return e.message.toString();
    }
  }

  Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }
}