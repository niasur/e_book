import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class ConnectivityUtils {
  static final ConnectivityUtils _singleton = ConnectivityUtils._internal();

  static ConnectivityUtils getInstance() => _singleton;

  ConnectivityUtils._internal();

  // StreamController untuk menginformasikan status koneksi
  final StreamController<bool> connectionChangeController =
  StreamController<bool>.broadcast();

  final Connectivity _connectivity = Connectivity();

  void initialize() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _connectionChange(results);
    });

    isConnected();
  }

  Stream<bool> get connectionChange => connectionChangeController.stream;

  void dispose() {
    connectionChangeController.close();
  }

  // Tangani perubahan koneksi
  void _connectionChange(List<ConnectivityResult> results) {
    final hasConnection = results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);
    connectionChangeController.add(hasConnection);
  }

  Future<bool> isConnected() async {
    try {
      final List<ConnectivityResult> results =
      await _connectivity.checkConnectivity();
      return _updateConnectionStatus(results);
    } on PlatformException {
      return false;
    }
  }

  Future<bool> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final hasConnection = results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);
    connectionChangeController.add(hasConnection);
    return hasConnection;
  }
}