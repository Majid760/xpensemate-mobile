import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

sealed class NetworkInfoService {
  bool get isConnect;
  Stream<bool> get connectivityStream;
}

class NetworkInfoServiceImpl implements NetworkInfoService {

  NetworkInfoServiceImpl(this._connectivity) {
    // Start listening to connectivity changes when created
    _initConnectivityListener();
  }

  final Connectivity _connectivity;
  final _connectionStatusController = StreamController<bool>.broadcast();
  bool _hasConnection = false;

  void _initConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((connectivityResults) async {
      _hasConnection = await _checkRealConnection(connectivityResults);
      _connectionStatusController.add(_hasConnection);
    });
  }

  Future<bool> _checkRealConnection(List<ConnectivityResult> results) async {
    try {
      if (results.isEmpty || (results.length == 1 && results.contains(ConnectivityResult.none))) {
        return false;
      }
      //CHECK DATA INSTEAD OF RADIO STATUS
      final result = await InternetAddress.lookup('www.google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (error) {
      debugPrint('something went wrong! in connection:$error');
      return false;
    }
  }

  @override
  bool get isConnect => _hasConnection;

  @override
  Stream<bool> get connectivityStream => _connectionStatusController.stream;
}