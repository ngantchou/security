import 'package:flutter/material.dart';
import '../network/network_info.dart';
import '../offline/offline_storage_service.dart';
import '../theme/app_theme.dart';
import '../../injection_container.dart' as di;

class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  bool _isOffline = false;
  int _pendingAlertsCount = 0;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _listenToConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final networkInfo = di.sl<NetworkInfo>();
    final isConnected = await networkInfo.isConnected;

    final offlineStorage = di.sl<OfflineStorageService>();
    final pendingCount = offlineStorage.getPendingAlertsCount();

    if (mounted) {
      setState(() {
        _isOffline = !isConnected;
        _pendingAlertsCount = pendingCount;
      });
    }
  }

  void _listenToConnectivity() {
    final networkInfo = di.sl<NetworkInfo>();
    networkInfo.onConnectivityChanged.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isOffline = !isConnected;
        });
        _checkConnectivity(); // Update pending count
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline && _pendingAlertsCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isOffline
            ? AppTheme.warningColor.withOpacity(0.9)
            : AppTheme.accentColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOffline ? Icons.cloud_off : Icons.sync,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            _isOffline
                ? 'Offline'
                : _pendingAlertsCount > 0
                    ? '$_pendingAlertsCount pending'
                    : '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
