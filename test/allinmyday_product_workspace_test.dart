import 'package:flutter_test/flutter_test.dart';
import 'package:lifeoz/allinmyday_product_development_rules.dart';
import 'package:lifeoz/allinmyday_product_ecosystem.dart';
import 'package:lifeoz/allinmyday_product_workspace.dart';

void main() {
  const workspace = AllinmydayProductWorkspace();

  test('ecosystem contains only original-design records', () {
    expect(workspace.products, isNotEmpty);
    expect(workspace.products.every((product) => product.originalDesign), isTrue);
  });

  test('status counts cover the complete catalog', () {
    final counts = workspace.statusCounts();
    final total = counts.values.fold<int>(0, (sum, value) => sum + value);
    expect(total, workspace.products.length);
  });

  test('search is case-insensitive across product fields', () {
    expect(workspace.search('BLDC'), isNotEmpty);
    expect(workspace.search('water'), isNotEmpty);
    expect(workspace.search('does-not-exist'), isEmpty);
  });

  test('production readiness requires validation and safety review', () {
    final fan = workspace.products.firstWhere((p) => p.id == 'fan-bldc-1200');
    expect(
      workspace.canMarkProductionReady(
        product: fan,
        prototypeValidated: false,
        safetyReviewed: true,
      ),
      isFalse,
    );
    expect(
      workspace.canMarkProductionReady(
        product: fan,
        prototypeValidated: true,
        safetyReviewed: true,
      ),
      isFalse,
    );
  });

  test('motto and originality policy are exposed centrally', () {
    expect(AllinmydayProductDevelopmentRules.motto,
        'One screen. One tap. One report.');
    expect(AllinmydayProductDevelopmentRules.originalDesignOnly, isTrue);
  });
}
