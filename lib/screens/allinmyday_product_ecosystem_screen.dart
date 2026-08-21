import 'package:flutter/material.dart';
import '../allinmyday_product_ecosystem.dart';

/// ALLINMYDAY product-development workspace.
///
/// This screen is intentionally data-driven and uses only Flutter primitives;
/// no third-party visual assets are required.
class AllinmydayProductEcosystemScreen extends StatefulWidget {
  const AllinmydayProductEcosystemScreen({super.key});

  @override
  State<AllinmydayProductEcosystemScreen> createState() =>
      _AllinmydayProductEcosystemScreenState();
}

class _AllinmydayProductEcosystemScreenState
    extends State<AllinmydayProductEcosystemScreen> {
  String _filter = 'ALL';
  String _query = '';

  List<AllinmydayProduct> get _products {
    final q = _query.trim().toLowerCase();
    return allinmydayProductEcosystem.where((p) {
      final status = _statusLabel(p.status);
      final matchesFilter = _filter == 'ALL' || status == _filter;
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.department.toLowerCase().contains(q) ||
          p.problem.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList(growable: false);
  }

  String _statusLabel(AllinmydayProductStatus status) {
    switch (status) {
      case AllinmydayProductStatus.idea:
        return 'IDEA';
      case AllinmydayProductStatus.concept:
        return 'CONCEPT';
      case AllinmydayProductStatus.prototype:
        return 'PROTOTYPE';
      case AllinmydayProductStatus.testing:
        return 'TESTING';
      case AllinmydayProductStatus.productionReady:
        return 'PRODUCTION';
    }
  }

  Color _statusColor(AllinmydayProductStatus status) {
    switch (status) {
      case AllinmydayProductStatus.idea:
        return const Color(0xFF8FA7B5);
      case AllinmydayProductStatus.concept:
        return const Color(0xFF9B7CFF);
      case AllinmydayProductStatus.prototype:
        return const Color(0xFF00E5FF);
      case AllinmydayProductStatus.testing:
        return const Color(0xFFFFC857);
      case AllinmydayProductStatus.productionReady:
        return const Color(0xFF55FF88);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01060A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01060A),
        elevation: 0,
        title: const Text(
          'ALLINMYDAY',
          style: TextStyle(letterSpacing: 3, fontSize: 15),
        ),
        subtitle: const Text('PRODUCT ECOSYSTEM'),
      ),
      body: Column(
        children: [
          _header(),
          _filters(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
              itemCount: _products.length,
              itemBuilder: (_, index) => _productCard(_products[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final prototypeCount = productsByStatus(AllinmydayProductStatus.prototype).length;
    final conceptCount = productsByStatus(AllinmydayProductStatus.concept).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LESS INFORMATION. MORE PRODUCT INTELLIGENCE.',
            style: TextStyle(color: Color(0xFF7FA2B2), fontSize: 9, letterSpacing: 1.5),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _metric('PRODUCTS', allinmydayProductEcosystem.length.toString()),
              const SizedBox(width: 8),
              _metric('PROTOTYPES', prototypeCount.toString()),
              const SizedBox(width: 8),
              _metric('CONCEPTS', conceptCount.toString()),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Find a product or department',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF00E5FF), size: 19),
              filled: true,
              fillColor: const Color(0xFF07151C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0x2200E5FF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0x2200E5FF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF061219),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x2200E5FF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 7, letterSpacing: 1)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(color: Color(0xFF55FF88), fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _filters() {
    const filters = ['ALL', 'PROTOTYPE', 'CONCEPT', 'IDEA', 'TESTING', 'PRODUCTION'];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (_, i) {
          final active = _filter == filters[i];
          return ChoiceChip(
            label: Text(filters[i], style: TextStyle(color: active ? const Color(0xFF01060A) : Colors.white70, fontSize: 8, letterSpacing: 1)),
            selected: active,
            onSelected: (_) => setState(() => _filter = filters[i]),
            selectedColor: const Color(0xFF00E5FF),
            backgroundColor: const Color(0xFF061219),
            side: const BorderSide(color: Color(0x2200E5FF)),
          );
        },
      ),
    );
  }

  Widget _productCard(AllinmydayProduct p) {
    final color = _statusColor(p.status);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xCC061219),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.20)),
        boxShadow: [BoxShadow(color: color.withOpacity(.05), blurRadius: 18)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(.10),
                  border: Border.all(color: color.withOpacity(.35)),
                ),
                child: Icon(_iconFor(p.id), color: color, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(p.department, style: TextStyle(color: color, fontSize: 8, letterSpacing: 1.1)),
                  ],
                ),
              ),
              _statusPill(p.status),
            ],
          ),
          const SizedBox(height: 12),
          _line('PROBLEM', p.problem),
          const SizedBox(height: 7),
          _line('ALLINMYDAY SOLUTION', p.solution),
          const SizedBox(height: 10),
          Row(
            children: [
              _tag(p.originalDesign ? 'ORIGINAL DESIGN' : 'REVIEW'),
              if (p.targetCost != null) ...[
                const SizedBox(width: 7),
                _tag('TARGET ₹${p.targetCost}'),
              ],
              if (p.targetRetail != null) ...[
                const SizedBox(width: 7),
                _tag('RETAIL ₹${p.targetRetail}'),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(String title, String text) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '$title  ', style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 7, letterSpacing: 1)),
          TextSpan(text: text, style: const TextStyle(color: Colors.white60, fontSize: 10, height: 1.35)),
        ],
      ),
    );
  }

  Widget _statusPill(AllinmydayProductStatus status) {
    final c = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: c.withOpacity(.10), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(.35))),
      child: Text(_statusLabel(status), style: TextStyle(color: c, fontSize: 7, letterSpacing: .8)),
    );
  }

  Widget _tag(String text) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(color: const Color(0xFF081820), borderRadius: BorderRadius.circular(7)),
        child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 7, letterSpacing: .5)),
      ),
    );
  }

  IconData _iconFor(String id) {
    if (id.contains('fan')) return Icons.air;
    if (id.contains('water')) return Icons.water_drop_outlined;
    if (id.contains('cleaning')) return Icons.cleaning_services_outlined;
    if (id.contains('cushion')) return Icons.event_seat_outlined;
    if (id.contains('waste')) return Icons.delete_outline;
    if (id.contains('food')) return Icons.restaurant_outlined;
    if (id.contains('clothing')) return Icons.checkroom_outlined;
    if (id.contains('drying')) return Icons.local_laundry_service_outlined;
    if (id.contains('senior')) return Icons.accessibility_new_outlined;
    if (id.contains('pet')) return Icons.pets_outlined;
    return Icons.travel_explore_outlined;
  }
}
