import 'package:flutter/material.dart';
import '../services/yansi_ambient_insight.dart';
import '../services/yansi_ambient_ui.dart';

/// Compact ambient insight surface: futuristic, dismissible, and never a chat panel.
class YansiAmbientInsightCard extends StatelessWidget {
  final YansiAmbientInsight insight;
  final VoidCallback onDismiss;
  final VoidCallback? onAction;

  const YansiAmbientInsightCard({
    super.key,
    required this.insight,
    required this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(insight.core);
    return Semantics(
      label: 'Yansi ambient insight',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: YansiAmbientUi.glass(accent: accent),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(top: 5, right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent,
                boxShadow: [BoxShadow(color: accent, blurRadius: 9)],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: onAction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(insight.text, style: YansiAmbientUi.body()),
                    const SizedBox(height: 6),
                    Text(insight.action, style: YansiAmbientUi.micro(color: accent)),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              visualDensity: VisualDensity.compact,
              iconSize: 16,
              tooltip: 'Dismiss insight',
              icon: const Icon(Icons.close, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  Color _accentFor(String core) {
    switch (core.toUpperCase()) {
      case 'MONEY':
        return const Color(0xFFFFC928);
      case 'HEALTH':
        return const Color(0xFFFF5F7A);
      case 'TASKS':
        return const Color(0xFF35FF72);
      case 'CALENDAR':
        return const Color(0xFF168CFF);
      default:
        return YansiAmbientUi.cyan;
    }
  }
}
