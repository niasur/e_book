import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared/http_exception.dart';
import '../shared/theme.dart';

class Auth with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  ThemeData theme = lightTheme;
  Key key = UniqueKey();

  bool get isAuth => token != null;

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId => _userId;

  Future<void> signup({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      _token = await user?.getIdToken();
      _userId = user?.uid;
      _expiryDate = DateTime.now().add(const Duration(hours: 1));

      _autoLogout();
      _saveUserData(false);
      notifyListeners();
    } catch (error) {
      throw HttpException('Signup failed: ${error.toString()}');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      _token = await user?.getIdToken();
      _userId = user?.uid;
      _expiryDate = DateTime.now().add(const Duration(hours: 1));

      _autoLogout();
      _saveUserData(false);
      notifyListeners();
    } catch (error) {
      throw HttpException('Login failed: ${error.toString()}');
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final userData =
    json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) return false;

    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = expiryDate;

    _autoLogout();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    _authTimer?.cancel();
    _authTimer = null;

    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');

    if (userData != null) {
      final data = json.decode(userData) as Map<String, dynamic>;
      if (data['loginType'] == true) {
        await _googleSignIn.signOut();
      }
    }

    await _auth.signOut();
    await prefs.clear();
    notifyListeners();
  }

  void _autoLogout() {
    _authTimer?.cancel();
    final timeToExpiry =
        _expiryDate?.difference(DateTime.now()).inSeconds ?? 0;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  void _saveUserData(bool isSocialLogin) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'userId': _userId,
      'expiryDate': _expiryDate!.toIso8601String(),
      'loginType': isSocialLogin,
    });
    prefs.setString('userData', userData);
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authResult = await _auth.signInWithCredential(credential);
      final user = authResult.user;

      if (user == null) {
        throw HttpException('Google sign-in failed: user is null');
      }

      final idToken = await user.getIdToken();
      _token = idToken;
      _userId = user.uid;

      _expiryDate = DateTime.now().add(const Duration(hours: 1));
      _saveUserData(true);
      notifyListeners();

      return true;
    } catch (e) {
      throw HttpException('Google sign-in failed: ${e.toString()}');
    }
  }

  void setTheme(ThemeData value, bool isDark) {
    theme = value;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("isDark", isDark);
    });
    notifyListeners();
  }

  ThemeData get getTheme => theme;

  Future<ThemeData> checkAppTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;

    final themeData = isDark ? darkTheme : lightTheme;
    setTheme(themeData, isDark);

    return themeData;
  }
}