import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth.dart';
import 'providers/shop.dart';
import 'providers/cart.dart';
import 'providers/order.dart';
import 'providers/theme.dart';

import 'screens/auth_screen.dart';
import 'screens/book_category_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/products_overview_screen.dart';
import 'screens/profile_edit_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProvider(create: (_) => Shop()),
        ChangeNotifierProvider(create: (_) => Cart()),
        ChangeNotifierProvider(create: (_) => Orders()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<Auth, ThemeProvider>(
        builder: (ctx, auth, themeProvider, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: auth.key,
          title: 'eBook Store',
          themeMode: themeProvider.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: auth.isAuth
              ? const HomeScreen()
              : FutureBuilder(
            future: auth.tryAutoLogin(),
            builder: (ctx, authSnapshot) =>
            authSnapshot.connectionState == ConnectionState.waiting
                ? const SplashScreen()
                : const LoginScreen(),
          ),
          routes: {
            '/login': (ctx) => const LoginScreen(),
            '/register': (ctx) => const AuthScreen(),
            '/home': (ctx) => const HomeScreen(),
            '/products': (ctx) => const ProductsOverviewScreen(),
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            CategoryBookScreen.routeName: (ctx) => const CategoryBookScreen(),
            '/edit-profile': (ctx) => const ProfileEditScreen(),
          },
          onGenerateRoute: (settings) {
            // Misalnya: Navigasi manual ke AuthScreen dengan data via arguments
            if (settings.name == '/auth') {
              return MaterialPageRoute(
                builder: (_) => const AuthScreen(),
                settings: settings,
              );
            }
            return null;
          },
          onUnknownRoute: (_) =>
              MaterialPageRoute(builder: (_) => const HomeScreen()),
        ),
      ),
    );
  }
}