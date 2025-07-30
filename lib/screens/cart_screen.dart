import 'package:e_book/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';

import '../providers/order.dart';
import '../providers/cart.dart';
import '../widgets/cart_item.dart';
import '../models/cart_item.dart' as model;

Future<String> fetchImageUrl(String productId) async {
  final doc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
  return doc.data()?['imageUrl'] ?? 'https://via.placeholder.com/100';
}

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.CART_SCREEN),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    Strings.TOTAL,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    backgroundColor: Colors.deepOrange,
                    label: Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(cart.totalAmount),
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OrderButton(cart: cart),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: cart.prodPan.isEmpty
                ? Center(
              child: Text(
                'Keranjang masih kosong.',
                style: textTheme.titleMedium,
              ),
            )
                : ListView.builder(
              itemCount: cart.prodPanCount,
              itemBuilder: (context, i) {
                final item = cart.prodPan.values.toList()[i];
                final idKey = cart.prodPan.keys.toList()[i];

                return FutureBuilder<String>(
                  future: fetchImageUrl(item.idProd),
                  builder: (ctx, snapshot) {
                    return CartItem(
                      id: item.idProd,
                      title: item.title,
                      price: item.price,
                      idProduct: idKey,
                      imageUrl: snapshot.data ?? 'https://via.placeholder.com/100',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({Key? key, required this.cart}) : super(key: key);
  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton.icon(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
        setState(() => _isLoading = true);

        final cartItems = await Future.wait(widget.cart.prodPan.entries.map((entry) async {
          final p = entry.value;
          final imageUrl = await fetchImageUrl(p.idProd);
          return model.CartItem(
            id: entry.key,
            idProduct: p.idProd,
            title: p.title,
            qte: p.qte,
            price: p.price,
            imageUrl: imageUrl,
          );
        }));

        final total = widget.cart.totalAmount;
        final date = DateTime.now();

        await Provider.of<Orders>(context, listen: false).addOrder(cartItems, total);
        widget.cart.clear();

        setState(() => _isLoading = false);

        if (!mounted) return;

        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: "Success",
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
            return Scaffold(
              backgroundColor: Colors.black.withOpacity(0.4), // semi transparan
              body: Center(
                child: Lottie.asset(
                  'assets/animasi/sukses.json',
                  width: 400,
                  height: 400,
                  repeat: false,
                ),
              ),
            );
          },
        );

        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;
        Navigator.of(context).pop(); // Tutup animasi

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReceiptScreen(
              items: cartItems,
              totalAmount: total,
              orderDate: date,
            ),
          ),
        );
      },
      icon: _isLoading
          ? const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : const Icon(Icons.check_circle_outline),
      label: Text(
        _isLoading ? 'Memproses...' : Strings.ORDERNOW,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  var _isLoading = false;
}

class ReceiptScreen extends StatelessWidget {
  final List<model.CartItem> items;
  final double totalAmount;
  final DateTime orderDate;

  const ReceiptScreen({
    super.key,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Struk Pemesanan',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tanggal'),
                          Text(DateFormat('dd MMM yyyy | HH:mm').format(orderDate)),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const DottedLine(dashColor: Colors.grey),
                      const SizedBox(height: 12),

                      ...items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(item.title)),
                            Text('x${item.qte}'),
                            const SizedBox(width: 8),
                            Text(
                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                                  .format(item.price),
                            ),
                          ],
                        ),
                      )),

                      const SizedBox(height: 12),
                      const DottedLine(dashColor: Colors.grey),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('OK', style: TextStyle(fontSize: 16)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}