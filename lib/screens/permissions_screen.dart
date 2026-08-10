import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  PermissionStatus _messagesStatus = PermissionStatus.denied;
  PermissionStatus _callsStatus = PermissionStatus.denied;
  PermissionStatus _calendarStatus = PermissionStatus.denied;
  PermissionStatus _locationStatus = PermissionStatus.denied;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    final messages = await Permission.sms.status;
    final calls = await Permission.phone.status;
    final calendar = await Permission.calendar.status;
    final location = await Permission.locationWhenInUse.status;

    if (!mounted) return;

    setState(() {
      _messagesStatus = messages;
      _callsStatus = calls;
      _calendarStatus = calendar;
      _locationStatus = location;
      _loading = false;
    });
  }

  Future<void> _requestPermission(
    BuildContext context,
    String title,
    Permission permission,
  ) async {
    final result = await permission.request();

    if (!mounted) return;

    setState(() {
      if (permission == Permission.sms) {
        _messagesStatus = result;
      } else if (permission == Permission.phone) {
        _callsStatus = result;
      } else if (permission == Permission.calendar) {
        _calendarStatus = result;
      } else if (permission == Permission.locationWhenInUse) {
        _locationStatus = result;
      }
    });

    if (result.isGranted) {
      _showMessage(
        context,
        '$title permission granted.',
        Icons.check_circle,
      );
    } else if (result.isPermanentlyDenied) {
      _showSettingsDialog(context, title);
    } else if (result.isDenied) {
      _showMessage(
        context,
        '$title permission was denied. '
        'You can continue using manual entry.',
        Icons.info_outline,
      );
    }
  }

  Future<void> _showSettingsDialog(
    BuildContext context,
    String title,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$title Permission'),
          content: Text(
            '$title permission has been permanently denied. '
            'You can enable it from Android App Settings.\n\n'
            'LifeOS will continue to work with manual entry if '
            'you choose not to enable it.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Not Now'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(
    BuildContext context,
    String message,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  String _statusText(PermissionStatus status) {
    if (status.isGranted) {
      return 'Granted';
    }

    if (status.isPermanentlyDenied) {
      return 'Blocked';
    }

    if (status.isRestricted) {
      return 'Restricted';
    }

    if (status.isLimited) {
      return 'Limited';
    }

    return 'Not granted';
  }

  Color _statusColor(PermissionStatus status) {
    if (status.isGranted) {
      return Colors.green;
    }

    if (status.isPermanentlyDenied) {
      return Colors.red;
    }

    return Colors.orange;
  }

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
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadPermissionStatus,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadPermissionStatus,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF082B3A),
                          Color(0xFF07351F),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.security,
                          size: 36,
                          color: Colors.white,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Your data. Your control.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'LifeOS only uses information when '
                          'you give permission. If permission is '
                          'denied, you can always enter information manually.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Data Access',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Choose which information LifeOS can access.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _PermissionCard(
                    icon: Icons.sms_outlined,
                    title: 'Messages',
                    description:
                        'Detect expenses and financial information '
                        'from permitted SMS messages.',
                    status: _messagesStatus,
                    statusText: _statusText(_messagesStatus),
                    statusColor: _statusColor(_messagesStatus),
                    onPressed: () {
                      _requestPermission(
                        context,
                        'Messages',
                        Permission.sms,
                      );
                    },
                  ),

                  _PermissionCard(
                    icon: Icons.phone_outlined,
                    title: 'Calls',
                    description:
                        'Use permitted phone information for '
                        'LifeOS activity tracking.',
                    status: _callsStatus,
                    statusText: _statusText(_callsStatus),
                    statusColor: _statusColor(_callsStatus),
                    onPressed: () {
                      _requestPermission(
                        context,
                        'Calls',
                        Permission.phone,
                      );
                    },
                  ),

                  _PermissionCard(
                    icon: Icons.calendar_month_outlined,
                    title: 'Calendar',
                    description:
                        'Help LifeOS understand upcoming events '
                        'and commitments.',
                    status: _calendarStatus,
                    statusText: _statusText(_calendarStatus),
                    statusColor: _statusColor(_calendarStatus),
                    onPressed: () {
                      _requestPermission(
                        context,
                        'Calendar',
                        Permission.calendar,
                      );
                    },
                  ),

                  _PermissionCard(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    description:
                        'Use location when a LifeOS feature '
                        'specifically needs it.',
                    status: _locationStatus,
                    statusText: _statusText(_locationStatus),
                    statusColor: _statusColor(_locationStatus),
                    onPressed: () {
                      _requestPermission(
                        context,
                        'Location',
                        Permission.locationWhenInUse,
                      );
                    },
                  ),

                  _PermissionCard(
                    icon: Icons.favorite_outline,
                    title: 'Health & Fitness',
                    description:
                        'Connect supported fitness and health '
                        'data when available.',
                    status: PermissionStatus.denied,
                    statusText: 'Manual / Future',
                    statusColor: Colors.blue,
                    onPressed: () {
                      _showHealthInfo(context);
                    },
                  ),

                  const SizedBox(height: 12),

                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.edit_note,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
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
                                const SizedBox(height: 7),
                                Text(
                                  'If you deny a permission, LifeOS will '
                                  'not block you. You can continue adding '
                                  'expenses, activities and other information '
                                  'manually.',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.orange.withValues(alpha: 0.10),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'LifeOS should request only the permissions '
                            'needed for features you choose to use. '
                            'Some permissions, especially SMS and call '
                            'access, are subject to Android and app-store policies.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  void _showHealthInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Health & Fitness'),
          content: const Text(
            'Health and fitness integration will be connected '
            'through a supported health platform or fitness device. '
            'Until then, you can enter fitness information manually.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
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
  final PermissionStatus status;
  final String statusText;
  final Color statusColor;
  final VoidCallback onPressed;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.statusText,
    required this.statusColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool granted = status.isGranted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Icon(icon),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            granted
                                ? Icons.check_circle
                                : Icons.circle,
                            size: 11,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            SizedBox(
              width: double.infinity,
              child: granted
                  ? OutlinedButton.icon(
                      onPressed: onPressed,
                      icon: const Icon(Icons.check),
                      label: const Text('Permission Granted'),
                    )
                  : FilledButton.icon(
                      onPressed: onPressed,
                      icon: const Icon(Icons.lock_open),
                      label: Text(
                        status.isPermanentlyDenied
                            ? 'Open Settings'
                            : 'Grant Permission',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
