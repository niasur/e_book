import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'app.dart'; // Root widget (MyApp)
import 'services/connectivity_utils.dart';

import 'providers/theme.dart';
import 'providers/cart.dart';
import 'providers/shop.dart';
import 'providers/order.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi koneksi
  ConnectivityUtils.getInstance().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => Cart()),
        ChangeNotifierProvider(create: (_) => Shop()),
        ChangeNotifierProvider(create: (_) => Orders()),
      ],
      child: const MyApp(),
    ),
  );
}