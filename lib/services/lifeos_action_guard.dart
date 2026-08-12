import 'lifeos_intelligence_bus.dart';

enum LifeOSActionRisk { safe, confirm, blocked }

class LifeOSActionDecision {
  final LifeOSActionRisk risk;
  final String reason;
  const LifeOSActionDecision(this.risk, this.reason);
}

/// Safety boundary for Yansi actions. Sensitive operations require consent.
class LifeOSActionGuard {
  const LifeOSActionGuard();

  LifeOSActionDecision evaluate({required String action, required LifeOSSignalType source}) {
    final value = action.toLowerCase();
    if (value.contains('delete all') || value.contains('erase all') || value.contains('transfer money')) {
      return const LifeOSActionDecision(LifeOSActionRisk.blocked, 'This action is too sensitive for automatic execution.');
    }
    if (source == LifeOSSignalType.investment || value.contains('pay ') || value.contains('send money') || value.contains('purchase') || value.contains('change policy')) {
      return const LifeOSActionDecision(LifeOSActionRisk.confirm, 'Explicit user confirmation is required before this action.');
    }
    return const LifeOSActionDecision(LifeOSActionRisk.safe, 'Safe to prepare or perform within granted permissions.');
  }
}
