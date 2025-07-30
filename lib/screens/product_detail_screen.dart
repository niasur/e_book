import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../providers/product.dart';
import '../providers/shop.dart';
import '../providers/cart.dart';
import 'package:lottie/lottie.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';

  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late String productId;
  Product? loadedProduct;
  bool isLoading = true;

  void showSuccessAnimation(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });

        return Center(
          child: Lottie.asset(
            'assets/animasi/add.json',
            width: 140,
            height: 140,
            repeat: false,
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    productId = ModalRoute.of(context)!.settings.arguments as String;

    final shopProvider = Provider.of<Shop>(context, listen: false);

    try {
      loadedProduct = shopProvider.findById(productId);
      setState(() => isLoading = false);
    } catch (_) {
      _fetchProductFromFirestore();
    }
  }

  Future<void> _fetchProductFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          loadedProduct = Product(
            id: doc.id,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            price: (data['price'] as num).toDouble(),
            imageUrl: data['imageUrl'] ?? '',
            category: List<String>.from(data['category'] ?? []),
            author: data['author'] ?? 'Unknown',
            isFavorite: false,
          );
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Firestore error: $e');
      setState(() => isLoading = false);
    }
  }

  Widget _buildBookCard(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        height: 160,
        width: 120,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (loadedProduct == null) {
      return const Scaffold(
        body: Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top image & overlay
            Stack(
              children: [
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: Image.network(
                    loadedProduct!.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  height: 400,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Positioned(
                  top: 300,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loadedProduct!.title,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        loadedProduct!.author,
                        style: GoogleFonts.montserrat(
                          color: Colors.grey[300],
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Info Boxes
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Rating",
                            style: GoogleFonts.montserrat(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            "4.4",
                            style: GoogleFonts.montserrat(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? Colors.blue
                                  : const Color(0xFF009688),
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                        child: VerticalDivider(
                          color: Colors.grey,
                          thickness: 1.5,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "Pages",
                            style: GoogleFonts.montserrat(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            "106",
                            style: GoogleFonts.montserrat(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? Colors.blue
                                  : const Color(0xFF009688),
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                        child: VerticalDivider(
                          color: Colors.grey,
                          thickness: 1.5,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "Languages",
                            style: GoogleFonts.montserrat(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            "ID",
                            style: GoogleFonts.montserrat(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? Colors.blue
                                  : const Color(0xFF009688),
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ReadMoreText(
                    loadedProduct!.description,
                    trimLines: 4,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: colorScheme.onBackground,
                    ),
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more',
                    trimExpandedText: ' Show less',
                    moreStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.blue
                          : const Color(0xFF009688), // hijau di dark mode
                    ),
                    lessStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.blue
                          : const Color(0xFF009688),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Best Seller section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    "Best Seller",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.filter_list, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildBookCard("https://upload.wikimedia.org/wikipedia/id/2/26/Sampul_buku_Ranah_3_Warna.jpg"),
                  const SizedBox(width: 12),
                  _buildBookCard("https://www.gramedia.com/blog/content/images/2022/01/9786024243999_Saman-2018.jpg"),
                  const SizedBox(width: 12),
                  _buildBookCard("https://upload.wikimedia.org/wikipedia/id/thumb/8/83/Rantau_1_muara_%28sampul%29.jpg/220px-Rantau_1_muara_%28sampul%29.jpg"),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final bgColor = Theme.of(context).colorScheme.surface;
          final primaryColor = isDark ? const Color(0xFF009688) : Colors.blue;
          final borderColor = primaryColor.withOpacity(0.5);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                // Favorite Button
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryColor, width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.transparent,
                  ),
                  child: IconButton(
                    icon: Icon(
                      loadedProduct!.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: primaryColor,
                    ),
                    onPressed: () async {
                      await loadedProduct!.toggleFavoriteStatus();
                      setState(() {});
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Add to Cart Button
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      cart.ajouterProdPan(
                        loadedProduct!.id,
                        loadedProduct!.price,
                        loadedProduct!.title,
                      );
                      showSuccessAnimation(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(
                      CupertinoIcons.cart,
                      size: 22.0,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      "Add to cart",
                      style: GoogleFonts.montserrat(
                        color: primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(loadedProduct!.price),
                          style: GoogleFonts.montserrat(
                            color: primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}