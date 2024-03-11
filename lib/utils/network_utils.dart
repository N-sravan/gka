import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  StreamSubscription<ConnectivityResult>? _subscription;
  ConnectivityResult? _connectivityResult;

  startTrackingConnection() {
    _subscription ??= Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      _connectivityResult = result;
    });
  }

  Future<bool> hasActiveInternet() async {
    if (_connectivityResult != null &&
        (_connectivityResult == ConnectivityResult.wifi ||
            _connectivityResult == ConnectivityResult.mobile)) {
      /// Connected to a mobile network or wifi network
      return true;
    } else {
      /// No active internet connection
      return false;
    }
  }
}

final networkUtils = NetworkUtils();
