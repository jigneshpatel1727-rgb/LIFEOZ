import 'package:flutter/material.dart';

import '../screens/receipt_scanner_screen.dart';

class YansiActions {
  static Future<void> openBillScanner(
    BuildContext context,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ReceiptScannerScreen(),
      ),
    );
  }

  static bool isScanRequest(
    String text,
  ) {
    final value = text.toLowerCase();

    return value.contains('scan bill') ||
        value.contains('scan the bill') ||
        value.contains('scan this bill') ||
        value.contains('scan receipt') ||
        value.contains('scan this receipt') ||
        value.contains('grocery bill') ||
        value.contains('shopping bill') ||
        value.contains('clothing bill') ||
        value.contains('mall bill');
  }
}
