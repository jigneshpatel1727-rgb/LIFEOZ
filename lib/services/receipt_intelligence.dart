import '../models/purchase_record.dart';

/// ============================================================
/// RECEIPT INTELLIGENCE
/// ============================================================
///
/// Converts raw receipt/OCR text into structured purchase data.
///
/// Future flow:
///
/// CAMERA
///   ↓
/// OCR
///   ↓
/// ReceiptIntelligence
///   ↓
/// PurchaseRecord
///   ↓
/// PurchaseMemory
///   ↓
/// Yansi analysis
///
/// This first version uses local parsing rules.
/// A stronger AI/OCR layer will later improve recognition.
/// ============================================================

class ReceiptIntelligence {
  /// ==========================================================
  /// PARSE RECEIPT
  /// ==========================================================

  PurchaseRecord parseReceipt({
    required String rawText,
    required String currency,
    String? imagePath,
  }) {
    final cleaned =
        _cleanText(rawText);

    final lines =
        cleaned.split('\n');

    final merchant =
        _extractMerchant(lines);

    final purchaseDate =
        _extractDate(cleaned);

    final items =
        _extractItems(lines);

    final subtotal =
        _extractAmountAfterLabels(
      cleaned,
      [
        'subtotal',
        'sub total',
      ],
    );

    final tax =
        _extractAmountAfterLabels(
      cleaned,
      [
        'tax',
        'gst',
        'vat',
      ],
    );

    final discount =
        _extractAmountAfterLabels(
      cleaned,
      [
        'discount',
        'saving',
        'savings',
      ],
    );

    final extractedTotal =
        _extractAmountAfterLabels(
      cleaned,
      [
        'grand total',
        'total amount',
        'amount payable',
        'amount paid',
        'net total',
        'total',
      ],
    );

    final calculatedItemsTotal =
        items.fold<double>(
      0.0,
      (
        total,
        item,
      ) =>
          total +
          item.totalPrice,
    );

    final finalTotal =
        extractedTotal ??
            (calculatedItemsTotal > 0
                ? calculatedItemsTotal
                : 0.0);

    final finalSubtotal =
        subtotal ??
            calculatedItemsTotal;

    return PurchaseRecord(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),

      createdAt:
          DateTime.now(),

      purchaseDate:
          purchaseDate,

      merchant:
          merchant,

      category:
          _detectReceiptCategory(
        cleaned,
      ),

      currency:
          currency,

      items:
          List.unmodifiable(
        items,
      ),

      subtotal:
          finalSubtotal,

      tax:
          tax ?? 0.0,

      discount:
          discount ?? 0.0,

      total:
          finalTotal,

      source:
          'camera_ocr',

      originalText:
          rawText,

      aiSummary:
          _createSummary(
        merchant,
        items,
        finalTotal,
      ),

      imagePath:
          imagePath,
    );
  }

  // ==========================================================
  // CLEAN TEXT
  // ==========================================================

  String _cleanText(
    String text,
  ) {
    return text
        .replaceAll(
          '\r',
          '',
        )
        .replaceAll(
          '\t',
          ' ',
        )
        .split('\n')
        .map(
          (line) => line.trim(),
        )
        .where(
          (line) => line.isNotEmpty,
        )
        .join('\n');
  }

  // ==========================================================
  // MERCHANT
  // ==========================================================

  String _extractMerchant(
    List<String> lines,
  ) {
    if (lines.isEmpty) {
      return 'Unknown Merchant';
    }

    final ignored = [
      'invoice',
      'receipt',
      'bill',
      'tax invoice',
      'date',
      'time',
      'gst',
      'total',
      'subtotal',
      'amount',
    ];

    for (final line in lines.take(8)) {
      final lower =
          line.toLowerCase();

      bool skip = false;

      for (final word
          in ignored) {
        if (lower == word ||
            lower.startsWith(
              '$word:',
            )) {
          skip = true;
          break;
        }
      }

      if (skip) {
        continue;
      }

      if (_looksLikeDate(line) ||
          _looksLikePhone(line) ||
          _looksLikeAmountOnly(line)) {
        continue;
      }

      if (line.length >= 2) {
        return line;
      }
    }

    return 'Unknown Merchant';
  }

  // ==========================================================
  // DATE
  // ==========================================================

  DateTime? _extractDate(
    String text,
  ) {
    final patterns = [
      RegExp(
        r'(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})',
      ),
      RegExp(
        r'(\d{4})[\/\-](\d{1,2})[\/\-](\d{1,2})',
      ),
    ];

    for (final pattern
        in patterns) {
      final match =
          pattern.firstMatch(text);

      if (match == null) {
        continue;
      }

      try {
        if (pattern
            .pattern
            .startsWith(
              r'(\d{4})',
            )) {
          return DateTime(
            int.parse(
              match.group(1)!,
            ),
            int.parse(
              match.group(2)!,
            ),
            int.parse(
              match.group(3)!,
            ),
          );
        }

        var year =
            int.parse(
          match.group(3)!,
        );

        if (year < 100) {
          year += 2000;
        }

        return DateTime(
          year,
          int.parse(
            match.group(2)!,
          ),
          int.parse(
            match.group(1)!,
          ),
        );
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  // ==========================================================
  // ITEMS
  // ==========================================================

  List<PurchaseItem> _extractItems(
    List<String> lines,
  ) {
    final items =
        <PurchaseItem>[];

    for (final line in lines) {
      final parsed =
          _parseItemLine(line);

      if (parsed == null) {
        continue;
      }

      items.add(parsed);
    }

    return items;
  }

  // ==========================================================
  // ITEM LINE
  // ==========================================================

  PurchaseItem? _parseItemLine(
    String line,
  ) {
    final clean =
        line.trim();

    if (clean.isEmpty) {
      return null;
    }

    final lower =
        clean.toLowerCase();

    if (_isHeaderOrFooter(lower)) {
      return null;
    }

    // --------------------------------------------------------
    // FORMAT:
    //
    // Rice 2 620
    //
    // Milk 1 64
    //
    // Shirt 2 2400
    // --------------------------------------------------------

    final pattern =
        RegExp(
      r'^(.+?)\s+(\d+(?:\.\d+)?)\s+([0-9,]+(?:\.[0-9]+)?)$',
    );

    final match =
        pattern.firstMatch(clean);

    if (match != null) {
      final name =
          match.group(1)!.trim();

      final quantity =
          double.tryParse(
                match.group(2)!,
              ) ??
              1;

      final total =
          _parseNumber(
        match.group(3)!,
      );

      if (!_validItemName(name) ||
          total <= 0) {
        return null;
      }

      final unitPrice =
          quantity > 0
              ? total / quantity
              : total;

      return PurchaseItem(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        name: name,
        category:
            _categorizeItem(name),
        quantity:
            quantity,
        unit:
            'piece',
        unitPrice:
            unitPrice,
        totalPrice:
            total,
      );
    }

    // --------------------------------------------------------
    // FORMAT:
    //
    // Rice 620
    // Milk 64
    // Shirt 2400
    // --------------------------------------------------------

    final simplePattern =
        RegExp(
      r'^(.+?)\s+([0-9,]+(?:\.[0-9]+)?)$',
    );

    final simpleMatch =
        simplePattern.firstMatch(
      clean,
    );

    if (simpleMatch != null) {
      final name =
          simpleMatch.group(1)!.trim();

      final total =
          _parseNumber(
        simpleMatch.group(2)!,
      );

      if (!_validItemName(name) ||
          total <= 0) {
        return null;
      }

      return PurchaseItem(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        name: name,
        category:
            _categorizeItem(name),
        quantity:
            1,
        unit:
            'piece',
        unitPrice:
            total,
        totalPrice:
            total,
      );
    }

    return null;
  }

  // ==========================================================
  // LABELLED AMOUNTS
  // ==========================================================

  double? _extractAmountAfterLabels(
    String text,
    List<String> labels,
  ) {
    final lines =
        text.split('\n');

    for (final line in lines) {
      final lower =
          line.toLowerCase();

      for (final label
          in labels) {
        if (!lower.contains(label)) {
          continue;
        }

        final amount =
            _extractLastNumber(line);

        if (amount != null) {
          return amount;
        }
      }
    }

    return null;
  }

  // ==========================================================
  // LAST NUMBER
  // ==========================================================

  double? _extractLastNumber(
    String text,
  ) {
    final matches =
        RegExp(
      r'([0-9][0-9,]*(?:\.[0-9]+)?)',
    ).allMatches(text);

    if (matches.isEmpty) {
      return null;
    }

    final value =
        matches.last.group(1);

    if (value == null) {
      return null;
    }

    return _parseNumber(value);
  }

  // ==========================================================
  // NUMBER
  // ==========================================================

  double _parseNumber(
    String value,
  ) {
    return double.tryParse(
          value.replaceAll(
            ',',
            '',
          ),
        ) ??
        0.0;
  }

  // ==========================================================
  // RECEIPT CATEGORY
  // ==========================================================

  String _detectReceiptCategory(
    String text,
  ) {
    final lower =
        text.toLowerCase();

    if (_containsAny(
      lower,
      [
        'grocery',
        'supermarket',
        'vegetable',
        'rice',
        'milk',
        'oil',
      ],
    )) {
      return 'Grocery';
    }

    if (_containsAny(
      lower,
      [
        'shirt',
        'clothing',
        'fashion',
        'jeans',
        'dress',
        'shoes',
      ],
    )) {
      return 'Clothing';
    }

    if (_containsAny(
      lower,
      [
        'restaurant',
        'cafe',
        'food',
        'dining',
      ],
    )) {
      return 'Food';
    }

    if (_containsAny(
      lower,
      [
        'pharmacy',
        'medical',
        'medicine',
      ],
    )) {
      return 'Medical';
    }

    return 'Shopping';
  }

  // ==========================================================
  // ITEM CATEGORY
  // ==========================================================

  String _categorizeItem(
    String name,
  ) {
    final lower =
        name.toLowerCase();

    if (_containsAny(
      lower,
      [
        'rice',
        'flour',
        'atta',
        'dal',
        'oil',
        'milk',
        'bread',
        'vegetable',
        'fruit',
        'sugar',
        'salt',
        'spice',
      ],
    )) {
      return 'Grocery';
    }

    if (_containsAny(
      lower,
      [
        'shirt',
        'tshirt',
        't-shirt',
        'jeans',
        'dress',
        'trouser',
        'pant',
        'jacket',
        'shoe',
        'sandal',
      ],
    )) {
      return 'Clothing';
    }

    if (_containsAny(
      lower,
      [
        'soap',
        'shampoo',
        'toothpaste',
        'detergent',
        'cleaner',
      ],
    )) {
      return 'Household';
    }

    if (_containsAny(
      lower,
      [
        'tablet',
        'medicine',
        'capsule',
        'syrup',
      ],
    )) {
      return 'Medical';
    }

    return 'Other';
  }

  // ==========================================================
  // SUMMARY
  // ==========================================================

  String _createSummary(
    String merchant,
    List<PurchaseItem> items,
    double total,
  ) {
    if (items.isEmpty) {
      return 'Purchase recorded at '
          '$merchant for '
          '${total.toStringAsFixed(2)}.';
    }

    return 'Purchase at $merchant with '
        '${items.length} item(s), '
        'total ${total.toStringAsFixed(2)}.';
  }

  // ==========================================================
  // VALID ITEM
  // ==========================================================

  bool _validItemName(
    String name,
  ) {
    final lower =
        name.toLowerCase();

    if (name.length < 2) {
      return false;
    }

    if (_isHeaderOrFooter(lower)) {
      return false;
    }

    if (_looksLikeDate(name)) {
      return false;
    }

    return true;
  }

  // ==========================================================
  // HEADER / FOOTER
  // ==========================================================

  bool _isHeaderOrFooter(
    String text,
  ) {
    const ignored = [
      'subtotal',
      'sub total',
      'total',
      'grand total',
      'amount',
      'amount payable',
      'amount paid',
      'tax',
      'gst',
      'vat',
      'discount',
      'cash',
      'change',
      'invoice',
      'receipt',
      'bill',
      'thank you',
      'thankyou',
    ];

    for (final value
        in ignored) {
      if (text == value ||
          text.startsWith(
            '$value:',
          )) {
        return true;
      }
    }

    return false;
  }

  // ==========================================================
  // DATE CHECK
  // ==========================================================

  bool _looksLikeDate(
    String text,
  ) {
    return RegExp(
      r'^\d{1,4}[\/\-]\d{1,2}[\/\-]\d{1,4}$',
    ).hasMatch(
      text.trim(),
    );
  }

  // ==========================================================
  // PHONE CHECK
  // ==========================================================

  bool _looksLikePhone(
    String text,
  ) {
    return RegExp(
      r'^\+?[0-9\s\-]{8,15}$',
    ).hasMatch(
      text.trim(),
    );
  }

  // ==========================================================
  // AMOUNT ONLY
  // ==========================================================

  bool _looksLikeAmountOnly(
    String text,
  ) {
    return RegExp(
      r'^[₹\$£€]?\s*[0-9,]+(?:\.[0-9]+)?$',
    ).hasMatch(
      text.trim(),
    );
  }

  // ==========================================================
  // STRING HELPER
  // ==========================================================

  bool _containsAny(
    String text,
    List<String> values,
  ) {
    for (final value in values) {
      if (text.contains(value)) {
        return true;
      }
    }

    return false;
  }
}
