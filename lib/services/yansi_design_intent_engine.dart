/// Converts natural design requests into safe, runtime UI preferences.
class YansiDesignIntentEngine {
  const YansiDesignIntentEngine();

  Map<String, dynamic> interpret(String request) {
    final text = request.trim().toLowerCase();
    final result = <String, dynamic>{
      'rawRequest': request,
      'theme': 'default',
      'iconStyle': 'default',
      'density': 'balanced',
      'animation': 'adaptive',
    };

    if (text.contains('neon') || text.contains('futur')) result['theme'] = 'futuristic';
    if (text.contains('minimal') || text.contains('simple')) result['density'] = 'minimal';
    if (text.contains('compact')) result['density'] = 'compact';
    if (text.contains('large') || text.contains('big')) result['density'] = 'spacious';
    if (text.contains('round') || text.contains('rounded')) result['iconStyle'] = 'rounded';
    if (text.contains('sharp')) result['iconStyle'] = 'sharp';
    if (text.contains('glow') || text.contains('neon')) result['iconStyle'] = 'glow';
    if (text.contains('motion') || text.contains('animated')) result['animation'] = 'expressive';
    if (text.contains('still') || text.contains('no animation')) result['animation'] = 'calm';

    return Map.unmodifiable(result);
  }
}
