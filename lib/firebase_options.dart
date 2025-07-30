import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmb4BvAXoXpK0cf-j98auOjBuGL77mp9A',
    appId: '1:962559044253:web:f17c621780bb75ead60274',
    messagingSenderId: '962559044253',
    projectId: 'ecommerce-flutter-5507b',
    storageBucket: 'ecommerce-flutter-5507b.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBmb4BvAXoXpK0cf-j98auOjBuGL77mp9A",
    authDomain: "ecommerce-flutter-5507b.firebaseapp.com",
    projectId: "ecommerce-flutter-5507b",
    storageBucket: "ecommerce-flutter-5507b.firebasestorage.app",
    messagingSenderId: "962559044253",
    appId: "1:962559044253:web:f17c621780bb75ead60274",
    measurementId: "G-WJ2X0V60RP",
  );
}