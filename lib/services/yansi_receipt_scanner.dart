class YansiReceiptItem {
  final String name;
  final double? price;
  final double? quantity;

  const YansiReceiptItem({required this.name, this.price, this.quantity});

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'quantity': quantity,
      };
}

class YansiReceiptResult {
  final List<YansiReceiptItem> items;
  final double? total;
  final String? merchant;
  final DateTime? date;

  const YansiReceiptResult({
    required this.items,
    this.total,
    this.merchant,
    this.date,
  });

  Map<String, dynamic> toMap() => {
        'merchant': merchant,
        'date': date?.toIso8601String(),
        'total': total,
        'items': items.map((e) => e.toMap()).toList(),
      };
}

/// Receipt parsing boundary. Camera/OCR providers can supply recognized text;
/// this class turns common receipt lines into structured LifeOS records.
class YansiReceiptScanner {
  const YansiReceiptScanner();

  YansiReceiptResult parseText(String text) {
    final items = <YansiReceiptItem>[];
    double? total;
    String? merchant;

    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (lines.isNotEmpty) merchant = lines.first;

    final money = RegExp(r'(?:₹|rs\.?|inr)?\s*([0-9]+(?:[.,][0-9]{1,2})?)', caseSensitive: false);
    for (final line in lines) {
      final lower = line.toLowerCase();
      final match = money.firstMatch(line);
      final value = match == null ? null : double.tryParse(match.group(1)!.replaceAll(',', ''));
      if (value == null) continue;

      if (lower.contains('total') || lower.contains('amount payable') || lower.contains('grand total')) {
        total = value;
      } else if (!lower.contains('tax') && !lower.contains('discount') && !lower.contains('subtotal')) {
        final name = line.substring(0, match.start).trim().replaceAll(RegExp(r'[-:]+$'), '').trim();
        if (name.isNotEmpty && name.toLowerCase() != merchant?.toLowerCase()) {
          items.add(YansiReceiptItem(name: name, price: value));
        }
      }
    }

    return YansiReceiptResult(items: items, total: total, merchant: merchant);
  }
}
