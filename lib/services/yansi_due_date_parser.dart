/// Lightweight, local-first due-date extraction for Yansi calendar signals.
/// It never guesses a date when the user's wording is ambiguous.
class YansiDueDateParser {
  static DateTime? parse(String text, {DateTime? now}) {
    final base = now ?? DateTime.now();
    final value = text.toLowerCase().trim();
    if (value.contains('today')) return _date(base);
    if (value.contains('tomorrow')) return _date(base.add(const Duration(days: 1)));
    if (value.contains('day after tomorrow')) return _date(base.add(const Duration(days: 2)));

    final inDays = RegExp(r'\bin\s+(\d+)\s+days?\b').firstMatch(value);
    if (inDays != null) {
      return _date(base.add(Duration(days: int.parse(inDays.group(1)!))));
    }

    final slash = RegExp(r'\b(\d{1,2})[/-](\d{1,2})(?:[/-](\d{2,4}))?\b').firstMatch(value);
    if (slash != null) {
      final day = int.parse(slash.group(1)!);
      final month = int.parse(slash.group(2)!);
      final yearText = slash.group(3);
      final year = yearText == null ? base.year : _year(yearText);
      if (_valid(year, month, day)) return DateTime(year, month, day);
    }

    final months = <String, int>{
      'january': 1, 'february': 2, 'march': 3, 'april': 4,
      'may': 5, 'june': 6, 'july': 7, 'august': 8,
      'september': 9, 'october': 10, 'november': 11, 'december': 12,
    };
    for (final entry in months.entries) {
      final match = RegExp(r'\b(\d{1,2})(?:st|nd|rd|th)?\s+' + entry.key + r'(?:\s+(\d{4}))?\b').firstMatch(value);
      if (match != null) {
        final day = int.parse(match.group(1)!);
        final year = match.group(2) == null ? base.year : int.parse(match.group(2)!);
        if (_valid(year, entry.value, day)) return DateTime(year, entry.value, day);
      }
    }
    return null;
  }

  static DateTime _date(DateTime value) => DateTime(value.year, value.month, value.day);
  static int _year(String value) => value.length == 2 ? 2000 + int.parse(value) : int.parse(value);
  static bool _valid(int year, int month, int day) {
    final d = DateTime(year, month, day);
    return d.year == year && d.month == month && d.day == day;
  }
}
