import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../models/author.dart';
import '../providers/shop.dart';
import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';
import '../shared/strings.dart';
import './product_input_screen.dart';
import '../providers/product.dart';
import '../screens/book_category_screen.dart';

enum FilterOptions { favorites, all }

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({super.key});

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {

  final List<Map<String, String>> banners = [
    {
      'title': 'Success',
      'subtitle': "Let's not be jackals",
      'image': 'assets/images/banner1.jpg',
    },
    {
      'title': 'Growth',
      'subtitle': "Keep moving forward",
      'image': 'assets/images/banner2.png',
    },
    {
      'title': 'Innovation',
      'subtitle': "Think different",
      'image': 'assets/images/banner3.png',
    },
  ];

  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  String _searchQuery = '';

  late final PageController _bannerController;
  int _currentPage = 0;
  Timer? _bannerTimer;

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
            'assets/animasi/no.json',
            width: 140,
            height: 140,
            repeat: false,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) => _autoScrollBanner());
  }

  void _autoScrollBanner() {
    if (_bannerController.hasClients) {
      _currentPage = (_currentPage + 1) % banners.length;
      _bannerController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() => _isLoading = true);
      Provider.of<Shop>(context, listen: false).fetchAndSetProducts().then((_) {
        setState(() => _isLoading = false);
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshProduits(BuildContext context) async {
    await Provider.of<Shop>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final shop = Provider.of<Shop>(context);
    final allProducts = _showOnlyFavorites ? shop.favoriteItems : shop.items;
    final products = _searchQuery.isEmpty
        ? allProducts
        : allProducts.where((p) =>
        p.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: _buildAppBar(),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: () => _refreshProduits(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // penting
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildBannerSlider(),
                const SizedBox(height: 16),
                _buildSectionTitle("Top Authors", categoryId: 'top-authors'),
                const SizedBox(height: 8),
                const TopAuthorsRow(),
                const SizedBox(height: 16),
                _buildSectionTitle("E-Books", categoryId: 'popular', seeAll: true),
                const SizedBox(height: 8),
                _TrendingBooksRow(products: products),
          ],
        ),
      ),
        ),
    );
  }
  AppBar _buildAppBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode ? Colors.white : Colors.black;

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(CupertinoIcons.list_dash, color: iconColor),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductInputScreen()),
          );
        },
      ),
      title: Text(
        Strings.APP_NAME,
        style: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        PopupMenuButton<FilterOptions>(
          onSelected: (FilterOptions selectedValue) {
            setState(() {
              _showOnlyFavorites = selectedValue == FilterOptions.favorites;
            });
          },
          icon: Icon(Icons.more_vert, color: iconColor),
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: FilterOptions.favorites,
              child: Text(Strings.ONLYFAVS),
            ),
            const PopupMenuItem(
              value: FilterOptions.all,
              child: Text(Strings.SHOWALL),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: theme.brightness == Brightness.light
              ? Colors.grey.shade300
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.search, color: colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                hintText: "Search...",
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlider() {
    final brightness = Theme.of(context).brightness;
    final textColor = Colors.white;

    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: banners.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  image: DecorationImage(
                    image: AssetImage(banner['image']!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(brightness == Brightness.dark ? 0.3 : 0.4),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner['title']!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        banner['subtitle']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 12,
            left: 23,
            right: 0,
            child: SmoothPageIndicator(
              controller: _bannerController,
              count: banners.length,
              effect: ExpandingDotsEffect(
                expansionFactor: 3.5,
                spacing: 4,
                radius: 8,
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.white,
                dotColor: Colors.grey.shade400,
              ),
              onDotClicked: (index) {
                _bannerController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {
    required String categoryId,
    bool seeAll = false,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textTheme.titleLarge?.color,
          ),
        ),
        if (seeAll) ...[
          const Spacer(),
          GestureDetector(
            onTap: () {
              print('Tapped See All');
              Navigator.of(context).pushNamed(
                CategoryBookScreen.routeName,
                arguments: {
                  'showAll': true,
                  'title': 'All Books',
                },
              );
            },
            child: Row(
              children: [
                Text(
                  "See All",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  CupertinoIcons.forward,
                  size: 18,
                  color: textTheme.bodyMedium?.color,
    ),
    ],
    ),
    ),
    ],
    ],
    );
  }
}

class TopAuthorsRow extends StatefulWidget {
  const TopAuthorsRow({super.key});

  @override
  State<TopAuthorsRow> createState() => _TopAuthorsRowState();
}

class _TopAuthorsRowState extends State<TopAuthorsRow> {
  List<Author> _authors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAuthorsFromApi();
  }

  Future<void> _fetchAuthorsFromApi() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/authors'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _authors = data.map((item) => Author.fromJson(item)).toList();
          _loading = false;
        });
      } else {
        throw Exception('Failed to load authors');
      }
    } catch (error) {
      print('Error fetching authors: $error');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 110,
      child: Center(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _authors.length,
          itemBuilder: (context, index) {
            final author = _authors[index];
            return Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(author.image),
                ),
                const SizedBox(height: 6),
                Text(
                  author.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            );
          },
          separatorBuilder: (_, __) => const SizedBox(width: 16),
        ),
      ),
    );
  }
}

class _TrendingBooksRow extends StatelessWidget {
  final List<Product> products;

  const _TrendingBooksRow({required this.products});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF009688) : Colors.blue;

    if (products.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Lottie.asset(
            'assets/animasi/no.json',
            width: 150,
            height: 150,
          ),
        ),
      );
    }

    return SizedBox(
      height: 350,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (ctx, i) {
          final book = products[i];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                ProductDetailScreen.routeName,
                arguments: book.id,
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Buku
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 2 / 3,
                      child: Image.network(
                        book.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Judul Buku
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),

                  // Harga Buku
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(book.price),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Row Bookmark & Add
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon Bookmark
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Disimpan ke bookmark')),
                          );
                          // TODO: Tambah logika simpan bookmark
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bookmark_border,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),

                      // Icon Add
                      GestureDetector(
                        onTap: () {
                          cart.ajouterProdPan(
                            book.id,
                            book.price,
                            book.title,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}