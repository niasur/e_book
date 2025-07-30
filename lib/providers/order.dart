import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final List<OrderItem> _orders = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Orders();

  List<OrderItem> get orders => [..._orders];

  int get ordersCount => _orders.length;

  Future<void> fetchAndSetOrders() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('Fetch orders: No user is signed in.');
      return;
    }

    try {
      debugPrint('Fetching orders for user: ${user.uid}');

      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('dateTime', descending: true)
          .get();

      debugPrint('Orders fetched: ${snapshot.docs.length} documents');

      final List<OrderItem> loadedOrders = snapshot.docs.map((doc) {
        final data = doc.data();

        // Log setiap dokumen yang diambil
        debugPrint('Order doc ID: ${doc.id}, data: $data');

        return OrderItem(
          id: doc.id,
          amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
          dateTime: (data['dateTime'] as Timestamp).toDate(),
          products: (data['products'] as List<dynamic>? ?? []).map((item) {
            debugPrint('  Product in order: $item');

            return CartItem(
              id: UniqueKey().toString(),
              idProduct: item['id'] ?? '',
              title: item['title'] ?? 'Unknown',
              qte: item['quantity'] ?? 0,
              price: (item['price'] as num?)?.toDouble() ?? 0.0,
              imageUrl: item['imageUrl'] ?? 'https://via.placeholder.com/100',
            );
          }).toList(),
        );
      }).toList();

      _orders
        ..clear()
        ..addAll(loadedOrders);

      notifyListeners();
    } catch (e, stack) {
      debugPrint('Fetch orders error: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  Future<bool> addOrder(List<CartItem> cartItems, double total) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final timestamp = DateTime.now();

    try {
      final docRef = await _firestore.collection('orders').add({
        'userId': user.uid,
        'amount': total,
        'dateTime': timestamp,
        'products': cartItems.map((item) {
          return {
            'id': item.idProduct,
            'title': item.title,
            'quantity': item.qte,
            'price': item.price,
            'imageUrl': item.imageUrl,
          };
        }).toList(),
      });

      final newOrder = OrderItem(
        id: docRef.id,
        amount: total,
        products: cartItems,
        dateTime: timestamp,
      );

      _orders.insert(0, newOrder);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Add order error: $e');
      return false;
    }
  }
}