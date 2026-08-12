import 'package:flutter/material.dart';

/// The five permanent LifeOS cores.
/// IDs are stable because the home screen stores/routes by index.
enum LifeOSCore { money, goals, productivity, household, calendar }

class LifeOSCoreDefinition {
  final LifeOSCore core;
  final IconData icon;
  final String title;
  final String description;

  const LifeOSCoreDefinition({
    required this.core,
    required this.icon,
    required this.title,
    required this.description,
  });

  int get index => core.index;
}

const lifeOsCores = <LifeOSCoreDefinition>[
  LifeOSCoreDefinition(
    core: LifeOSCore.money,
    icon: Icons.account_balance_wallet_outlined,
    title: 'Money',
    description: 'Expenses, income, investments and financial intelligence.',
  ),
  LifeOSCoreDefinition(
    core: LifeOSCore.goals,
    icon: Icons.auto_awesome_outlined,
    title: 'Goals',
    description: 'Goals, progress, planning and future projections.',
  ),
  LifeOSCoreDefinition(
    core: LifeOSCore.productivity,
    icon: Icons.bolt_outlined,
    title: 'Productivity',
    description: 'Home and work tasks with progress and carry-forward.',
  ),
  LifeOSCoreDefinition(
    core: LifeOSCore.household,
    icon: Icons.home_work_outlined,
    title: 'Household',
    description: 'Shopping, recurring requirements and receipt intelligence.',
  ),
  LifeOSCoreDefinition(
    core: LifeOSCore.calendar,
    icon: Icons.calendar_month_outlined,
    title: 'Calendar',
    description: 'Bills, renewals, appointments and important life dates.',
  ),
];

LifeOSCoreDefinition coreByIndex(int index) {
  if (index < 0 || index >= lifeOsCores.length) return lifeOsCores.first;
  return lifeOsCores[index];
}
