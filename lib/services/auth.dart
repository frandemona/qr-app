import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

// import 'package:flutter/cupertino.dart';

class AuthService /* with ChangeNotifier */ {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ///
  /// return the Future with firebase user object User if one exists
  ///
  User get getUser => _auth.currentUser;

  Stream<User> get user => _auth.authStateChanges();

  // wrapping the firebase calls
  Future<void> logout() {
    var result = _auth.signOut();
    // notifyListeners();
    return result;
  }

  Future<User> loginUser({String email, String password}) async {
    try {
      var result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // since something changed, let's notify the listeners...
      updateUserData(result.user);
      // notifyListeners();
      return result.user;
    } catch (e) {
      throw new FirebaseAuthException(message: e.message, code: e.code);
    }
  }

  Future<void> updateUserData(User firebaseUser) {
    DocumentReference userRef = _db.collection('users').doc(firebaseUser.uid);

    if (userRef != null) {
      return userRef
          .set({'lastActivity': DateTime.now()}, SetOptions(merge: true));
    }
    return null;
  }

  Future<void> sendPasswordResetEmail({String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // since something changed, let's notify the listeners...
      // notifyListeners();
      return;
    } catch (e) {
      throw new FirebaseAuthException(code: e.code, message: e.message);
    }
  }
}
