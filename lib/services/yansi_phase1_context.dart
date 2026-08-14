/// Unified read-only snapshot passed into Yansi reasoning.
/// Keeps Phase 1 cores decoupled while giving Yansi one coherent view.
class YansiPhase1Context {
  final double monthlySpend;
  final double monthlyBudget;
  final int upcomingBills;
  final int openTasks;
  final List<String> householdNeeds;
  final List<String> permittedSignals;
  final String? activeFocus;
  final DateTime capturedAt;

  const YansiPhase1Context({
    required this.monthlySpend,
    required this.monthlyBudget,
    required this.upcomingBills,
    required this.openTasks,
    required this.householdNeeds,
    required this.permittedSignals,
    this.activeFocus,
    required this.capturedAt,
  });

  YansiPhase1Context copyWith({
    double? monthlySpend,
    double? monthlyBudget,
    int? upcomingBills,
    int? openTasks,
    List<String>? householdNeeds,
    List<String>? permittedSignals,
    String? activeFocus,
    DateTime? capturedAt,
  }) => YansiPhase1Context(
        monthlySpend: monthlySpend ?? this.monthlySpend,
        monthlyBudget: monthlyBudget ?? this.monthlyBudget,
        upcomingBills: upcomingBills ?? this.upcomingBills,
        openTasks: openTasks ?? this.openTasks,
        householdNeeds: householdNeeds ?? this.householdNeeds,
        permittedSignals: permittedSignals ?? this.permittedSignals,
        activeFocus: activeFocus ?? this.activeFocus,
        capturedAt: capturedAt ?? this.capturedAt,
      );

  Map<String, dynamic> toMap() => {
        'monthlySpend': monthlySpend,
        'monthlyBudget': monthlyBudget,
        'upcomingBills': upcomingBills,
        'openTasks': openTasks,
        'householdNeeds': List<String>.from(householdNeeds),
        'permittedSignals': List<String>.from(permittedSignals),
        'activeFocus': activeFocus,
        'capturedAt': capturedAt.toIso8601String(),
      };
}
