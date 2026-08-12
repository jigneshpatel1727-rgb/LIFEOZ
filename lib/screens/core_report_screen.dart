import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/yansi_brain.dart';

class CoreReportScreen extends StatefulWidget {
  final int core;
  final String currency;

  const CoreReportScreen({
    super.key,
    required this.core,
    required this.currency,
  });

  @override
  State<CoreReportScreen> createState() =>
      _CoreReportScreenState();
}

class _CoreReportScreenState
    extends State<CoreReportScreen> {
  bool loading = true;

  List<Map<String, dynamic>> records = [];

  double income = 0;
  double expenses = 0;
  double balance = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs =
        await SharedPreferences.getInstance();

    final brain = YansiBrain(
      prefs: prefs,
    );

    final memory =
        await brain.getMemory();

    final summary =
        await brain.getSummary();

    List<Map<String, dynamic>> filtered;

    switch (widget.core) {
      case 0:
        filtered = memory.where((item) {
          return item['type'] == 'expense' ||
              item['type'] == 'income';
        }).toList();
        break;

      case 1:
        filtered = memory.where((item) {
          return item['type'] == 'goal';
        }).toList();
        break;

      case 2:
        filtered = memory.where((item) {
          return item['type'] == 'task' ||
              item['type'] == 'reminder';
        }).toList();
        break;

      case 3:
        filtered = memory.where((item) {
          return item['type'] == 'household';
        }).toList();
        break;

      case 4:
        filtered = memory.where((item) {
          return item['type'] == 'diary';
        }).toList();
        break;

      default:
        filtered = [];
    }

    if (!mounted) return;

    setState(() {
      records = filtered;

      income =
          (summary['income'] as num?)
                  ?.toDouble() ??
              0;

      expenses =
          (summary['expenses'] as num?)
                  ?.toDouble() ??
              0;

      balance =
          (summary['balance'] as num?)
                  ?.toDouble() ??
              0;

      loading = false;
    });
  }

  String money(double value) {
    if (value == value.roundToDouble()) {
      return '${widget.currency}${value.toInt()}';
    }

    return '${widget.currency}${value.toStringAsFixed(2)}';
  }

  String title() {
    const titles = [
      'FINANCIAL LIFE',
      'GOALS & GROWTH',
      'PRODUCTIVITY',
      'HOUSEHOLD',
      'LIFE',
    ];

    return titles[widget.core];
  }

  IconData icon() {
    const icons = [
      Icons.account_balance_wallet_outlined,
      Icons.auto_awesome_outlined,
      Icons.bolt_outlined,
      Icons.home_work_outlined,
      Icons.timeline_rounded,
    ];

    return icons[widget.core];
  }

  String mainValue() {
    switch (widget.core) {
      case 0:
        return money(expenses);

      default:
        return '${records.length}';
    }
  }

  String mainLabel() {
    switch (widget.core) {
      case 0:
        return 'TOTAL SPENDING';

      case 1:
        return 'GOALS';

      case 2:
        return 'TASKS';

      case 3:
        return 'HOUSEHOLD ITEMS';

      case 4:
        return 'DIARY RECORDS';

      default:
        return 'RECORDS';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF02070B),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,

        title: Row(
          children: [
            Icon(
              icon(),
              color:
                  const Color(0xFF00E5FF),
            ),

            const SizedBox(width: 10),

            Text(
              title(),
              style:
                  const TextStyle(
                fontSize: 13,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xFF00E5FF),
              ),
            )
          : RefreshIndicator(
              color:
                  const Color(0xFF00E5FF),

              onRefresh:
                  loadData,

              child: ListView(
                padding:
                    const EdgeInsets.all(18),

                children: [
                  // ==================================================
                  // MAIN INTELLIGENCE CARD
                  // ==================================================

                  Container(
                    padding:
                        const EdgeInsets.all(24),

                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        28,
                      ),

                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(0xFF071820),
                          Color(0xFF030B10),
                        ],
                      ),

                      border:
                          Border.all(
                        color:
                            const Color(
                          0xFF00E5FF,
                        ).withOpacity(.20),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(
                            0xFF00E5FF,
                          ).withOpacity(.08),
                          blurRadius: 35,
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'YANSI INTELLIGENCE',
                          style:
                              TextStyle(
                            color:
                                Color(0xFF76FFFF),
                            fontSize: 9,
                            letterSpacing: 2.5,
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        Text(
                          mainValue(),
                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          mainLabel(),
                          style:
                              const TextStyle(
                            color:
                                Colors.white38,
                            fontSize: 9,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // FINANCIAL INTELLIGENCE
                  // ==================================================

                  if (widget.core == 0)
                    Container(
                      padding:
                          const EdgeInsets.all(20),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFF061118,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          24,
                        ),

                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFF00E5FF,
                          ).withOpacity(.12),
                        ),
                      ),

                      child: Column(
                        children: [
                          metric(
                            'INCOME',
                            money(income),
                          ),

                          metric(
                            'SPENDING',
                            money(expenses),
                          ),

                          metric(
                            'BALANCE',
                            money(balance),
                          ),
                        ],
                      ),
                    ),

                  if (widget.core == 0)
                    const SizedBox(
                      height: 16,
                    ),

                  // ==================================================
                  // YANSI GRAPH
                  // ==================================================

                  Container(
                    height: 150,

                    padding:
                        const EdgeInsets.all(18),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF061118,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        24,
                      ),

                      border:
                          Border.all(
                        color:
                            const Color(
                          0xFF00E5FF,
                        ).withOpacity(.12),
                      ),
                    ),

                    child: CustomPaint(
                      painter:
                          _LifeGraphPainter(),
                      child:
                          const SizedBox.expand(),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // RECORDS
                  // ==================================================

                  Container(
                    padding:
                        const EdgeInsets.all(18),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF061118,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        24,
                      ),

                      border:
                          Border.all(
                        color:
                            const Color(
                          0xFF00E5FF,
                        ).withOpacity(.12),
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'RECENT LIFEOS DATA',
                          style:
                              TextStyle(
                            color:
                                Color(0xFF76FFFF),
                            fontSize: 9,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        if (records.isEmpty)
                          const Padding(
                            padding:
                                EdgeInsets.all(
                              20,
                            ),
                            child: Center(
                              child: Text(
                                'No records yet.\nSpeak naturally to Yansi.',
                                textAlign:
                                    TextAlign.center,
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),

                        ...records
                            .reversed
                            .take(10)
                            .map(
                              recordTile,
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget metric(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [
          Text(
            label,
            style:
                const TextStyle(
              color:
                  Colors.white38,
              fontSize: 9,
              letterSpacing: 1.5,
            ),
          ),

          Text(
            value,
            style:
                const TextStyle(
              color:
                  Color(0xFF76FFFF),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget recordTile(
    Map<String, dynamic> record,
  ) {
    final type =
        record['type']
            ?.toString() ??
        'record';

    String text =
        record['text']
            ?.toString() ??
        record['task']
            ?.toString() ??
        record['goal']
            ?.toString() ??
        record['item']
            ?.toString() ??
        '';

    final amount =
        (record['amount'] as num?)
            ?.toDouble();

    IconData recordIcon =
        Icons.auto_awesome;

    if (type == 'expense') {
      recordIcon =
          Icons.account_balance_wallet_outlined;
    } else if (type == 'income') {
      recordIcon =
          Icons.trending_up_rounded;
    } else if (type == 'task') {
      recordIcon =
          Icons.bolt_outlined;
    } else if (type == 'reminder') {
      recordIcon =
          Icons.notifications_none;
    } else if (type == 'household') {
      recordIcon =
          Icons.home_work_outlined;
    } else if (type == 'diary') {
      recordIcon =
          Icons.menu_book_outlined;
    } else if (type == 'goal') {
      recordIcon =
          Icons.auto_awesome_outlined;
    }

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),

      padding:
          const EdgeInsets.all(12),

      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(.025),

        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,

            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,

              color:
                  const Color(
                0xFF00E5FF,
              ).withOpacity(.07),
            ),

            child: Icon(
              recordIcon,
              color:
                  const Color(
                0xFF00E5FF,
              ),
              size: 18,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              text.isEmpty
                  ? type.toUpperCase()
                  : text,

              maxLines: 2,

              overflow:
                  TextOverflow.ellipsis,

              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize: 12,
              ),
            ),
          ),

          if (amount != null)
            Text(
              money(amount),
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
  }
}

// ============================================================
// FUTURISTIC GRAPH
// ============================================================

class _LifeGraphPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final grid =
        Paint()
          ..color =
              const Color(
            0xFF00E5FF,
          ).withOpacity(.06)
          ..strokeWidth = .5;

    for (int i = 1; i < 5; i++) {
      final y =
          size.height *
              i /
              5;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        grid,
      );
    }

    final line =
        Paint()
          ..color =
              const Color(
            0xFF00E5FF,
          ).withOpacity(.70)
          ..strokeWidth = 2
          ..style =
              PaintingStyle.stroke
          ..strokeCap =
              StrokeCap.round;

    final path =
        Path();

    path.moveTo(
      0,
      size.height * .75,
    );

    path.cubicTo(
      size.width * .15,
      size.height * .60,
      size.width * .24,
      size.height * .78,
      size.width * .38,
      size.height * .43,
    );

    path.cubicTo(
      size.width * .52,
      size.height * .18,
      size.width * .62,
      size.height * .62,
      size.width * .75,
      size.height * .31,
    );

    path.cubicTo(
      size.width * .85,
      size.height * .10,
      size.width * .94,
      size.height * .32,
      size.width,
      size.height * .18,
    );

    canvas.drawPath(
      path,
      line,
    );
  }

  @override
  bool shouldRepaint(
    covariant _LifeGraphPainter oldDelegate,
  ) {
    return false;
  }
}
