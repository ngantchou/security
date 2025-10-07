import 'package:flutter/material.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../injection_container.dart' as di;

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late NotificationService _notificationService;
  bool _notificationsEnabled = true;
  bool _dndMode = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _notificationRadius = 5.0;
  final Map<DangerType, bool> _dangerTypePreferences = {};

  @override
  void initState() {
    super.initState();
    _notificationService = di.sl<NotificationService>();
    _loadPreferences();
  }

  void _loadPreferences() {
    setState(() {
      _notificationsEnabled = _notificationService.isNotificationEnabled();
      _dndMode = _notificationService.isDndModeEnabled();
      _soundEnabled = _notificationService.isSoundEnabled();
      _vibrationEnabled = _notificationService.isVibrationEnabled();
      _notificationRadius = _notificationService.getNotificationRadius();

      // Load danger type preferences
      for (final dangerType in DangerType.values) {
        _dangerTypePreferences[dangerType] =
            _notificationService.isDangerTypeEnabled(
          dangerType.toString().split('.').last,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Master Switch
          Card(
            child: SwitchListTile(
              title: const Text(
                'Enable Notifications',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Receive alerts for nearby dangers'),
              value: _notificationsEnabled,
              onChanged: (value) async {
                await _notificationService.setNotificationEnabled(value);
                setState(() => _notificationsEnabled = value);
              },
              activeThumbColor: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Do Not Disturb
          Card(
            child: SwitchListTile(
              title: const Text('Do Not Disturb'),
              subtitle: const Text('Mute all alert notifications'),
              value: _dndMode,
              onChanged: _notificationsEnabled
                  ? (value) async {
                      await _notificationService.setDndMode(value);
                      setState(() => _dndMode = value);
                    }
                  : null,
              activeThumbColor: AppTheme.warningColor,
            ),
          ),
          const SizedBox(height: 24),

          // Notification Radius
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notification Radius',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_notificationRadius.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Receive notifications for alerts within this distance',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _notificationRadius,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    label: '${_notificationRadius.toStringAsFixed(1)} km',
                    onChanged: _notificationsEnabled
                        ? (value) {
                            setState(() => _notificationRadius = value);
                          }
                        : null,
                    onChangeEnd: (value) async {
                      await _notificationService.setNotificationRadius(value);
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sound & Vibration
          const Text(
            'Alert Behavior',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sound'),
                  subtitle: const Text('Play sound for notifications'),
                  value: _soundEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) async {
                          await _notificationService.setSoundEnabled(value);
                          setState(() => _soundEnabled = value);
                        }
                      : null,
                  activeThumbColor: AppTheme.primaryColor,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Vibration'),
                  subtitle: const Text('Vibrate for notifications'),
                  value: _vibrationEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) async {
                          await _notificationService.setVibrationEnabled(value);
                          setState(() => _vibrationEnabled = value);
                        }
                      : null,
                  activeThumbColor: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Danger Type Preferences
          const Text(
            'Alert Types',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select which types of alerts you want to receive',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: DangerType.values.map((dangerType) {
                return Column(
                  children: [
                    SwitchListTile(
                      title: Row(
                        children: [
                          Text(
                            dangerType.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(dangerType.displayName),
                        ],
                      ),
                      value: _dangerTypePreferences[dangerType] ?? true,
                      onChanged: _notificationsEnabled
                          ? (value) async {
                              await _notificationService.setDangerTypeEnabled(
                                dangerType.toString().split('.').last,
                                value,
                              );
                              setState(() {
                                _dangerTypePreferences[dangerType] = value;
                              });
                            }
                          : null,
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                    if (dangerType != DangerType.values.last)
                      const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Test Notification
          OutlinedButton.icon(
            onPressed: _notificationsEnabled
                ? () async {
                    await _showTestNotification();
                  }
                : null,
            icon: const Icon(Icons.notifications_active),
            label: const Text('Test Notification'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTestNotification() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent!'),
        duration: Duration(seconds: 2),
      ),
    );

    // Show a test notification
    // This would normally go through the notification service
    // For now, we'll just show the snackbar
  }
}
