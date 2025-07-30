import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/product_item.dart';
import '../providers/product.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class CategoryBookScreen extends StatelessWidget {
  static const routeName = '/category-books';

  const CategoryBookScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final showAll = routeArgs?['showAll'] == true;
    final categoryId = routeArgs?['id'] ?? '';
    final categoryTitle = routeArgs?['title'] ?? 'Semua Buku';

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: showAll
            ? FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots()
            : FirebaseFirestore.instance
            .collection('products')
            .where('category', arrayContains: categoryId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animasi/no.json',
                    height: 160,
                    width: 160,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final doc = docs[i];

              final data = doc.data() as Map<String, dynamic>;
              if (!data.containsKey('title') || !data.containsKey('price') || !data.containsKey('imageUrl')) {
                return const SizedBox.shrink(); // skip jika data kurang
              }

              final product = Product(
                id: doc.id,
                title: data['title'],
                price: (data['price'] as num).toDouble(),
                description: data['description'] ?? '',
                imageUrl: data['imageUrl'],
                category: List<String>.from(data['category'] ?? []),
                author: data['author'] ?? 'Unknown',
              );

              return ChangeNotifierProvider.value(
                value: product,
                child: const ProductItem(),
              );
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
          );
        },
      ),
    );
  }
}