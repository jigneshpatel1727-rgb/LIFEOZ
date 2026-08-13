/// Lightweight index for matching user-approved historical context to a request.
class YansiPersonalContextIndex {
  const YansiPersonalContextIndex();

  List<Map<String, dynamic>> findMatches({
    required List<Map<String, dynamic>> entries,
    required String query,
  }) {
    final terms = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((term) => term.length > 2)
        .toSet();

    if (terms.isEmpty) return const <Map<String, dynamic>>[];

    return entries.where((entry) {
      final text = entry.values.map((value) => value.toString().toLowerCase()).join(' ');
      return terms.any(text.contains);
    }).toList(growable: false);
  }
}
