import 'package:flutter/material.dart';

/// Canonical LIFEOZ visual identity registry.
///
/// These are product-level definitions, not generic Material icon mappings.
/// The renderer is intentionally separate so the same identity can later be
/// used by Android, wearables, holographic surfaces, and other clients.
class LifeozReality {
  final String id;
  final String name;
  final String principle;
  final Color primary;
  final Color secondary;
  final Color deep;
  final RealityMotion motion;

  const LifeozReality({
    required this.id,
    required this.name,
    required this.principle,
    required this.primary,
    required this.secondary,
    required this.deep,
    required this.motion,
  });
}

enum RealityMotion { neural, refraction, crystalline, organic, orbital, eclipse }

const lifeozRealities = <LifeozReality>[
  LifeozReality(
    id: 'oreon_prime',
    name: 'OREON PRIME',
    principle: 'Living cosmic intelligence',
    primary: Color(0xFF39E7FF),
    secondary: Color(0xFFFFB347),
    deep: Color(0xFF020A18),
    motion: RealityMotion.neural,
  ),
  LifeozReality(
    id: 'terra_flux',
    name: 'TERRA FLUX',
    principle: 'Organic adaptive intelligence',
    primary: Color(0xFF63FFB1),
    secondary: Color(0xFF36D9FF),
    deep: Color(0xFF03130D),
    motion: RealityMotion.organic,
  ),
  LifeozReality(
    id: 'vortex_nexus',
    name: 'VORTEX NEXUS',
    principle: 'Dimensional information flow',
    primary: Color(0xFFFFC76B),
    secondary: Color(0xFF7A8CFF),
    deep: Color(0xFF090616),
    motion: RealityMotion.orbital,
  ),
  LifeozReality(
    id: 'crysta_lumen',
    name: 'CRYSTA LUMEN',
    principle: 'Precision through light geometry',
    primary: Color(0xFFB88CFF),
    secondary: Color(0xFF5CFFFF),
    deep: Color(0xFF0A0617),
    motion: RealityMotion.crystalline,
  ),
  LifeozReality(
    id: 'nebula_soul',
    name: 'NEBULA SOUL',
    principle: 'Emotion and contextual intelligence',
    primary: Color(0xFFFF6CBA),
    secondary: Color(0xFFFFA83D),
    deep: Color(0xFF12030F),
    motion: RealityMotion.refraction,
  ),
  LifeozReality(
    id: 'shadow_core',
    name: 'SHADOW CORE',
    principle: 'Minimal intelligence with maximum signal',
    primary: Color(0xFFF2F7FF),
    secondary: Color(0xFF7CEBFF),
    deep: Color(0xFF010205),
    motion: RealityMotion.eclipse,
  ),
];

/// Meaning-first core glyph identifiers. These are intentionally semantic
/// rather than tied to a platform icon set.
class LifeozGlyph {
  final String id;
  final String meaning;
  final String geometry;

  const LifeozGlyph(this.id, this.meaning, this.geometry);
}

const lifeozGlyphs = <LifeozGlyph>[
  LifeozGlyph('genesis', 'Goals, growth and life direction', 'seed-to-orbit'),
  LifeozGlyph('guardian', 'Health, family and personal wellbeing', 'protected-heart'),
  LifeozGlyph('wealth_flow', 'Money, spending, income and investment', 'continuous-flow'),
  LifeozGlyph('time_harmony', 'Tasks, dates, bills and commitments', 'temporal-weave'),
  LifeozGlyph('knowledge_core', 'Diary, ideas, learning and documents', 'mind-orbit'),
];

LifeozReality realityFor(String id) => lifeozRealities.firstWhere(
      (reality) => reality.id == id,
      orElse: () => lifeozRealities.first,
    );

LifeozGlyph glyphFor(int index) => lifeozGlyphs[index.clamp(0, lifeozGlyphs.length - 1)];
