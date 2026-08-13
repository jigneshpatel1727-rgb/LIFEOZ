import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/yansi_brain.dart';
import '../services/yansi_due_date_parser.dart';

/// Dedicated Calendar core. Diary remains a Yansi capability rather than a
/// replacement for the fifth permanent LifeOS core.
class CalendarCoreScreen extends StatefulWidget {
  final String currency;

  const CalendarCoreScreen({super.key, required this.currency});

  @override
  State<CalendarCoreScreen> createState() => _CalendarCoreScreenState();
}

class _CalendarCoreScreenState extends State<CalendarCoreScreen> {
  bool loading = true;
  List<Map<String, dynamic>> events = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final brain = YansiBrain(prefs: prefs);
    final memory = await brain.getMemory();
    final calendar = memory.where((record) {
      final type = record['type']?.toString();
      return type == 'reminder' || type == 'calendar' || type == 'bill' || type == 'renewal';
    }).map((record) {
      final copy = Map<String, dynamic>.from(record);
      final text = (copy['text'] ?? copy['title'] ?? copy['event'] ?? '').toString();
      final parsed = YansiDueDateParser.parse(text);
      if (parsed != null) copy['dueDate'] = parsed.toIso8601String();
      return copy;
    }).toList()
      ..sort((a, b) => _eventDate(a).compareTo(_eventDate(b)));

    if (!mounted) return;
    setState(() {
      events = calendar;
      loading = false;
    });
  }

  DateTime _eventDate(Map<String, dynamic> record) {
    final due = DateTime.tryParse((record['dueDate'] ?? '').toString());
    if (due != null) return due;
    return DateTime.tryParse((record['date'] ?? '').toString()) ?? DateTime(9999);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02070B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.calendar_month_outlined, color: Color(0xFF00E5FF)),
            SizedBox(width: 10),
            Text('CALENDAR', style: TextStyle(fontSize: 13, letterSpacing: 2)),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
          : RefreshIndicator(
              color: const Color(0xFF00E5FF),
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: const LinearGradient(colors: [Color(0xFF071820), Color(0xFF030B10)]),
                      border: Border.all(color: Color(0xFF00E5FF), width: .6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('YANSI CALENDAR INTELLIGENCE', style: TextStyle(color: Color(0xFF76FFFF), fontSize: 9, letterSpacing: 2.2)),
                        const SizedBox(height: 14),
                        Text('${events.length}', style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('UPCOMING LIFE EVENTS', style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (events.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(36),
                      child: Center(child: Text('No calendar events yet.\nTell Yansi about a bill, renewal, birthday, appointment or due date.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, height: 1.5))),
                    ),
                  ...events.take(50).map(_eventTile),
                ],
              ),
            ),
    );
  }

  Widget _eventTile(Map<String, dynamic> record) {
    final text = (record['text'] ?? record['title'] ?? record['event'] ?? 'Calendar event').toString();
    final date = (record['dueDate'] ?? record['date'] ?? '').toString();
    final hasDueDate = record['dueDate'] != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.025), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00E5FF).withOpacity(.07)), child: const Icon(Icons.event_outlined, color: Color(0xFF00E5FF), size: 19)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12))),
          if (date.isNotEmpty) Text(_shortDate(date, explicit: hasDueDate), style: TextStyle(color: hasDueDate ? const Color(0xFF76FFFF) : Colors.white24, fontSize: 10)),
        ],
      ),
    );
  }

  String _shortDate(String value, {required bool explicit}) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return '';
    final prefix = explicit ? '' : '~';
    return '$prefix${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}';
  }
}
