import 'package:flutter/services.dart';

/// Permission-controlled bridge for keeping Yansi's ambient runtime alive.
/// The Android foreground service is started/stopped explicitly by the app;
/// it never turns on microphone capture by itself.
class YansiBackgroundBridge {
  static const MethodChannel _channel = MethodChannel('lifeos/yansi_background');

  static Future<bool> start() async {
    try {
      return await _channel.invokeMethod<bool>('start') ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> stop() async {
    try {
      return await _channel.invokeMethod<bool>('stop') ?? false;
    } on PlatformException {
      return false;
    }
  }
}
