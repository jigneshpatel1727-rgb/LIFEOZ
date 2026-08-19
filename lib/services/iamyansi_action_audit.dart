import 'iamyansi_event_bus.dart';

/// Lightweight audit trail for Iamyansi lifecycle events.
/// Stores only the fields needed by the app for transparency and debugging.
class IamyansiActionAudit {
  final List<IamyansiAuditEntry> _entries = <IamyansiAuditEntry>[];
  final int maxEntries;

  IamyansiActionAudit({this.maxEntries = 200});

  List<IamyansiAuditEntry> get entries => List.unmodifiable(_entries);

  void attach(IamyansiEventBus bus) {
    bus.events.listen((event) {
      final data = Map<String, dynamic>.from(event.data);
      _entries.add(IamyansiAuditEntry(
        type: event.type,
        timestamp: DateTime.now(),
        data: data,
      ));
      if (_entries.length > maxEntries) {
        _entries.removeRange(0, _entries.length - maxEntries);
      }
    });
  }

  void clear() => _entries.clear();
}

class IamyansiAuditEntry {
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const IamyansiAuditEntry({
    required this.type,
    required this.timestamp,
    required this.data,
  });
}
