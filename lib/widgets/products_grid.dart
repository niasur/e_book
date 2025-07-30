import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop.dart';
import 'product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyFavorites;

  const ProductsGrid(this.showOnlyFavorites, {super.key});

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Shop>(context);
    final products = showOnlyFavorites
        ? productsData.favoriteItems
        : productsData.items;

    if (products.isEmpty) {
      return const Center(
        child: Text('Tidak ada produk tersedia.'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: products.length,
      itemBuilder: (context, i) => ChangeNotifierProvider.value(
        value: products[i],
        child: ProductItem(),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
    );
  }
}