import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/audio_player_widget.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../comments/presentation/bloc/comment_bloc.dart';
import '../../../comments/presentation/widgets/comments_section.dart';
import '../../domain/entities/alert_entity.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import '../bloc/alert_state.dart';

class AlertDetailSheet extends StatelessWidget {
  final AlertEntity alert;

  const AlertDetailSheet({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header with danger type icon and title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Danger type icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.getAlertLevelColor(alert.level)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      alert.dangerType.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Title and level
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.getAlertLevelColor(alert.level),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Level ${alert.level}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              alert.dangerType.displayName,
                              style: const TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Share button
                  IconButton(
                    onPressed: () => _shareAlert(context),
                    icon: const Icon(Icons.share),
                    tooltip: 'Share alert',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Time
              _buildInfoRow(
                Icons.access_time,
                'Time',
                alert.createdAt.timeAgo(),
              ),
              const SizedBox(height: 12),

              // Location
              _buildInfoRow(
                Icons.location_on,
                'Location',
                '${alert.neighborhood}, ${alert.city}, ${alert.region}',
              ),
              if (alert.address != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Text(
                    alert.address!,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Creator
              _buildInfoRow(
                Icons.person,
                'Reported by',
                alert.creatorName,
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                alert.description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Audio playback if available
              if (alert.audioCommentUrl != null) ...[
                AudioPlayerWidget(
                  audioUrl: alert.audioCommentUrl!,
                  isNetworkFile: true,
                ),
                const SizedBox(height: 16),
              ],

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.visibility,
                      alert.viewCount.toString(),
                      'Views',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      Icons.verified,
                      alert.confirmations.toString(),
                      'Confirmations',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      Icons.volunteer_activism,
                      alert.helpOffered.toString(),
                      'Help Offered',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor().withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status: ${alert.status.toString().split('.').last.toUpperCase()}',
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons
              BlocListener<AlertBloc, AlertState>(
                listener: (context, state) {
                  if (state is HelpOffered) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.accentColor,
                      ),
                    );
                    Navigator.pop(context);
                  } else if (state is AlertConfirmed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.accentColor,
                      ),
                    );
                    Navigator.pop(context);
                  } else if (state is AlertMarkedAsResolved) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.accentColor,
                      ),
                    );
                    Navigator.pop(context);
                  } else if (state is FalseAlarmReported) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.warningColor,
                      ),
                    );
                    Navigator.pop(context);
                  } else if (state is AlertError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showConfirmDialog(context),
                            icon: const Icon(Icons.verified_outlined),
                            label: const Text('Confirm'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showOfferHelpDialog(context),
                            icon: const Icon(Icons.volunteer_activism),
                            label: const Text('Offer Help'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: alert.status == AlertStatus.active
                                ? () => _showMarkResolvedDialog(context)
                                : null,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Mark Resolved'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: alert.status == AlertStatus.active
                                ? () => _showReportFalseAlarmDialog(context)
                                : null,
                            icon: const Icon(Icons.flag_outlined),
                            label: const Text('False Alarm'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Comments section
              const Divider(height: 32),
              BlocProvider(
                create: (context) => di.sl<CommentBloc>(),
                child: CommentsSection(alertId: alert.alertId),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmDialog(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to confirm alerts')),
      );
      return;
    }

    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Alert'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(
            labelText: 'Comment (optional)',
            hintText: 'Add details about what you observed...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AlertBloc>().add(ConfirmAlertRequested(
                    alertId: alert.alertId,
                    userId: authState.user.uid,
                    userName: authState.user.displayName,
                    comment: commentController.text.trim().isEmpty
                        ? null
                        : commentController.text.trim(),
                  ));
              Navigator.pop(dialogContext);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showOfferHelpDialog(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to offer help')),
      );
      return;
    }

    String selectedHelpType = 'transportation';
    final descriptionController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Offer Help'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Type of help:'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedHelpType,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'transportation', child: Text('Transportation')),
                    DropdownMenuItem(value: 'medical', child: Text('Medical Assistance')),
                    DropdownMenuItem(value: 'shelter', child: Text('Shelter')),
                    DropdownMenuItem(value: 'food', child: Text('Food/Water')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedHelpType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Describe how you can help...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number (optional)',
                    hintText: 'Your phone number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AlertBloc>().add(OfferHelpRequested(
                      alertId: alert.alertId,
                      userId: authState.user.uid,
                      userName: authState.user.displayName,
                      helpType: selectedHelpType,
                      description: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                      phoneNumber: phoneController.text.trim().isEmpty
                          ? null
                          : phoneController.text.trim(),
                    ));
                Navigator.pop(dialogContext);
              },
              child: const Text('Offer Help'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkResolvedDialog(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to mark alerts as resolved')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mark as Resolved'),
        content: const Text(
          'Are you sure you want to mark this alert as resolved? This action indicates that the situation is no longer a threat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AlertBloc>().add(MarkAlertAsResolvedRequested(
                    alertId: alert.alertId,
                    userId: authState.user.uid,
                  ));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text('Mark Resolved'),
          ),
        ],
      ),
    );
  }

  void _showReportFalseAlarmDialog(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to report false alarms')),
      );
      return;
    }

    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report False Alarm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a reason for reporting this as a false alarm:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Explain why this is a false alarm...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }
              context.read<AlertBloc>().add(ReportFalseAlarmRequested(
                    alertId: alert.alertId,
                    userId: authState.user.uid,
                    reason: reasonController.text.trim(),
                  ));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (alert.status) {
      case AlertStatus.active:
        return AppTheme.primaryColor;
      case AlertStatus.resolved:
        return AppTheme.accentColor;
      case AlertStatus.falseAlarm:
        return AppTheme.textSecondaryColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  IconData _getStatusIcon() {
    switch (alert.status) {
      case AlertStatus.active:
        return Icons.warning_amber_rounded;
      case AlertStatus.resolved:
        return Icons.check_circle;
      case AlertStatus.falseAlarm:
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _shareAlert(BuildContext context) {
    final String shareText = '''
🚨 Safety Alert - Cameroon

${alert.dangerType.icon} ${alert.title}
Level: ${alert.level}/5
Type: ${alert.dangerType.displayName}

📍 Location: ${alert.neighborhood}, ${alert.city}, ${alert.region}

📝 Description:
${alert.description}

⏰ Time: ${alert.createdAt.timeAgo()}
👤 Reported by: ${alert.creatorName}

📊 Stats:
✓ ${alert.confirmations} confirmations
👁 ${alert.viewCount} views
🤝 ${alert.helpOffered} help offers

Status: ${alert.status.toString().split('.').last.toUpperCase()}

Stay safe and stay informed!
''';

    Share.share(
      shareText,
      subject: '🚨 Safety Alert: ${alert.title}',
    );
  }
}
