/// Original ALLINMYDAY physical-product ecosystem catalog.
///
/// This is deliberately domain-only: no UI, vendor lock-in, pricing claims, or
/// third-party design assets are embedded here. UI layers can consume this model
/// later for the LifeOS / Yansi product-development workspace.
enum AllinmydayProductStatus {
  idea,
  concept,
  prototype,
  testing,
  productionReady,
}

class AllinmydayProduct {
  const AllinmydayProduct({
    required this.id,
    required this.name,
    required this.department,
    required this.problem,
    required this.solution,
    required this.status,
    required this.originalDesign,
    this.targetCost,
    this.targetRetail,
  });

  final String id;
  final String name;
  final String department;
  final String problem;
  final String solution;
  final AllinmydayProductStatus status;
  final bool originalDesign;
  final int? targetCost;
  final int? targetRetail;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'department': department,
        'problem': problem,
        'solution': solution,
        'status': status.name,
        'originalDesign': originalDesign,
        'targetCost': targetCost,
        'targetRetail': targetRetail,
      };
}

/// Central source of truth for the current ALLINMYDAY product-development
/// direction. These are development targets, not market or certification claims.
const allinmydayProductEcosystem = <AllinmydayProduct>[
  AllinmydayProduct(
    id: 'fan-bldc-1200',
    name: 'Designer BLDC Fan',
    department: 'Home / Energy',
    problem: 'High electricity use and difficult maintenance in everyday fans.',
    solution: 'Original 1200 mm BLDC fan with aerodynamic blades, modular service parts and measurable efficiency targets.',
    status: AllinmydayProductStatus.prototype,
    originalDesign: true,
    targetCost: 2700,
    targetRetail: 3999,
  ),
  AllinmydayProduct(
    id: 'water-tank-cassette',
    name: 'Tank Treatment Cassette',
    department: 'Water',
    problem: 'Household tanks can receive sediment or contaminated inflow.',
    solution: 'Removable in-tank treatment cassette with replaceable treatment stages; performance must be independently validated.',
    status: AllinmydayProductStatus.concept,
    originalDesign: true,
  ),
  AllinmydayProduct(
    id: 'no-bend-cleaning',
    name: 'No-Bend Cleaning System',
    department: 'Cleaning / Home',
    problem: 'Routine floor and surface cleaning can require repeated bending and multiple tools.',
    solution: 'Modular adjustable handle with original quick-lock heads for different cleaning jobs.',
    status: AllinmydayProductStatus.concept,
    originalDesign: true,
  ),
  AllinmydayProduct(
    id: 'ergonomic-cushion',
    name: 'Ergonomic Comfort Cushion',
    department: 'Health / Home',
    problem: 'Long sitting can create discomfort and pressure concentration.',
    solution: 'Multi-zone support cushion with replaceable cover and layered comfort materials; health claims require testing.',
    status: AllinmydayProductStatus.concept,
    originalDesign: true,
  ),
  AllinmydayProduct(
    id: 'smart-waste-bin',
    name: 'Smart Waste-Sorting Bin',
    department: 'Waste / Home',
    problem: 'Wet, dry and special household waste can be mixed.',
    solution: 'Simple three-compartment family bin with removable washable inserts and clear sorting cues.',
    status: AllinmydayProductStatus.concept,
    originalDesign: true,
  ),
  AllinmydayProduct(
    id: 'water-saving-tap',
    name: 'Water-Saving Tap',
    department: 'Water / Home',
    problem: 'Useful water is often wasted during everyday hand and kitchen washing.',
    solution: 'Low-maintenance flow-control and aeration architecture designed to reduce unnecessary flow.',
    status: AllinmydayProductStatus.idea,
    originalDesign: true,
  ),
  AllinmydayProduct(
    id: 'fresh-food-storage',
    name: 'Fresh-Food Storage System',
    department: 'Food / Kitchen',
    problem: 'Food can lose freshness or become difficult to organize.',
    solution: 'Modular reusable storage architecture focused on visibility, separation and easy cleaning.',
    status: AllinmydayProductStatus.idea,
    originalDesign: true,
  ),
  AllinmydayProduct(
    id: 'functional-clothing',
    name: 'Functional Climate Clothing',
    department: 'Clothing',
    problem: 'Everyday clothing must handle heat, sweat, storage and frequent washing.',
    solution: 'Original modular clothing system optimized around Indian everyday conditions.',
    status: AllinmydayProductStatus.idea,
    originalDesign: true,
  ),
  AllinmydayProduct(
    id: 'smart-drying-rack',
    name: 'Compact Drying Rack',
    department: 'Home',
    problem: 'Drying clothes can consume floor space and airflow is inconsistent.',
    solution: 'Foldable vertical rack with controlled airflow options and compact storage.',
    status: AllinmydayProductStatus.idea,
    originalDesign: true,
  ),
  AllinmydayProduct(
    id: 'senior-home-kit',
    name: 'Senior Independence Home Kit',
    department: 'Seniors / Health',
    problem: 'Small daily tasks can become difficult when grip, reach or balance changes.',
    solution: 'Modular easy-grip, anti-slip and visibility-focused household accessories.',
    status: AllinmydayProductStatus.idea,
    originalDesign: true,
  ),
  AllinmydayProduct(
    id: 'pet-home-system',
    name: 'Pet Home Care System',
    department: 'Pets',
    problem: 'Feeding, hydration, cleaning and travel create repetitive household work.',
    solution: 'Modular washable feeding, hydration and comfort components.',
    status: AllinmydayProductStatus.idea,
    originalDesign: true,
  ),
  AllinmydayProduct(
    id: 'travel-comfort-system',
    name: 'Travel Comfort System',
    department: 'Travel / Vehicle',
    problem: 'Small travel items become difficult to organize and access.',
    solution: 'Modular storage, comfort and drying accessories designed as one reusable system.',
    status: AllinmydayProductStatus.idea,
    originalDesign: true,
  ),
];

List<AllinmydayProduct> productsByDepartment(String department) {
  final normalized = department.trim().toLowerCase();
  return allinmydayProductEcosystem
      .where((product) => product.department.toLowerCase().contains(normalized))
      .toList(growable: false);
}

List<AllinmydayProduct> productsByStatus(AllinmydayProductStatus status) {
  return allinmydayProductEcosystem
      .where((product) => product.status == status)
      .toList(growable: false);
}
