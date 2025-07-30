import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

enum AuthMode { signup, login }

class AuthCard extends StatefulWidget {
  final AuthMode authMode;

  const AuthCard({Key? key, this.authMode = AuthMode.login}) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _authData = {'email': '', 'password': '', 'name': ''};
  final _passwordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _opacityAnimation;

  late AuthMode _authMode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authMode = widget.authMode;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    if (_authMode == AuthMode.signup) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final auth = Provider.of<Auth>(context, listen: false);
    bool success = false;

    if (_authMode == AuthMode.signup) {
      success = await auth.registerWithEmail(
        _authData['email']!,
        _authData['password']!,
        _authData['name']!,
      );

      if (!success) {
        _showErrorDialog("Registrasi gagal. Email mungkin sudah terdaftar.");
      } else {
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.of(context).pushReplacementNamed('/login', arguments: 'registered');
      }
    } else {
      success = await auth.loginWithEmail(_authData['email']!, _authData['password']!);

      if (!success) {
        _showErrorDialog("Login gagal. Periksa email dan password Anda.");
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }

    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => kIsWeb || defaultTargetPlatform == TargetPlatform.android
          ? AlertDialog(
        title: const Text("Terjadi Kesalahan"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      )
          : CupertinoAlertDialog(
        title: const Text("Terjadi Kesalahan"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final cardHeight = _authMode == AuthMode.signup ? 420.0 : 320.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: cardHeight,
      width: deviceSize.width * 0.75,
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                if (_authMode == AuthMode.signup)
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                    textInputAction: TextInputAction.next,
                    focusNode: _nameFocusNode,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocusNode),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Nama tidak boleh kosong'
                        : null,
                    onSaved: (value) => _authData['name'] = value ?? '',
                  ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  focusNode: _emailFocusNode,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_passwordFocusNode),
                  validator: (value) =>
                  (value == null || !value.contains('@')) ? 'Email tidak valid!' : null,
                  onSaved: (value) => _authData['email'] = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  textInputAction:
                  _authMode == AuthMode.signup ? TextInputAction.next : TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (_authMode == AuthMode.signup) {
                      FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                    } else {
                      _submit();
                    }
                  },
                  validator: (value) => (value == null || value.length < 6)
                      ? 'Password minimal 6 karakter!'
                      : null,
                  onSaved: (value) => _authData['password'] = value!,
                ),
                if (_authMode == AuthMode.signup)
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.signup,
                        decoration: const InputDecoration(labelText: 'Konfirmasi Password'),
                        obscureText: true,
                        focusNode: _confirmPasswordFocusNode,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Password tidak cocok!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                const Spacer(),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB6463D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(_authMode == AuthMode.login ? 'LOGIN' : 'DAFTAR'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                      '/auth',
                      arguments:
                      _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login,
                    );
                  },
                  child: Text(
                    _authMode == AuthMode.login ? 'DAFTAR' : 'LOGIN',
                    style: const TextStyle(
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
    );
  }
}