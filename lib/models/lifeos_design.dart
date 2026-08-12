import 'package:flutter/material.dart';

class LifeOSDesign {
  final int index;
  final String name;
  final String description;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color text;

  const LifeOSDesign({
    required this.index,
    required this.name,
    required this.description,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.text,
  });
}

/// The five established LifeOS visual worlds.
/// Keep these IDs stable because user profiles store the selected index.
const lifeOsDesigns = <LifeOSDesign>[
  LifeOSDesign(index: 0, name: 'Aurora Nexus', description: 'Neon aqua neural world', primary: Color(0xFF00FFD5), secondary: Color(0xFF00E5FF), background: Color(0xFF020B0B), text: Colors.white),
  LifeOSDesign(index: 1, name: 'Void Matrix', description: 'Deep blue intelligence grid', primary: Color(0xFF168CFF), secondary: Color(0xFF00D9FF), background: Color(0xFF020611), text: Colors.white),
  LifeOSDesign(index: 2, name: 'Quantum Purple', description: 'Quantum violet neural space', primary: Color(0xFFD24CFF), secondary: Color(0xFF6B5CFF), background: Color(0xFF0A0310), text: Colors.white),
  LifeOSDesign(index: 3, name: 'Solaris Prime', description: 'Warm solar command interface', primary: Color(0xFFFFC928), secondary: Color(0xFFFF7A18), background: Color(0xFF0B0802), text: Colors.white),
  LifeOSDesign(index: 4, name: 'Frost Minimal', description: 'Bright crystalline interface', primary: Color(0xFF147BFF), secondary: Color(0xFF00B7FF), background: Color(0xFFF4FAFF), text: Color(0xFF08244A)),
];

LifeOSDesign designByIndex(int index) {
  if (index < 0 || index >= lifeOsDesigns.length) return lifeOsDesigns.first;
  return lifeOsDesigns[index];
}
