import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({
    super.key,
  });

  @override
  State<ReceiptScannerScreen> createState() =>
      _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState
    extends State<ReceiptScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  File? _image;

  bool _processing = false;

  String _status = 'READY';

  Future<void> _scanReceipt() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image == null) return;

      setState(() {
        _image = File(image.path);
        _processing = true;
        _status = 'ANALYSING BILL';
      });

      /*
       * STEP 6 FOUNDATION
       *
       * The photograph is now captured.
       *
       * The next intelligence layer will:
       *
       * IMAGE
       *   ↓
       * OCR
       *   ↓
       * STORE NAME
       *   ↓
       * ITEMS
       *   ↓
       * PRICES
       *   ↓
       * CATEGORY
       *   ↓
       * YANSI MEMORY
       *
       * We deliberately don't pretend OCR has happened yet.
       */

      await Future.delayed(
        const Duration(
          milliseconds: 700,
        ),
      );

      if (!mounted) return;

      setState(() {
        _processing = false;
        _status = 'BILL CAPTURED';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _processing = false;
        _status = 'CAMERA ERROR';
      });
    }
  }

  Future<void> _chooseFromGallery() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) return;

      setState(() {
        _image = File(image.path);
        _processing = true;
        _status = 'ANALYSING BILL';
      });

      await Future.delayed(
        const Duration(
          milliseconds: 700,
        ),
      );

      if (!mounted) return;

      setState(() {
        _processing = false;
        _status = 'BILL CAPTURED';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _processing = false;
        _status = 'IMAGE ERROR';
      });
    }
  }

  Future<void> _saveScanRecord() async {
    if (_image == null) return;

    final prefs =
        await SharedPreferences.getInstance();

    final scans =
        prefs.getStringList(
              'yansi_receipt_scans',
            ) ??
            <String>[];

    scans.add(
      DateTime.now()
          .toIso8601String(),
    );

    await prefs.setStringList(
      'yansi_receipt_scans',
      scans,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Bill saved to Yansi memory.',
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
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
        child: Padding(
          padding:
              const EdgeInsets.all(20),

          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,

                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(30),

                    border:
                        Border.all(
                      color:
                          const Color(
                        0xFF00E5FF,
                      ).withOpacity(.25),
                    ),

                    color:
                        const Color(
                      0xFF061118,
                    ),
                  ),

                  child:
                      _image == null
                          ? _emptyScanner()
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(
                                30,
                              ),
                              child:
                                  Image.file(
                                _image!,
                                fit:
                                    BoxFit.cover,
                              ),
                            ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

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

              const SizedBox(
                height: 16,
              ),

              if (_processing)
                const Padding(
                  padding:
                      EdgeInsets.only(
                    bottom: 16,
                  ),
                  child:
                      LinearProgressIndicator(
                    color:
                        Color(0xFF00E5FF),
                    backgroundColor:
                        Color(0xFF10252B),
                  ),
                ),

              Row(
                children: [
                  Expanded(
                    child:
                        _actionButton(
                      icon:
                          Icons.camera_alt_outlined,
                      text:
                          'SCAN',
                      onTap:
                          _scanReceipt,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                        _actionButton(
                      icon:
                          Icons.photo_library_outlined,
                      text:
                          'GALLERY',
                      onTap:
                          _chooseFromGallery,
                    ),
                  ),
                ],
              ),

              if (_image != null) ...[
                const SizedBox(
                  height: 12,
                ),

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child:
                      ElevatedButton(
                    onPressed:
                        _processing
                            ? null
                            : _saveScanRecord,

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

                    child:
                        const Text(
                      'SAVE TO YANSI',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        letterSpacing:
                            1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyScanner() {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [
        Container(
          width: 90,
          height: 90,

          decoration:
              BoxDecoration(
            shape:
                BoxShape.circle,

            color:
                const Color(
              0xFF00E5FF,
            ).withOpacity(.06),

            border:
                Border.all(
              color:
                  const Color(
                0xFF00E5FF,
              ).withOpacity(.25),
            ),
          ),

          child: const Icon(
            Icons.document_scanner_outlined,
            color:
                Color(0xFF00E5FF),
            size: 38,
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        const Text(
          'SHOW YANSI THE BILL',
          style:
              TextStyle(
            color:
                Colors.white,
            fontSize: 15,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        const Text(
          'Grocery • Clothing • Mall • Household',
          textAlign:
              TextAlign.center,
          style:
              TextStyle(
            color:
                Colors.white38,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,

      child:
          OutlinedButton.icon(
        onPressed:
            _processing
                ? null
                : onTap,

        icon: Icon(
          icon,
          size: 18,
        ),

        label:
            Text(
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
              const Color(
            0xFF00E5FF,
          ),

          side:
              BorderSide(
            color:
                const Color(
              0xFF00E5FF,
            ).withOpacity(.35),
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),
    );
  }
}
