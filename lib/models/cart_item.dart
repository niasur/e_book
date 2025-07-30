import 'package:e_book/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';

class CartItem extends StatefulWidget {
  final String id;
  final String idProduct;
  final String title;
  final int qte;
  final double price;
  final String imageUrl;

  const CartItem({
    super.key,
    required this.id,
    required this.idProduct,
    required this.title,
    required this.qte,
    required this.price,
    required this.imageUrl,
  });

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.qte;
  }

  void _increaseQty() {
    setState(() => quantity++);
    Provider.of<Cart>(context, listen: false)
        .adjusterQte(widget.idProduct, quantity);
  }

  void _decreaseQty() {
    if (quantity > 1) {
      setState(() => quantity--);
      Provider.of<Cart>(context, listen: false)
          .adjusterQte(widget.idProduct, quantity);
    }
  }

  String get formattedPrice => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(widget.price);

  String get formattedTotal => NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(widget.price * quantity);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Dismissible(
      key: ValueKey(widget.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(Icons.delete, color: Colors.white, size: 40),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
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
        Provider.of<Cart>(context, listen: false)
            .suppProdPan(widget.idProduct);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: widget.idProduct,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.imageUrl.isNotEmpty
                        ? widget.imageUrl
                        : 'https://via.placeholder.com/60',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        width: 60,
                        height: 60,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Text & controls
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('$quantity x $formattedPrice'),
                      const SizedBox(height: 2),
                      Text('Total: $formattedTotal'),
                    ],
                  ),
                ),

                // Qty controls
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove,
                          color: quantity > 1
                              ? iconColor
                              : iconColor.withOpacity(0.4)),
                      onPressed: quantity > 1 ? _decreaseQty : null,
                    ),
                    Text('$quantity'),
                    IconButton(
                      icon: Icon(Icons.add, color: iconColor),
                      onPressed: _increaseQty,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}