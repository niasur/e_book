import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// Warna dasar
const Color lightBG = Colors.white;
const Color darkBG = Colors.black;
const Color lightPrimary = Colors.white;
const Color darkPrimary = Colors.black;

// Tema terang
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: lightBG,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Colors.indigo,
    onPrimary: Colors.white,
    secondary: Colors.deepOrange,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: lightBG,
    onBackground: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
  ),
);

// Tema gelap
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: darkBG,
  appBarTheme: AppBarTheme(
    backgroundColor: darkBG,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: Colors.teal,
    onPrimary: Colors.black,
    secondary: Colors.orangeAccent,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: darkBG,
    onBackground: Colors.white,
    surface: Colors.grey.shade800,
    onSurface: Colors.white,
  ),
);