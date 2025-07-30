import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:e_book/providers/product.dart';

class Shop with ChangeNotifier {
  List<Product> _items = [];
  final List<Product> _cartItems = [];

  Shop();

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  List<Product> get cartItems {
    return [..._cartItems];
  }

  Future<void> fetchAndSetProducts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Ambil semua produk dari Firestore
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      // Ambil data favorit user
      final favoriteSnapshot = await FirebaseFirestore.instance
          .collection('userFavorites')
          .doc(user.uid)
          .collection('favorites')
          .get();

      final favoriteIds = favoriteSnapshot.docs.map((doc) => doc.id).toSet();

      final List<Product> loadedProducts = [];

      for (var doc in productSnapshot.docs) {
        final data = doc.data();
        loadedProducts.add(Product(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] as num).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          category: List<String>.from(data['category'] ?? []),
          isFavorite: favoriteIds.contains(doc.id),
          author: data['author'] ?? 'Unknown',

        ));
      }

      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      print('Fetch products error: $e');
      rethrow;
    }
  }

  Future<void> toggleFavoriteStatus(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final productIndex = _items.indexWhere((prod) => prod.id == productId);
    if (productIndex >= 0) {
      final currentStatus = _items[productIndex].isFavorite;
      _items[productIndex].isFavorite = !currentStatus;
      notifyListeners();

      final favRef = FirebaseFirestore.instance
          .collection('userFavorites')
          .doc(user.uid)
          .collection('favorites')
          .doc(productId);

      if (!currentStatus) {
        // tambahkan ke favorit
        await favRef.set({'liked': true});
      } else {
        // hapus dari favorit
        await favRef.delete();
      }
    }
  }

  /// Tambahkan produk ke keranjang
  void addToCart(Product product) {
    _cartItems.add(product);
    notifyListeners();
  }

  /// (Optional) Hapus dari keranjang
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  /// (Optional) Clear keranjang
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void addProduct() {
    notifyListeners();
  }
}