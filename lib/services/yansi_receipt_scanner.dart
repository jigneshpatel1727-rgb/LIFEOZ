import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class YansiReceiptItem {
  final String name;
  final double? price;
  final double? quantity;
  final String category;

  const YansiReceiptItem({required this.name, this.price, this.quantity, this.category = 'other'});

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'quantity': quantity,
        'category': category,
      };
}

class YansiReceiptResult {
  final List<YansiReceiptItem> items;
  final double? total;
  final String? merchant;
  final DateTime? date;
  final String rawText;

  const YansiReceiptResult({
    required this.items,
    this.total,
    this.merchant,
    this.date,
    this.rawText = '',
  });

  Map<String, dynamic> toMap() => {
        'merchant': merchant,
        'date': date?.toIso8601String(),
        'total': total,
        'items': items.map((e) => e.toMap()).toList(),
        'rawText': rawText,
        'source': 'receipt_scan',
      };
}

/// Phase-1 local-first receipt intelligence.
/// OCR runs on-device. Yansi can refine categorization and interpretation later.
class YansiReceiptScanner {
  final ImagePicker _picker;
  final TextRecognizer _recognizer;

  YansiReceiptScanner({ImagePicker? picker, TextRecognizer? recognizer})
      : _picker = picker ?? ImagePicker(),
        _recognizer = recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  Future<YansiReceiptResult?> scanCamera() => _scan(ImageSource.camera);
  Future<YansiReceiptResult?> scanGallery() => _scan(ImageSource.gallery);

  Future<YansiReceiptResult?> _scan(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 92);
    if (image == null) return null;
    final recognized = await _recognizer.processImage(InputImage.fromFilePath(image.path));
    return parseText(recognized.text);
  }

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
      final matches = money.allMatches(line).toList();
      if (matches.isEmpty) continue;
      final match = matches.last;
      final valueText = match.group(1);
      if (valueText == null) continue;
      final value = double.tryParse(valueText.replaceAll(',', ''));
      if (value == null) continue;

      if (lower.contains('grand total') || lower.contains('amount payable') || lower.contains('total')) {
        total = value;
        continue;
      }
      if (lower.contains('tax') || lower.contains('gst') || lower.contains('discount') || lower.contains('subtotal')) continue;

      final name = line.substring(0, match.start).trim().replaceAll(RegExp(r'[-:]+$'), '').trim();
      if (name.isEmpty || name.toLowerCase() == merchant?.toLowerCase()) continue;
      items.add(YansiReceiptItem(name: name, price: value, category: _categoryFor(name)));
    }

    total ??= _largest(items.map((e) => e.price).whereType<double>());
    return YansiReceiptResult(items: items, total: total, merchant: merchant, date: _dateFrom(lines), rawText: text);
  }

  String _categoryFor(String name) {
    final value = name.toLowerCase();
    if (RegExp(r'rice|flour|atta|oil|milk|bread|vegetable|fruit|grocery|dal|pulse|spice').hasMatch(value)) return 'food';
    if (RegExp(r'detergent|soap|cleaner|tissue|dish|household|toilet').hasMatch(value)) return 'household';
    if (RegExp(r'shampoo|cosmetic|cream|toothpaste|personal').hasMatch(value)) return 'personal_care';
    if (RegExp(r'fuel|petrol|diesel|parking|toll').hasMatch(value)) return 'transport';
    return 'other';
  }

  double? _largest(Iterable<double> values) {
    double? largest;
    for (final value in values) {
      if (largest == null || value > largest) largest = value;
    }
    return largest;
  }

  DateTime? _dateFrom(List<String> lines) {
    final pattern = RegExp(r'\b(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})\b');
    for (final line in lines) {
      final match = pattern.firstMatch(line);
      if (match == null) continue;
      final day = int.tryParse(match.group(1)!);
      final month = int.tryParse(match.group(2)!);
      var year = int.tryParse(match.group(3)!);
      if (day == null || month == null || year == null) continue;
      if (year < 100) year += 2000;
      try {
        return DateTime(year, month, day);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> dispose() => _recognizer.close();
}
