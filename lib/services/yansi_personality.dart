/// Natural-language personality layer for Yansi.
/// It keeps tone separate from the underlying LifeOS intelligence so the same
/// answer can be delivered professionally, warmly, or casually.
class YansiPersonality {
  const YansiPersonality();

  YansiTone detectTone(String input) {
    final text = input.trim().toLowerCase();
    if (text.isEmpty) return YansiTone.neutral;
    if (text.contains('please') || text.contains('could you') || text.contains('would you')) {
      return YansiTone.polite;
    }
    if (RegExp(r'\b(hi|hey|hello|bro|buddy|friend|thanks|thank you|lol|haha)\b').hasMatch(text)) {
      return YansiTone.friendly;
    }
    if (text.contains('?') || text.startsWith('how ') || text.startsWith('why ') || text.startsWith('what ')) {
      return YansiTone.inquisitive;
    }
    return YansiTone.neutral;
  }

  String wrap(String answer, {required YansiTone tone}) {
    final clean = answer.trim();
    if (clean.isEmpty) return 'I’m here. Tell me what you need.';
    switch (tone) {
      case YansiTone.friendly:
        return 'Sure — $clean';
      case YansiTone.polite:
        return clean;
      case YansiTone.inquisitive:
        return clean;
      case YansiTone.neutral:
        return clean;
    }
  }

  String complexityGuidance(String input) {
    final text = input.toLowerCase();
    final complex = text.length > 180 ||
        RegExp(r'\b(compare|analyse|analyze|calculate|strategy|explain|why|forecast|plan)\b')
            .hasMatch(text);
    return complex
        ? 'Use structured reasoning, state assumptions, separate facts from estimates, and explain the conclusion clearly.'
        : 'Answer directly and conversationally.';
  }
}

enum YansiTone { neutral, friendly, polite, inquisitive }
