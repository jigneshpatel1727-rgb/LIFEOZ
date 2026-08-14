/// Five selectable visual identities for the LifeOS shell.
///
/// Each identity owns its palette, visual language and icon family while
/// keeping the same five-core information architecture.
enum LifeOSDesignId { neural, quantum, holographic, aurora, cyber } 

class LifeOSIconSet {
  final String money;
  final String productivity;
  final String calendar;
  final String household;
  final String goals;

  const LifeOSIconSet({
    required this.money,
    required this.productivity,
    required this.calendar,
    required this.household,
    required this.goals,
  });
}

class LifeOSDesignProfile {
  final LifeOSDesignId id;
  final String name;
  final int primaryColor;
  final int secondaryColor;
  final int backgroundColor;
  final LifeOSIconSet icons;

  const LifeOSDesignProfile({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.icons,
  });
}

class LifeOSDesignCatalog {
  const LifeOSDesignCatalog();

  static const profiles = <LifeOSDesignProfile>[
    LifeOSDesignProfile(
      id: LifeOSDesignId.neural,
      name: 'Neural Flow',
      primaryColor: 0xFF00E5FF,
      secondaryColor: 0xFF63FFB1,
      backgroundColor: 0xFF02070B,
      icons: LifeOSIconSet(money: '◈', productivity: 'ϟ', calendar: '⌁', household: '◇', goals: '◎'),
    ),
    LifeOSDesignProfile(
      id: LifeOSDesignId.quantum,
      name: 'Quantum Pulse',
      primaryColor: 0xFF8A9CFF,
      secondaryColor: 0xFFFF5CE1,
      backgroundColor: 0xFF070512,
      icons: LifeOSIconSet(money: '◉', productivity: '⟡', calendar: '◌', household: '⬡', goals: '⊙'),
    ),
    LifeOSDesignProfile(
      id: LifeOSDesignId.holographic,
      name: 'Holo Prism',
      primaryColor: 0xFF00FFC6,
      secondaryColor: 0xFF5C7CFF,
      backgroundColor: 0xFF020B0D,
      icons: LifeOSIconSet(money: '▣', productivity: '✦', calendar: '⌬', household: '◇', goals: '✧'),
    ),
    LifeOSDesignProfile(
      id: LifeOSDesignId.aurora,
      name: 'Aurora Core',
      primaryColor: 0xFFB8FF4D,
      secondaryColor: 0xFF00E5FF,
      backgroundColor: 0xFF041008,
      icons: LifeOSIconSet(money: '△', productivity: '↯', calendar: '◫', household: '⌂', goals: '◈'),
    ),
    LifeOSDesignProfile(
      id: LifeOSDesignId.cyber,
      name: 'Cyber Matrix',
      primaryColor: 0xFFFF3D9A,
      secondaryColor: 0xFF00F0FF,
      backgroundColor: 0xFF08040A,
      icons: LifeOSIconSet(money: '▱', productivity: '⚡', calendar: '◍', household: '⬢', goals: '✺'),
    ),
  ];

  LifeOSDesignProfile byId(LifeOSDesignId id) =>
      profiles.firstWhere((profile) => profile.id == id);
}
