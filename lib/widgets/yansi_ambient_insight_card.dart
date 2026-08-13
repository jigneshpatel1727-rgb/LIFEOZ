import 'package:flutter/material.dart';
import '../services/yansi_ambient_insight.dart';
import '../services/yansi_ambient_ui.dart';

/// A compact ambient insight surface: futuristic, dismissible, and never a chat panel.
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
    return Semantics(
      label: 'Yansi ambient insight',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: YansiAmbientUi.glass(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(top: 5, right: 10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: YansiAmbientUi.cyan,
                boxShadow: [BoxShadow(color: YansiAmbientUi.cyan, blurRadius: 9)],
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
                    Text(insight.action, style: YansiAmbientUi.micro()),
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
}
