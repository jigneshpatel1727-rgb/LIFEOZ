import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/budget_engine.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({
    super.key,
  });

  @override
  State<BudgetScreen> createState() =>
      _BudgetScreenState();
}

class _BudgetScreenState
    extends State<BudgetScreen> {
  bool loading = true;

  double income = 0;
  double spending = 0;
  double remaining = 0;
  double savingTarget = 0;

  Map<String, double> categories = {};

  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();
    loadBudget();
  }

  Future<void> loadBudget() async {
    final prefs =
        await SharedPreferences.getInstance();

    final engine =
        BudgetEngine(
      prefs: prefs,
    );

    final budget =
        await engine.calculateBudget();

    final categoryData =
        await engine.currentMonthCategories();

    final advice =
        await engine.savingSuggestions();

    if (!mounted) return;

    setState(() {
      income =
          (budget['income'] as num?)
                  ?.toDouble() ??
              0;

      spending =
          (budget['spending'] as num?)
                  ?.toDouble() ??
              0;

      remaining =
          (budget['remaining'] as num?)
                  ?.toDouble() ??
              0;

      savingTarget =
          (budget['savingTarget'] as num?)
                  ?.toDouble() ??
              0;

      categories =
          categoryData;

      suggestions =
          advice;

      loading = false;
    });
  }

  String money(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  double get spendingPercent {
    if (income <= 0) return 0;

    final value =
        spending / income;

    return value.clamp(
      0.0,
      1.0,
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
          'YANSI BUDGET',
          style:
              TextStyle(
            fontSize: 13,
            letterSpacing: 2.5,
          ),
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
                  loadBudget,

              child: ListView(
                padding:
                    const EdgeInsets.all(18),

                children: [
                  _overview(),

                  const SizedBox(
                    height: 16,
                  ),

                  _progress(),

                  const SizedBox(
                    height: 16,
                  ),

                  _categories(),

                  const SizedBox(
                    height: 16,
                  ),

                  _suggestions(),
                ],
              ),
            ),
    );
  }

  // ==========================================================
  // OVERVIEW
  // ==========================================================

  Widget _overview() {
    return Container(
      padding:
          const EdgeInsets.all(22),

      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(28),

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
              const Color(0xFF00E5FF)
                  .withOpacity(.18),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'YANSI MONTHLY INTELLIGENCE',
            style:
                TextStyle(
              color:
                  Color(0xFF76FFFF),
              fontSize: 9,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          Text(
            money(remaining),
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          const Text(
            'ESTIMATED MONEY REMAINING',
            style:
                TextStyle(
              color:
                  Colors.white38,
              fontSize: 9,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _smallMetric(
                  'INCOME',
                  money(income),
                ),
              ),

              Expanded(
                child:
                    _smallMetric(
                  'SPENDING',
                  money(spending),
                ),
              ),

              Expanded(
                child:
                    _smallMetric(
                  'SAVE TARGET',
                  money(savingTarget),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallMetric(
    String title,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style:
              const TextStyle(
            color:
                Colors.white38,
            fontSize: 8,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        Text(
          value,
          style:
              const TextStyle(
            color:
                Color(0xFF76FFFF),
            fontSize: 14,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SPENDING PROGRESS
  // ==========================================================

  Widget _progress() {
    return Container(
      padding:
          const EdgeInsets.all(20),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFF061118),

        borderRadius:
            BorderRadius.circular(24),

        border:
            Border.all(
          color:
              const Color(0xFF00E5FF)
                  .withOpacity(.10),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'SPENDING LEVEL',
            style:
                TextStyle(
              color:
                  Color(0xFF76FFFF),
              fontSize: 9,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),

            child:
                LinearProgressIndicator(
              minHeight: 10,

              value:
                  spendingPercent,

              backgroundColor:
                  Colors.white
                      .withOpacity(.06),

              valueColor:
                  const AlwaysStoppedAnimation(
                Color(0xFF00E5FF),
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            '${(spendingPercent * 100).toStringAsFixed(0)}% of available monthly income used',
            style:
                const TextStyle(
              color:
                  Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CATEGORY ANALYSIS
  // ==========================================================

  Widget _categories() {
    final entries =
        categories.entries.toList()
          ..sort(
            (a, b) =>
                b.value.compareTo(
              a.value,
            ),
          );

    return Container(
      padding:
          const EdgeInsets.all(20),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFF061118),

        borderRadius:
            BorderRadius.circular(24),

        border:
            Border.all(
          color:
              const Color(0xFF00E5FF)
                  .withOpacity(.10),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'CATEGORY ANALYSIS',
            style:
                TextStyle(
              color:
                  Color(0xFF76FFFF),
              fontSize: 9,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          if (entries.isEmpty)
            const Text(
              'Yansi is learning your spending pattern.',
              style:
                  TextStyle(
                color:
                    Colors.white38,
                fontSize: 11,
              ),
            ),

          ...entries.take(8).map(
            (entry) {
              final percentage =
                  income <= 0
                      ? 0.0
                      : (entry.value /
                              income)
                          .clamp(
                          0.0,
                          1.0,
                        );

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 15,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [
                        Text(
                          entry.key,
                          style:
                              const TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 11,
                          ),
                        ),

                        Text(
                          money(
                            entry.value,
                          ),
                          style:
                              const TextStyle(
                            color:
                                Color(0xFF76FFFF),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    ClipRRect(
                      borderRadius:
                          BorderRadius
                              .circular(
                        8,
                      ),

                      child:
                          LinearProgressIndicator(
                        minHeight: 6,

                        value:
                            percentage,

                        backgroundColor:
                            Colors.white
                                .withOpacity(
                          .05,
                        ),

                        valueColor:
                            const AlwaysStoppedAnimation(
                          Color(0xFF168CFF),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // YANSI SAVING ADVICE
  // ==========================================================

  Widget _suggestions() {
    return Container(
      padding:
          const EdgeInsets.all(20),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFF061118),

        borderRadius:
            BorderRadius.circular(24),

        border:
            Border.all(
          color:
              const Color(0xFF00E5FF)
                  .withOpacity(.12),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            'YANSI SUGGESTIONS',
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

          ...suggestions.map(
            (suggestion) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 12,
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 15,
                      color:
                          Color(0xFF00E5FF),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Text(
                        suggestion,
                        style:
                            const TextStyle(
                          color:
                              Colors.white70,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
