import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
