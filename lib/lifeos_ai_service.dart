class LifeOSAIService {
  Future<String> analyze({
    required String category,
    required double amount,
    required String description,
  }) async {
    final normalizedCategory = category.trim().toLowerCase();
    final note = description.trim();

    if (amount >= 10000) {
      return 'High-value expense: ₹${amount.toStringAsFixed(0)}. Review whether this expense is necessary, compare alternatives, and check if it can be planned or reduced.';
    }

    if (normalizedCategory.contains('food') ||
        normalizedCategory.contains('restaurant') ||
        normalizedCategory.contains('shopping')) {
      return 'LifeOS suggestion: this is a controllable expense. Track similar expenses this month and set a practical limit before the next purchase.';
    }

    if (normalizedCategory.contains('fuel') ||
        normalizedCategory.contains('petrol') ||
        normalizedCategory.contains('diesel')) {
      return 'LifeOS suggestion: monitor fuel spending against your monthly travel. Combining trips, reducing unnecessary travel, and comparing fuel efficiency can help reduce this cost.';
    }

    if (normalizedCategory.contains('electricity') ||
        normalizedCategory.contains('bill') ||
        normalizedCategory.contains('utility')) {
      return 'LifeOS suggestion: this looks like a regular household cost. Compare it with previous months and look for avoidable usage or opportunities to reduce the next bill.';
    }

    if (normalizedCategory.contains('emi') ||
        normalizedCategory.contains('loan')) {
      return 'LifeOS suggestion: EMI is usually a committed expense. Focus on reducing discretionary spending around it and consider prepayment only after maintaining an emergency reserve.';
    }

    if (amount <= 500) {
      return 'LifeOS suggestion: small expenses can add up. Keep tracking this expense and review the monthly total for this category.';
    }

    if (note.isNotEmpty) {
      return 'LifeOS reviewed this ₹${amount.toStringAsFixed(0)} $category expense. Keep the description for better monthly reports and compare this category with your previous spending.';
    }

    return 'LifeOS reviewed this ₹${amount.toStringAsFixed(0)} expense. Continue tracking it so the AI can identify patterns and suggest where you can save money.';
  }
}
