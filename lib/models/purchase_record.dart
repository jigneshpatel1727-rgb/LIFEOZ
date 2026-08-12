import 'dart:convert';

/// ============================================================
/// PURCHASE RECORD
/// ============================================================
///
/// Represents one complete purchase/receipt.
///
/// Yansi can eventually create this from:
/// Camera scan
/// Voice
/// Text
/// Notification
/// Email
/// Manual entry
///
/// Historical records are permanent.
/// There is intentionally no delete method.
/// ============================================================

class PurchaseItem {
  final String id;

  final String name;

  final String category;

  final double quantity;

  final String unit;

  final double unitPrice;

  final double totalPrice;

  const PurchaseItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  factory PurchaseItem.fromMap(
    Map<String, dynamic> map,
  ) {
    return PurchaseItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      category:
          map['category'] as String? ?? 'Other',
      quantity:
          (map['quantity'] as num?)?.toDouble() ?? 1,
      unit:
          map['unit'] as String? ?? 'piece',
      unitPrice:
          (map['unitPrice'] as num?)?.toDouble() ?? 0,
      totalPrice:
          (map['totalPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory PurchaseItem.fromJson(
    String value,
  ) {
    return PurchaseItem.fromMap(
      jsonDecode(value)
          as Map<String, dynamic>,
    );
  }
}

/// ============================================================
/// COMPLETE PURCHASE
/// ============================================================

class PurchaseRecord {
  final String id;

  final DateTime createdAt;

  final DateTime? purchaseDate;

  final String merchant;

  final String category;

  final String currency;

  final List<PurchaseItem> items;

  final double subtotal;

  final double tax;

  final double discount;

  final double total;

  final String source;

  final String originalText;

  final String aiSummary;

  final String? imagePath;

  const PurchaseRecord({
    required this.id,
    required this.createdAt,
    required this.merchant,
    required this.category,
    required this.currency,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.source,
    required this.originalText,
    required this.aiSummary,
    this.purchaseDate,
    this.imagePath,
  });

  /// ==========================================================
  /// MAP
  /// ==========================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt':
          createdAt.toIso8601String(),
      'purchaseDate':
          purchaseDate?.toIso8601String(),
      'merchant': merchant,
      'category': category,
      'currency': currency,
      'items': items
          .map(
            (item) => item.toMap(),
          )
          .toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'source': source,
      'originalText': originalText,
      'aiSummary': aiSummary,
      'imagePath': imagePath,
    };
  }

  /// ==========================================================
  /// FROM MAP
  /// ==========================================================

  factory PurchaseRecord.fromMap(
    Map<String, dynamic> map,
  ) {
    final rawItems =
        map['items'] as List<dynamic>? ?? [];

    final parsedItems =
        rawItems.map((item) {
      return PurchaseItem.fromMap(
        Map<String, dynamic>.from(
          item as Map,
        ),
      );
    }).toList();

    return PurchaseRecord(
      id: map['id'] as String? ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] as String,
      ),
      purchaseDate:
          map['purchaseDate'] == null
              ? null
              : DateTime.parse(
                  map['purchaseDate']
                      as String,
                ),
      merchant:
          map['merchant'] as String? ?? '',
      category:
          map['category'] as String? ?? 'Other',
      currency:
          map['currency'] as String? ?? '₹',
      items: List.unmodifiable(
        parsedItems,
      ),
      subtotal:
          (map['subtotal'] as num?)
                  ?.toDouble() ??
              0,
      tax:
          (map['tax'] as num?)
                  ?.toDouble() ??
              0,
      discount:
          (map['discount'] as num?)
                  ?.toDouble() ??
              0,
      total:
          (map['total'] as num?)
                  ?.toDouble() ??
              0,
      source:
          map['source'] as String? ??
              'unknown',
      originalText:
          map['originalText'] as String? ??
              '',
      aiSummary:
          map['aiSummary'] as String? ??
              '',
      imagePath:
          map['imagePath'] as String?,
    );
  }

  /// ==========================================================
  /// JSON
  /// ==========================================================

  String toJson() {
    return jsonEncode(
      toMap(),
    );
  }

  factory PurchaseRecord.fromJson(
    String value,
  ) {
    return PurchaseRecord.fromMap(
      jsonDecode(value)
          as Map<String, dynamic>,
    );
  }

  /// ==========================================================
  /// ITEM COUNT
  /// ==========================================================

  int get itemCount {
    return items.length;
  }

  /// ==========================================================
  /// CATEGORY TOTAL
  /// ==========================================================

  double categoryTotal(
    String requestedCategory,
  ) {
    return items
        .where(
          (item) =>
              item.category
                  .toLowerCase() ==
              requestedCategory
                  .toLowerCase(),
        )
        .fold(
          0.0,
          (
            total,
            item,
          ) =>
              total +
              item.totalPrice,
        );
  }
}
