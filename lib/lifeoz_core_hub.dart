import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LifeOZCoreHub extends StatefulWidget {
  final SharedPreferences prefs;
  final int coreIndex;
  const LifeOZCoreHub({super.key, required this.prefs, required this.coreIndex});

  @override
  State<LifeOZCoreHub> createState() => _LifeOZCoreHubState();
}

class _LifeOZCoreHubState extends State<LifeOZCoreHub> {
  final FlutterTts _tts = FlutterTts();
  late List<Map<String, dynamic>> _records;
  static const titles = ['GROWTH', 'CARE', 'PROSPERITY', 'TIME', 'PERSONAL'];
  static const subtitles = ['Goals, productivity and progress', 'Household, health and daily care', 'Expenses, investments and financial flow', 'Tasks, calendar and commitments', 'Diary, reflection and personal goals'];
  static const colors = [0xFF4FEF83, 0xFFFF5A61, 0xFFFFB83D, 0xFF42D9FF, 0xFFC86BFF];
  String get _key => 'lifeoz_core_${widget.coreIndex}_records';

  @override
  void initState() { super.initState(); _records = _load(); _tts.setSpeechRate(0.44); }

  List<Map<String, dynamic>> _load() {
    final raw = widget.prefs.getString(_key);
    if (raw == null) return <Map<String, dynamic>>[];
    try { return (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList(); } catch (_) { return <Map<String, dynamic>>[]; }
  }

  Future<void> _save() async => widget.prefs.setString(_key, jsonEncode(_records));

  Future<void> _speakSummary() async {
    final done = _records.where((r) => r['done'] == true).length;
    final total = _records.length;
    final message = total == 0 ? '${titles[widget.coreIndex]} is clear. Add your first record when ready.' : '${titles[widget.coreIndex]} has $total records. $done are complete.';
    await _tts.stop(); await _tts.speak(message);
  }

  Future<void> _addRecord() async {
    final title = TextEditingController();
    final value = TextEditingController();
    final note = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF07101B),
        title: Text('ADD ${titles[widget.coreIndex]} RECORD'),
        content: SingleChildScrollView(child: Column(children: [
          TextField(controller: title, autofocus: true, decoration: const InputDecoration(labelText: 'What should Yansi remember?')),
          if (widget.coreIndex == 2) TextField(controller: value, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount (optional)')),
          TextField(controller: note, maxLines: 2, decoration: const InputDecoration(labelText: 'Note (optional)')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(ctx, {'title': title.text.trim(), 'value': value.text.trim(), 'note': note.text.trim()}), child: const Text('SAVE')),
        ],
      ),
    );
    title.dispose(); value.dispose(); note.dispose();
    if (result == null || (result['title'] ?? '').isEmpty) return;
    setState(() => _records.insert(0, {'id': DateTime.now().microsecondsSinceEpoch.toString(), 'title': result['title'], 'value': result['value'] ?? '', 'note': result['note'] ?? '', 'done': false, 'date': DateTime.now().toIso8601String()}));
    await _save();
    await _tts.stop(); await _tts.speak('Got it. I added ${result['title']}.');
  }

  Future<void> _toggle(int index) async { setState(() => _records[index]['done'] = !(_records[index]['done'] == true)); await _save(); }

  Future<void> _delete(int index) async {
    final removed = _records[index]['title'] ?? 'record';
    setState(() => _records.removeAt(index)); await _save();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed $removed')));
  }

  String _date(String raw) { final d = DateTime.tryParse(raw); if (d == null) return ''; return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}'; }

  @override
  void dispose() { _tts.stop(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final accent = Color(colors[widget.coreIndex]);
    final done = _records.where((r) => r['done'] == true).length;
    final progress = _records.isEmpty ? 0.0 : done / _records.length;
    return Scaffold(
      backgroundColor: const Color(0xFF01030A),
      appBar: AppBar(backgroundColor: Colors.transparent, title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titles[widget.coreIndex], style: const TextStyle(letterSpacing: 2.2, fontWeight: FontWeight.w700)), Text(subtitles[widget.coreIndex], style: const TextStyle(fontSize: 11, color: Colors.white54))]), actions: [IconButton(onPressed: _speakSummary, icon: const Icon(Icons.graphic_eq_rounded)), const SizedBox(width: 8)]),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addRecord, backgroundColor: accent, foregroundColor: Colors.black, icon: const Icon(Icons.add), label: const Text('ADD')),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withOpacity(.035), borderRadius: BorderRadius.circular(22), border: Border.all(color: accent.withOpacity(.25))), child: Row(children: [
          SizedBox(width: 74, height: 74, child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: progress, strokeWidth: 5, color: accent, backgroundColor: Colors.white10), Text('${(progress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w700))])),
          const SizedBox(width: 18), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${_records.length} SIGNALS', style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text('$done completed • ${_records.length - done} active', style: const TextStyle(color: Colors.white60))])),
        ])),
        const SizedBox(height: 18),
        if (_records.isEmpty)
          Container(padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24), decoration: BoxDecoration(color: Colors.white.withOpacity(.025), borderRadius: BorderRadius.circular(22)), child: const Column(children: [Icon(Icons.auto_awesome, size: 38, color: Colors.white30), SizedBox(height: 12), Text('NO RECORDS YET', style: TextStyle(letterSpacing: 2, color: Colors.white60)), SizedBox(height: 7), Text('Tap ADD and let Yansi build this intelligence stream.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38))]))
        else
          ...List.generate(_records.length, (i) {
            final r = _records[i]; final completed = r['done'] == true;
            return Dismissible(key: ValueKey(r['id']), direction: DismissDirection.endToStart, confirmDismiss: (_) async { await _delete(i); return false; }, background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: Colors.red.withOpacity(.18), child: const Icon(Icons.delete_outline)), child: Card(color: Colors.white.withOpacity(.035), margin: const EdgeInsets.only(bottom: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: completed ? accent.withOpacity(.18) : Colors.white10)), child: ListTile(onTap: () => _toggle(i), leading: Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked, color: completed ? accent : Colors.white30), title: Text(r['title'] ?? '', style: TextStyle(decoration: completed ? TextDecoration.lineThrough : null, color: completed ? Colors.white54 : Colors.white)), subtitle: Text([if ((r['value'] ?? '').toString().isNotEmpty) '₹${r['value']}', if ((r['note'] ?? '').toString().isNotEmpty) r['note'], _date(r['date'] ?? '')].join('  •  '), maxLines: 2, overflow: TextOverflow.ellipsis), trailing: IconButton(onPressed: () => _delete(i), icon: const Icon(Icons.delete_outline, color: Colors.white38)))));
          }),
      ]),
    );
  }
}
