import 'package:flutter/material.dart';

class ProductOrder {
  final String idProd;
  final String title;
  final int qte;
  final double price;
  final String imageUrl;

  ProductOrder({
    required this.idProd,
    required this.title,
    required this.qte,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': idProd,
      'title': title,
      'quantity': qte,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory ProductOrder.fromMap(Map<String, dynamic> map) {
    return ProductOrder(
      idProd: map['id'] ?? '',
      title: map['title'] ?? '',
      qte: map['quantity'] ?? 0,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

class Cart with ChangeNotifier {
  Map<String, ProductOrder> _prodPan = {};

  Map<String, ProductOrder> get prodPan => {..._prodPan};

  /// Jumlah total produk secara keseluruhan (qty semua produk dijumlah)
  int get itemCount {
    return _prodPan.values.fold(0, (sum, item) => sum + item.qte);
  }

  /// Jumlah jenis produk yang berbeda (1 produk A + 1 produk B = 2 jenis)
  int get prodPanCount => _prodPan.length;

  /// Total harga semua item di keranjang
  double get totalAmount {
    double total = 0;
    _prodPan.forEach((_, item) {
      total += item.price * item.qte;
    });
    return total;
  }

  /// Menambahkan produk ke keranjang atau menambah qty jika sudah ada
  void ajouterProdPan(String idProduct, double price, String title,
      [String imageUrl = 'https://via.placeholder.com/100']) {
    if (_prodPan.containsKey(idProduct)) {
      _prodPan.update(
        idProduct,
            (existing) => ProductOrder(
          idProd: existing.idProd,
          title: existing.title,
          qte: existing.qte + 1,
          price: existing.price,
          imageUrl: existing.imageUrl,
        ),
      );
    } else {
      _prodPan.putIfAbsent(
        idProduct,
            () => ProductOrder(
          idProd: idProduct,
          title: title,
          qte: 1,
          price: price,
          imageUrl: imageUrl,
        ),
      );
    }
    notifyListeners();
  }

  /// Menghapus seluruh produk dari keranjang
  void suppProdPan(String idProduct) {
    _prodPan.remove(idProduct);
    notifyListeners();
  }

  /// Mengurangi qty satu produk; hapus jika qty jadi 0
  void supp1Prod(String idProduct) {
    if (!_prodPan.containsKey(idProduct)) return;

    if (_prodPan[idProduct]!.qte > 1) {
      _prodPan.update(
        idProduct,
            (existing) => ProductOrder(
          idProd: existing.idProd,
          title: existing.title,
          qte: existing.qte - 1,
          price: existing.price,
          imageUrl: existing.imageUrl,
        ),
      );
    } else {
      _prodPan.remove(idProduct);
    }
    notifyListeners();
  }

  /// Mengatur jumlah qty produk langsung (misalnya dari input box)
  void adjusterQte(String idProduct, int newQty) {
    if (!_prodPan.containsKey(idProduct)) return;

    _prodPan.update(
      idProduct,
          (existing) => ProductOrder(
        idProd: existing.idProd,
        title: existing.title,
        qte: newQty,
        price: existing.price,
        imageUrl: existing.imageUrl,
      ),
    );
    notifyListeners();
  }

  /// Membersihkan keranjang
  void clear() {
    _prodPan = {};
    notifyListeners();
  }
}