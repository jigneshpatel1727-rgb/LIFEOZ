import 'package:flutter/material.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LifeOS Permissions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF082B3A),
                  Color(0xFF07351F),
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.security,
                  size: 34,
                ),
                SizedBox(height: 12),
                Text(
                  'Your data. Your control.',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'LifeOS only uses information when '
                  'you give permission. If permission is '
                  'denied, you can always enter information manually.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Data Access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _PermissionCard(
            icon: Icons.sms_outlined,
            title: 'Messages',
            description:
                'Detect expenses and financial information from permitted messages.',
            status: 'Not configured',
            onPressed: () {
              _showComingSoon(
                context,
                'Message access',
              );
            },
          ),

          _PermissionCard(
            icon: Icons.phone_outlined,
            title: 'Calls',
            description:
                'Use permitted call information for LifeOS activity tracking.',
            status: 'Not configured',
            onPressed: () {
              _showComingSoon(
                context,
                'Call access',
              );
            },
          ),

          _PermissionCard(
            icon: Icons.calendar_month_outlined,
            title: 'Calendar',
            description:
                'Help LifeOS understand upcoming events and commitments.',
            status: 'Not configured',
            onPressed: () {
              _showComingSoon(
                context,
                'Calendar access',
              );
            },
          ),

          _PermissionCard(
            icon: Icons.location_on_outlined,
            title: 'Location',
            description:
                'Use location when a LifeOS feature specifically needs it.',
            status: 'Not configured',
            onPressed: () {
              _showComingSoon(
                context,
                'Location access',
              );
            },
          ),

          _PermissionCard(
            icon: Icons.favorite_outline,
            title: 'Health & Fitness',
            description:
                'Connect supported fitness and health data when available.',
            status: 'Not configured',
            onPressed: () {
              _showComingSoon(
                context,
                'Health & fitness access',
              );
            },
          ),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.edit_note,
                    size: 30,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Manual entry is always available',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'If you deny a permission, LifeOS will '
                          'not block you. You can continue adding '
                          'expenses and other information manually.',
                          style: TextStyle(
                            color:
                                Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showComingSoon(
    BuildContext context,
    String feature,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(feature),
          content: const Text(
            'The Android permission integration will be '
            'enabled in the next step. LifeOS will request '
            'only the permission required for this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String status;
  final VoidCallback onPressed;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  child: Icon(icon),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 9,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onPressed,
                child: const Text(
                  'Grant Permission',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
