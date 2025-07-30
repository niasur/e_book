import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../widgets/auth_card.dart'; // Import AuthMode dari sini
import '../providers/auth.dart';
import '../screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  bool _shownSuccess = false;
  bool _shouldAutofocus = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shownSuccess) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args == 'registered') {
      _shownSuccess = true;
      _shouldAutofocus = true;

      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pendaftaran berhasil, silakan login."),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          _emailFocusNode.requestFocus();
        });
      });
    }
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() async {
    final auth = Provider.of<Auth>(context, listen: false);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _formKey.currentState?.save();
    setState(() => _isLoading = true);

    final success = await auth.loginWithEmail(_email, _password);

    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login gagal. Periksa email dan password Anda."),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFB63A3A).withOpacity(0.9),
                  const Color(0xFFB63A3A).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 80),
                  SizedBox(
                    height: 150,
                    child: Lottie.asset(
                      'assets/animasi/logo.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      width: deviceSize.width * 0.75,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              focusNode: _emailFocusNode,
                              autofocus: _shouldAutofocus,
                              decoration: const InputDecoration(labelText: 'Email'),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) => value != null && value.contains('@')
                                  ? null
                                  : 'Email tidak valid',
                              onSaved: (value) => _email = value ?? '',
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_passwordFocusNode);
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              focusNode: _passwordFocusNode,
                              decoration: const InputDecoration(labelText: 'Password'),
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              validator: (value) => value != null && value.length >= 6
                                  ? null
                                  : 'Password minimal 6 karakter',
                              onSaved: (value) => _password = value ?? '',
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 30),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB6463D),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0,
                                  vertical: 12.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text("LOGIN"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  '/auth',
                                  arguments: AuthMode.signup,
                                );
                              },
                              child: const Text(
                                "DAFTAR",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB6463D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}