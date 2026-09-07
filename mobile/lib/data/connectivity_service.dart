import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Tracks network connectivity and exposes a ValueNotifier.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final ValueNotifier<bool> isOnline = ValueNotifier(true);

  void init() {
    Connectivity().onConnectivityChanged.listen((results) {
      // connectivity_plus returns a List<ConnectivityResult> on newer versions.
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online != isOnline.value) isOnline.value = online;
    });
  }
}
