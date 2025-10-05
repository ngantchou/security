import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/emergency_beacon.dart';
import 'core/services/notification_service.dart';
import 'core/offline/offline_storage_service.dart';
import 'core/offline/sync_service.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/phone_auth_page.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable offline persistence for Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize dependency injection
  await di.init();

  // Initialize offline storage
  final offlineStorage = di.sl<OfflineStorageService>();
  await offlineStorage.initialize();

  // Initialize notifications
  final notificationService = di.sl<NotificationService>();
  await notificationService.initialize();

  // Start sync service
  final syncService = di.sl<SyncService>();
  syncService.startListening();

  runApp(const SafetyAlertApp());
}

class SafetyAlertApp extends StatelessWidget {
  const SafetyAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>()..add(AppStarted()),
      child: MaterialApp(
        title: 'Safety Alert',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // Routes
        routes: {
          '/home': (context) => BlocProvider.value(
                value: context.read<AuthBloc>(),
                child: const HomePage(),
              ),
        },

        // Home screen with auth check
        home: const AuthWrapper(),
      ),
    );
  }
}

// Auth Wrapper to handle authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const SplashScreen();
        } else if (state is Authenticated || state is GuestMode) {
          return const HomePage();
        } else {
          return const PhoneAuthPage();
        }
      },
    );
  }
}

// Splash screen with emergency beacon animation
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Emergency Beacon
            Stack(
              alignment: Alignment.center,
              children: [
                const RippleAnimation(
                  color: Colors.white,
                  size: 200,
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const PulsingAlert(
                    child: Icon(
                      Icons.emergency,
                      size: 80,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // App Name with fade animation
            const Text(
              'Safety Alert',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle
            const Text(
              'Community Safety Network',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 50),

            // Loading indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Version/Status
            const Text(
              'Version 1.0.0\nInitializing...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
