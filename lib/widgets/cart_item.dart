import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';
import '../shared/strings.dart';

class CartItem extends StatefulWidget {
  final String id;
  final String idProduct;
  final String title;
  final double price;
  final String imageUrl;

  const CartItem({
    super.key,
    required this.id,
    required this.idProduct,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  int get quantity {
    final cartItem =
    Provider.of<Cart>(context, listen: false).prodPan[widget.idProduct];
    return cartItem?.qte ?? 1;
  }

  void _increaseQty() {
    final newQty = quantity + 1;
    Provider.of<Cart>(context, listen: false)
        .adjusterQte(widget.idProduct, newQty);
    setState(() {});
  }

  void _decreaseQty() {
    if (quantity > 1) {
      final newQty = quantity - 1;
      Provider.of<Cart>(context, listen: false)
          .adjusterQte(widget.idProduct, newQty);
      setState(() {});
    }
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color enabledColor = isDarkMode ? Colors.grey[300]! : Colors.black;
    final Color disabledColor = Colors.grey;

    return Dismissible(
      key: ValueKey(widget.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      confirmDismiss: (_) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text(Strings.DELETE_TITLE),
            content: const Text(Strings.DELETE_MESSAGE),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(Strings.NO),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(Strings.YES),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        Provider.of<Cart>(context, listen: false).suppProdPan(widget.idProduct);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    ProductDetailScreen.routeName,
                    arguments: widget.idProduct,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.network(widget.imageUrl),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Info Produk
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          ProductDetailScreen.routeName,
                          arguments: widget.idProduct,
                        );
                      },
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatCurrency(widget.price)} x $quantity',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      'Total: ${formatCurrency(widget.price * quantity)}',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Tombol - Qty +
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 22,
                    color: quantity > 1 ? enabledColor : disabledColor,
                    onPressed: quantity > 1 ? _decreaseQty : null,
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 22,
                    color: enabledColor,
                    onPressed: _increaseQty,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}