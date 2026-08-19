/// Shared routing contract for the five intelligent LifeOS cores.
/// Keeps business capabilities independent from the future 3D presentation.
enum LifeOsCore {
  expenses,
  goals,
  productivity,
  household,
  calendar,
}

class LifeOsCoreRoute {
  final LifeOsCore core;
  final String title;
  final String subtitle;

  const LifeOsCoreRoute({
    required this.core,
    required this.title,
    required this.subtitle,
  });
}

const lifeOsCoreRoutes = <LifeOsCoreRoute>[
  LifeOsCoreRoute(core: LifeOsCore.expenses, title: 'Expenses', subtitle: 'Money, spending and saving intelligence'),
  LifeOsCoreRoute(core: LifeOsCore.goals, title: 'Goals', subtitle: 'Targets, progress and next actions'),
  LifeOsCoreRoute(core: LifeOsCore.productivity, title: 'Productivity', subtitle: 'Tasks, completion and carry-forward'),
  LifeOsCoreRoute(core: LifeOsCore.household, title: 'Household', subtitle: 'Shopping and daily requirements'),
  LifeOsCoreRoute(core: LifeOsCore.calendar, title: 'Calendar', subtitle: 'Bills, renewals and important dates'),
];

class LifeOsCoreRouter {
  const LifeOsCoreRouter();

  LifeOsCoreRoute routeFor(LifeOsCore core) =>
      lifeOsCoreRoutes.firstWhere((route) => route.core == core);
}
