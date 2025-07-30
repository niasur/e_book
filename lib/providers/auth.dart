import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.deepPurple,
      fontFamily: 'Lato',
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: Colors.deepOrange,
      ),
    );
  }

  Future<void> tryAutoLogin() async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulasi delay
    if (_auth.currentUser != null) {
      notifyListeners();
    }
  }

  // 🔐 LOGIN
  Future<bool> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners(); // penting agar UI tahu
      return true;
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.message}');
      return false;
    } catch (e) {
      print('Login unknown error: $e');
      return false;
    }
  }

  // 📝 REGISTER
  Future<bool> registerWithEmail(String email, String password, String name) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user == null) return false;

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print('Register error: ${e.message}');
      return false;
    } catch (e) {
      print('Register unknown error: $e');
      return false;
    }
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  // Cek apakah user sudah login
  bool get isAuth => _auth.currentUser != null;

  // Dapatkan user saat ini
  User? get currentUser => _auth.currentUser;
}