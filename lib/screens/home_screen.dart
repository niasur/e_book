import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'products_overview_screen.dart';
import 'categories_screen.dart';
import 'cart_screen.dart' as cart_page;
import 'orders_screen.dart';
import 'profile_screen.dart';

import '../providers/cart.dart';
import '../providers/theme.dart';
import '../shared/strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int activeTab = 0;
  late AnimationController _badgeController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    // Jalankan animasi badge setiap rebuild (produk ditambah)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_badgeController.isAnimating) {
        _badgeController.forward(from: 0.0);
      }
    });

    return Scaffold(
      body: getPage(),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        selectedFontSize: 16,
        currentIndex: activeTab,
        onTap: (index) => setState(() => activeTab = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 20),
            label: Strings.HOME,
            backgroundColor: Colors.blue,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.apps, size: 20),
            label: Strings.CATEGORIES,
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart, size: 20),
                Positioned(
                  top: -5,
                  right: -6,
                  child: Selector<Cart, int>(
                    selector: (_, cart) => cart.prodPan.length,
                    builder: (_, count, __) {
                      if (count == 0) return const SizedBox.shrink();
                      return AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (ctx, child) => Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 1,
                            horizontal: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 6, // lebih kecil
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            label: Strings.CART,
            backgroundColor: Colors.red,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.payment, size: 20),
            label: Strings.ORDERS,
            backgroundColor: Colors.purple,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, size: 20),
            label: Strings.PROFILE,
            backgroundColor: Color.fromRGBO(39, 105, 171, 1),
          ),
        ],
      ),
    );
  }

  Widget getPage() {
    return IndexedStack(
      index: activeTab,
      children: const [
        ProductsOverviewScreen(),
        CategoriesScreen(),
        cart_page.CartScreen(),
        OrdersScreen(),
        ProfileScreen(),
      ],
    );
  }
}