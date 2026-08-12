class YansiInvestmentPosition {
  final String id;
  final String name;
  final String type;
  final double units;
  final double investedAmount;
  final double currentValue;
  final DateTime? updatedAt;

  const YansiInvestmentPosition({
    required this.id,
    required this.name,
    required this.type,
    required this.units,
    required this.investedAmount,
    required this.currentValue,
    this.updatedAt,
  });

  double get profitLoss => currentValue - investedAmount;
  double get returnPercent => investedAmount == 0 ? 0 : profitLoss / investedAmount * 100;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'units': units,
        'investedAmount': investedAmount,
        'currentValue': currentValue,
        'updatedAt': updatedAt?.toUtc().toIso8601String(),
      };
}

/// Local investment domain model. Market prices must come from an approved,
/// user-permitted data provider; this class never invents live prices.
class YansiInvestmentTracker {
  const YansiInvestmentTracker();

  YansiInvestmentPosition createPosition({
    required String id,
    required String name,
    required String type,
    required double units,
    required double investedAmount,
    double currentValue = 0,
    DateTime? updatedAt,
  }) {
    if (id.trim().isEmpty || name.trim().isEmpty) {
      throw ArgumentError('Investment id and name are required.');
    }
    if (units < 0 || investedAmount < 0 || currentValue < 0) {
      throw ArgumentError('Investment values cannot be negative.');
    }
    return YansiInvestmentPosition(
      id: id.trim(),
      name: name.trim(),
      type: type.trim().isEmpty ? 'other' : type.trim(),
      units: units,
      investedAmount: investedAmount,
      currentValue: currentValue,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
