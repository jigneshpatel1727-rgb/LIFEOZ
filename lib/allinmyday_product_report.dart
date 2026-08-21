import 'allinmyday_product_workspace.dart';

/// Compact report model for the ALLINMYDAY product workspace.
/// Presentation layers can render this as the project's single-screen report.
class AllinmydayProductReport {
  const AllinmydayProductReport({
    required this.motto,
    required this.principle,
    required this.productCount,
    required this.statusCounts,
    required this.originalDesignOnly,
    required this.requiresPrototypeValidation,
    required this.requiresSafetyReviewBeforeRelease,
  });

  final String motto;
  final String principle;
  final int productCount;
  final Map<String, int> statusCounts;
  final bool originalDesignOnly;
  final bool requiresPrototypeValidation;
  final bool requiresSafetyReviewBeforeRelease;

  factory AllinmydayProductReport.fromWorkspace(
    AllinmydayProductWorkspace workspace,
  ) {
    final snapshot = workspace.reportSnapshot();
    return AllinmydayProductReport(
      motto: snapshot['motto']! as String,
      principle: snapshot['principle']! as String,
      productCount: snapshot['productCount']! as int,
      statusCounts:
          Map<String, int>.from(snapshot['statusCounts']! as Map),
      originalDesignOnly: snapshot['originalDesignOnly']! as bool,
      requiresPrototypeValidation:
          snapshot['requiresPrototypeValidation']! as bool,
      requiresSafetyReviewBeforeRelease:
          snapshot['requiresSafetyReviewBeforeRelease']! as bool,
    );
  }

  String get headline => '$productCount products in development';
}
