import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import '../bloc/alert_state.dart';
import '../widgets/alert_card.dart';
import '../widgets/alert_detail_sheet.dart';
import 'map_view_page.dart';

class AlertsListPage extends StatefulWidget {
  const AlertsListPage({super.key});

  @override
  State<AlertsListPage> createState() => _AlertsListPageState();
}

class _AlertsListPageState extends State<AlertsListPage> {
  Position? _currentPosition;
  double _currentRadius = 10.0;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);

      if (mounted) {
        context.read<AlertBloc>().add(LoadNearbyAlerts(
              latitude: position.latitude,
              longitude: position.longitude,
              radiusInKm: _currentRadius,
            ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _refreshAlerts() async {
    if (_currentPosition != null) {
      context.read<AlertBloc>().add(LoadNearbyAlerts(
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            radiusInKm: _currentRadius,
          ));
    } else {
      await _loadAlerts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: BlocConsumer<AlertBloc, AlertState>(
        listener: (context, state) {
          if (state is AlertError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AlertLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading alerts...'),
                ],
              ),
            );
          }

          if (state is AlertEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: AppTheme.textSecondaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _refreshAlerts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          if (state is AlertsLoaded) {
            return RefreshIndicator(
              onRefresh: _refreshAlerts,
              child: Column(
                children: [
                  // Stats header
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppTheme.backgroundColor,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${state.alerts.length} alert${state.alerts.length != 1 ? 's' : ''} nearby',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Within ${_currentRadius.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Alerts list
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.alerts.length,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemBuilder: (context, index) {
                        final alert = state.alerts[index];
                        return AlertCard(
                          alert: alert,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  AlertDetailSheet(alert: alert),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          // Initial state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Getting your location...'),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _loadAlerts,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: context.read<AlertBloc>(),
                child: const MapViewPage(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.map),
        label: const Text('Map View'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showFilterDialog() {
    double tempRadius = _currentRadius;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Alerts'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search Radius',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${tempRadius.toStringAsFixed(1)} km',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Slider(
                  value: tempRadius,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  label: '${tempRadius.toStringAsFixed(1)} km',
                  onChanged: (value) {
                    setDialogState(() => tempRadius = value);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _currentRadius = tempRadius);
              Navigator.pop(context);
              _refreshAlerts();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
