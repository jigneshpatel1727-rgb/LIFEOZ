import 'yansi_proactive_suggestions.dart';
import 'yansi_receipt_scanner.dart';

/// Turns a reviewed receipt scan into Yansi suggestions without silently
/// committing anything. Persistence remains the responsibility of the
/// existing receipt intelligence service.
class YansiReceiptInsightBridge {
  const YansiReceiptInsightBridge();

  List<YansiProactiveSuggestion> evaluate(YansiReceiptResult receipt) {
    final result = <YansiProactiveSuggestion>[];
    final total = receipt.total;

    if (total != null && total > 0) {
      final merchant = receipt.merchant?.trim();
      final label = merchant == null || merchant.isEmpty ? 'this purchase' : merchant;
      result.add(YansiProactiveSuggestion(
        title: 'Purchase recognized',
        message: 'I recognized $label at about ${total.toStringAsFixed(2)}. I can categorize it and include it in your spending picture.',
        core: 'money',
        priority: 72,
      ));
    }

    final food = receipt.items.where((item) => item.category == 'food').length;
    final household = receipt.items.where((item) => item.category == 'household').length;

    if (food > 0 || household > 0) {
      result.add(YansiProactiveSuggestion(
        title: 'Household spending signal',
        message: 'This receipt contains $food food and $household household item${food + household == 1 ? '' : 's'}. I can use the pattern for future household planning.',
        core: 'household',
        priority: 68,
      ));
    }

    return result;
  }
}
