import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_book/screens/profile_edit_screen.dart';
import '../providers/order.dart';
import '../providers/cart.dart';
import '../shared/strings.dart';
import '../providers/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    final updatedUser = FirebaseAuth.instance.currentUser;

    setState(() {
      fullName = updatedUser?.displayName ?? '';
      email = updatedUser?.email ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<Orders>(context);
    final cart = Provider.of<Cart>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    double height = MediaQuery.of(context).size.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradasi
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(4, 9, 35, 1),
                Color.fromRGBO(39, 105, 171, 1),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              child: Column(
                children: [
                  // Tema & Logout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (v) => themeProvider.toggleTheme(v),
                      ),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Theme.of(context).dialogBackgroundColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (ctx) {
                              final isDark = Theme.of(context).brightness == Brightness.dark;
                              final batalColor = isDark ? const Color(0xFF009688) : Colors.blue;
                              final keluarColor = Theme.of(context).colorScheme.error;

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Keluar dari akun?',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: batalColor,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () => Navigator.of(ctx).pop(),
                                            child: const Text(
                                              'Batal',
                                              style: TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: keluarColor,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () async {
                                              Navigator.of(ctx).pop();
                                              await FirebaseAuth.instance.signOut();
                                              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                                            },
                                            child: const Text(
                                              'Keluar',
                                              style: TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: const Icon(Icons.logout, size: 30, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Judul
                  Text(
                    'My\nProfile',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.courgette(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Kartu profil
                  SizedBox(
                    height: height * 0.43,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double innerHeight = constraints.maxHeight;
                        double innerWidth = constraints.maxWidth;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // Card putih
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: innerHeight * 0.72,
                                width: innerWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 80),

                                    // Full Name
                                    Text(
                                      fullName.isNotEmpty ? fullName : 'Nama belum diset',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: Color.fromRGBO(39, 105, 171, 1),
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // Email (tebal)
                                    Text(
                                      email,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 25,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Orders dan Pending
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              Strings.ORDERS,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontFamily: 'Nunito',
                                                fontSize: 22,
                                              ),
                                            ),
                                            Text(
                                              orders.ordersCount.toString(),
                                              style: const TextStyle(
                                                color: Color.fromRGBO(39, 105, 171, 1),
                                                fontFamily: 'Nunito',
                                                fontSize: 22,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 25),
                                          child: Container(
                                            height: 50,
                                            width: 3,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(100),
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              Strings.PENDING,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontFamily: 'Nunito',
                                                fontSize: 22,
                                              ),
                                            ),
                                            Text(
                                              cart.prodPan.length.toString(),
                                              style: const TextStyle(
                                                color: Color.fromRGBO(39, 105, 171, 1),
                                                fontFamily: 'Nunito',
                                                fontSize: 22,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Icon setting
                            Positioned(
                              top: 111,
                              right: 20,
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.of(context).pushNamed('/edit-profile');
                                  _loadUserData(); // refresh setelah balik
                                },
                                child: Icon(
                                  Icons.settings,
                                  color: Colors.grey[700],
                                  size: 30,
                                ),
                              ),
                            ),

                            // Foto profil
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Image.asset(
                                  'assets/images/profil.png',
                                  width: innerWidth * 0.45,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}