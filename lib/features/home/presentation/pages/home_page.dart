import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/offline_indicator.dart';
import '../../../../core/services/data_seed_service.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../alerts/presentation/pages/create_alert_page.dart';
import '../../../alerts/presentation/pages/map_view_page.dart';
import '../../../alerts/presentation/pages/alerts_list_page.dart';
import '../../../alerts/presentation/bloc/alert_bloc.dart';
import '../../../verification/presentation/pages/user_profile_page.dart';
import '../../../groups/presentation/pages/news_feed_page.dart';
import '../../../settings/presentation/pages/notification_settings_page.dart';
import '../../../neighborhood_watch/presentation/bloc/watch_group_bloc.dart';
import '../../../neighborhood_watch/presentation/pages/watch_groups_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final bool isGuest = state is GuestMode;
        final user = state is Authenticated ? state.user : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(isGuest ? 'Safety Alert - Visitor' : 'Safety Alert'),
            actions: [
              const OfflineIndicator(),
              if (!isGuest)
                IconButton(
                  icon: const Icon(Icons.feed),
                  tooltip: 'News Feed',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewsFeedPage(),
                      ),
                    );
                  },
                ),
              IconButton(
                icon: const Icon(Icons.notifications),
                tooltip: 'Notification Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsPage(),
                    ),
                  );
                },
              ),
              if (!isGuest)
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfilePage(),
                      ),
                    );
                  },
                ),
              if (isGuest)
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                )
              else
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthBloc>().add(SignOutRequested());
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                // App Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.emergency,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // Welcome Message
                Text(
                  isGuest ? 'Welcome, Visitor!' : 'Welcome!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),

                if (isGuest)
                  Text(
                    'Browsing in visitor mode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.warningColor,
                          fontWeight: FontWeight.w500,
                        ),
                  )
                else if (user != null) ...[
                  Text(
                    user.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.phoneNumber,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                  ),
                ],
                const SizedBox(height: 40),

                // Seed Database Card (Dev Only)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.science,
                        color: Colors.orange,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Development Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Populate database with sample data for testing',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showSeedDataDialog(context),
                        icon: const Icon(Icons.api),
                        label: const Text('Seed Database'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Quick Actions (Placeholder)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isGuest
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please sign in to create alerts'),
                                    backgroundColor: AppTheme.warningColor,
                                  ),
                                );
                              }
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateAlertPage(),
                                  ),
                                );
                              },
                        icon: Icon(isGuest ? Icons.lock_outline : Icons.add_alert),
                        label: const Text('Create Alert'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isGuest
                              ? AppTheme.textSecondaryColor
                              : AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                      create: (_) => di.sl<AlertBloc>(),
                                      child: const MapViewPage(),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.map_outlined),
                              label: const Text('Map View'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                      create: (_) => di.sl<AlertBloc>(),
                                      child: const AlertsListPage(),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.list),
                              label: const Text('List View'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (_) => di.sl<WatchGroupBloc>(),
                                child: const WatchGroupsPage(),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shield),
                        label: const Text('Neighborhood Watch'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  void _showSeedDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Seed Database'),
        content: const Text(
          'This will populate your database with sample data:\n\n'
          '• 5 sample users\n'
          '• 15 alerts\n'
          '• 2 watch groups\n'
          '• 2 hospitals\n'
          '• 3 blood donors\n'
          '• 1 NGO\n'
          '• 2 emergency resources\n'
          '• 1 community fund\n\n'
          'This is for development/testing only!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              _seedData(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Seed Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _seedData(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Seeding database...'),
          ],
        ),
      ),
    );

    try {
      final seedService = DataSeedService(FirebaseFirestore.instance);
      await seedService.seedAllData();

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Database seeded successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error seeding database: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
