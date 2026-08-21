import 'allinmyday_product_development_rules.dart';
import 'allinmyday_product_ecosystem.dart';

/// Application-facing service for the ALLINMYDAY product workspace.
///
/// Keeps product intelligence separate from presentation so the same source can
/// later drive the mobile workspace, Yansi actions and reports.
class AllinmydayProductWorkspace {
  const AllinmydayProductWorkspace();

  List<AllinmydayProduct> get products => allinmydayProductEcosystem;

  List<AllinmydayProduct> byStatus(AllinmydayProductStatus status) =>
      productsByStatus(status);

  List<AllinmydayProduct> byDepartment(String department) =>
      productsByDepartment(department);

  List<AllinmydayProduct> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.department.toLowerCase().contains(q) ||
            p.problem.toLowerCase().contains(q) ||
            p.solution.toLowerCase().contains(q))
        .toList(growable: false);
  }

  Map<String, int> statusCounts() {
    final result = <String, int>{};
    for (final status in AllinmydayProductStatus.values) {
      result[status.name] = byStatus(status).length;
    }
    return result;
  }

  bool isOriginal(AllinmydayProduct product) => product.originalDesign;

  bool canMarkProductionReady({
    required AllinmydayProduct product,
    required bool prototypeValidated,
    required bool safetyReviewed,
  }) {
    return AllinmydayProductDevelopmentRules.canClaimProductionReady(
      stage: product.status.name,
      prototypeValidated: prototypeValidated,
      safetyReviewed: safetyReviewed,
    );
  }

  Map<String, Object?> reportSnapshot() => {
        'motto': AllinmydayProductDevelopmentRules.motto,
        'principle': AllinmydayProductDevelopmentRules.principle,
        'productCount': products.length,
        'statusCounts': statusCounts(),
        'originalDesignOnly':
            AllinmydayProductDevelopmentRules.originalDesignOnly,
        'requiresPrototypeValidation':
            AllinmydayProductDevelopmentRules.requirePrototypeValidation,
        'requiresSafetyReviewBeforeRelease':
            AllinmydayProductDevelopmentRules.requireSafetyReviewBeforeRelease,
      };
}
