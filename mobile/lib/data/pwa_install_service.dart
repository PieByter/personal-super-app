import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';

/// Detects the browser's PWA install prompt (beforeinstallprompt) and lets
/// the app show an "Install App" button. Only active on web.
///
/// The actual install-prompt handling lives in web/index.html (a small
/// script that captures `beforeinstallprompt` and exposes
/// `window.__pwaCanInstall` / `window.__pwaInstall()`). This service just
/// reads those globals, keeping the Dart side simple and cross-platform.
class PwaInstallService {
  static final PwaInstallService _instance = PwaInstallService._internal();
  factory PwaInstallService() => _instance;
  PwaInstallService._internal();

  final ValueNotifier<bool> canInstall = ValueNotifier(false);

  void init() {
    if (!kIsWeb) return;
    // Poll the global flag set by index.html.
    _poll();
  }

  void _poll() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!kIsWeb) return;
      final can = _readCanInstall();
      if (can != canInstall.value) canInstall.value = can;
      if (!can) _poll();
    });
  }

  bool _readCanInstall() {
    try {
      final value = web.window.getProperty('__pwaCanInstall'.toJS);
      return value == true.toJS;
    } catch (_) {
      return false;
    }
  }

  /// Triggers the browser install prompt. Returns true if the user accepted.
  Future<bool> promptInstall() async {
    if (!kIsWeb) return false;
    try {
      final result = web.window.callMethod('__pwaInstall'.toJS);
      canInstall.value = false;
      return result == true.toJS;
    } catch (_) {
      return false;
    }
  }
}
