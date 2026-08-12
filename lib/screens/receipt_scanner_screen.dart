import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/budget_engine.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() =>
      _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState
    extends State<ReceiptScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  final TextRecognizer _recognizer =
      TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  File? _image;

  bool _processing = false;
  bool _saved = false;

  String _status = 'READY';
  String _recognizedText = '';

  List<Map<String, dynamic>> _items = [];

  double _total = 0;

  @override
  void dispose() {
    _recognizer.close();
    super.dispose();
  }

  // ==========================================================
  // CAMERA
  // ==========================================================

  Future<void> _scanReceipt() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 95,
    );

    if (image == null) return;

    await _analyseImage(File(image.path));
  }

  // ==========================================================
  // GALLERY
  // ==========================================================

  Future<void> _chooseFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );

    if (image == null) return;

    await _analyseImage(File(image.path));
  }

  // ==========================================================
  // OCR
  // ==========================================================

  Future<void> _analyseImage(File image) async {
    setState(() {
      _image = image;
      _processing = true;
      _saved = false;
      _status = 'YANSI IS READING';
      _recognizedText = '';
      _items = [];
      _total = 0;
    });

    try {
      final inputImage =
          InputImage.fromFile(image);

      final result =
          await _recognizer.processImage(
        inputImage,
      );

      final text = result.text.trim();

      final items = _extractItems(text);

      final total =
          _extractTotal(text, items);

      if (!mounted) return;

      setState(() {
        _recognizedText = text;
        _items = items;
        _total = total;
        _processing = false;
        _status = items.isEmpty
            ? 'TEXT CAPTURED'
            : 'BILL UNDERSTOOD';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _processing = false;
        _status = 'SCAN FAILED';
      });
    }
  }

  // ==========================================================
  // ITEM EXTRACTION
  // ==========================================================

  List<Map<String, dynamic>> _extractItems(
    String text,
  ) {
    final result =
        <Map<String, dynamic>>[];

    final lines = text.split('\n');

    for (final rawLine in lines) {
      final line = rawLine.trim();

      if (line.isEmpty) continue;

      final price = _extractPrice(line);

      if (price == null) continue;

      final cleaned = _cleanItemName(line);

      if (cleaned.isEmpty) continue;

      if (_looksLikeTotal(cleaned)) {
        continue;
      }

      result.add({
        'name': cleaned,
        'price': price,
        'category': _categoryFor(cleaned),
      });
    }

    return result;
  }

  // ==========================================================
  // PRICE
  // ==========================================================

  double? _extractPrice(String line) {
    final cleaned = line
        .replaceAll(',', '')
        .replaceAll('₹', '');

    final matches = RegExp(
      r'(\d+(?:\.\d{1,2})?)',
    ).allMatches(cleaned);

    if (matches.isEmpty) {
      return null;
    }

    final values = matches
        .map(
          (m) => double.tryParse(
            m.group(1)!,
          ),
        )
        .whereType<double>()
        .toList();

    if (values.isEmpty) {
      return null;
    }

    return values.last;
  }

  // ==========================================================
  // ITEM NAME
  // ==========================================================

  String _cleanItemName(String line) {
    return line
        .replaceAll(
          RegExp(
            r'₹?\s*\d+(?:,\d{3})*(?:\.\d{1,2})?',
          ),
          '',
        )
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        )
        .trim();
  }

  // ==========================================================
  // TOTAL
  // ==========================================================

  double _extractTotal(
    String text,
    List<Map<String, dynamic>> items,
  ) {
    for (final line in text.split('\n')) {
      final lower =
          line.toLowerCase();

      if (lower.contains('grand total') ||
          lower.contains('net total') ||
          lower.contains('total amount') ||
          lower == 'total' ||
          lower.startsWith('total ')) {
        final value =
            _extractPrice(line);

        if (value != null) {
          return value;
        }
      }
    }

    double sum = 0;

    for (final item in items) {
      sum +=
          (item['price'] as num?)
                  ?.toDouble() ??
              0;
    }

    return sum;
  }

  bool _looksLikeTotal(String text) {
    final lower =
        text.toLowerCase();

    return lower.contains('total') ||
        lower.contains('subtotal') ||
        lower.contains('tax') ||
        lower.contains('gst') ||
        lower.contains('discount') ||
        lower.contains('cash') ||
        lower.contains('change');
  }

  // ==========================================================
  // CATEGORY
  // ==========================================================

  String _categoryFor(String item) {
    final lower =
        item.toLowerCase();

    if (_containsAny(lower, [
      'milk',
      'bread',
      'rice',
      'flour',
      'sugar',
      'oil',
      'dal',
      'atta',
      'vegetable',
      'fruit',
      'grocery',
      'biscuit',
    ])) {
      return 'Grocery';
    }

    if (_containsAny(lower, [
      'shirt',
      'tshirt',
      't-shirt',
      'pant',
      'jeans',
      'dress',
      'kurta',
      'shoe',
      'sandal',
      'clothing',
    ])) {
      return 'Clothing';
    }

    if (_containsAny(lower, [
      'soap',
      'shampoo',
      'toothpaste',
      'detergent',
      'cleaner',
      'tissue',
    ])) {
      return 'Household';
    }

    if (_containsAny(lower, [
      'phone',
      'charger',
      'headphone',
      'earphone',
      'laptop',
      'electronics',
    ])) {
      return 'Electronics';
    }

    return 'Other';
  }

  bool _containsAny(
    String text,
    List<String> words,
  ) {
    return words.any(
      (word) => text.contains(word),
    );
  }

  // ==========================================================
  // SAVE TO YANSI + BUDGET ENGINE
  // ==========================================================

  Future<void> _saveToYansi() async {
    if (_items.isEmpty && _total <= 0) {
      return;
    }

    final prefs =
        await SharedPreferences.getInstance();

    final budgetEngine =
        BudgetEngine(
      prefs: prefs,
    );

    // Financial expense.
    await budgetEngine.saveReceiptAsExpense(
      total: _total,
      items: _items,
      source: 'bill_scanner',
    );

    // Keep a dedicated receipt history too.
    final receipt = {
      'id': DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      'type': 'receipt',
      'date': DateTime.now()
          .toIso8601String(),
      'total': _total,
      'items': _items,
      'rawText': _recognizedText,
      'source': 'camera',
    };

    final receipts =
        prefs.getStringList(
              'yansi_receipts',
            ) ??
            <String>[];

    receipts.add(
      jsonEncode(receipt),
    );

    await prefs.setStringList(
      'yansi_receipts',
      receipts,
    );

    if (!mounted) return;

    setState(() {
      _saved = true;
      _status = 'SAVED • YANSI LEARNED';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Bill added to Yansi financial memory.',
        ),
      ),
    );
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF02070B),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        title: const Text(
          'YANSI SCAN',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 2.5,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _imageBox(),

                    const SizedBox(height: 14),

                    Text(
                      _status,
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF76FFFF),
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),

                    if (_items.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _summaryCard(),
                      const SizedBox(height: 14),
                      _itemsCard(),
                    ],
                  ],
                ),
              ),
            ),

            _bottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _imageBox() {
    return Container(
      height: 270,
      width: double.infinity,
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(28),
        color:
            const Color(0xFF061118),
        border:
            Border.all(
          color:
              const Color(0xFF00E5FF)
                  .withOpacity(.20),
        ),
      ),
      child: _image == null
          ? const Center(
              child: Icon(
                Icons.document_scanner_outlined,
                size: 55,
                color:
                    Color(0xFF00E5FF),
              ),
            )
          : ClipRRect(
              borderRadius:
                  BorderRadius.circular(28),
              child: Image.file(
                _image!,
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(22),
        color:
            const Color(0xFF061118),
        border:
            Border.all(
          color:
              const Color(0xFF00E5FF)
                  .withOpacity(.12),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'YANSI ANALYSIS',
                style:
                    TextStyle(
                  color:
                      Color(0xFF76FFFF),
                  fontSize: 9,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_items.length} ITEMS',
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            '₹${_total.toStringAsFixed(2)}',
            style:
                const TextStyle(
              color:
                  Color(0xFF76FFFF),
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemsCard() {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(22),
        color:
            const Color(0xFF061118),
        border:
            Border.all(
          color:
              const Color(0xFF00E5FF)
                  .withOpacity(.10),
        ),
      ),
      child: Column(
        children:
            _items.map(
          (item) {
            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color:
                        Color(0xFF00E5FF),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${item['name']} • ${item['category']}',
                      style:
                          const TextStyle(
                        color:
                            Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Text(
                    '₹${(item['price'] as num).toStringAsFixed(2)}',
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF76FFFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _bottomButtons() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        18,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _button(
                  Icons.camera_alt_outlined,
                  'SCAN',
                  _processing
                      ? null
                      : _scanReceipt,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _button(
                  Icons.photo_library_outlined,
                  'GALLERY',
                  _processing
                      ? null
                      : _chooseFromGallery,
                ),
              ),
            ],
          ),

          if (_items.isNotEmpty) ...[
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed:
                    _processing || _saved
                        ? null
                        : _saveToYansi,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF00E5FF,
                  ),
                  foregroundColor:
                      const Color(
                    0xFF02070B,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),

                child: Text(
                  _saved
                      ? 'SAVED TO YANSI'
                      : 'SAVE TO YANSI MEMORY',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _button(
    IconData icon,
    String text,
    VoidCallback? action,
  ) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: action,
        icon: Icon(
          icon,
          size: 18,
        ),
        label: Text(
          text,
          style:
              const TextStyle(
            fontSize: 10,
            letterSpacing: 1.2,
          ),
        ),
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              const Color(0xFF00E5FF),
          side:
              BorderSide(
            color:
                const Color(0xFF00E5FF)
                    .withOpacity(.35),
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
