import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final double price;
  final String description;
  final List<String> category;
  final String imageUrl;
  final String author;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.description,
    required this.imageUrl,
    this.isFavorite = false,
    required this.author,
  });

  Future<void> toggleFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    try {
      final docRef = FirebaseFirestore.instance
          .collection('userFavorites')
          .doc(user.uid)
          .collection('favorites')
          .doc(id);

      if (isFavorite) {
        await docRef.set({'isFavorite': true});
      } else {
        await docRef.delete();
      }
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }

  static Future<bool> isFavorited(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final docRef = FirebaseFirestore.instance
        .collection('userFavorites')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId);

    final doc = await docRef.get();
    return doc.exists;
  }
}