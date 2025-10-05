import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/alert_entity.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import '../bloc/alert_state.dart';
import '../widgets/alert_detail_sheet.dart';
import 'alerts_list_page.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({super.key});

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  double _currentRadius = 5.0; // Default 5km radius
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  // Default camera position (Cameroon - Douala)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(4.0511, 9.7679), // Douala, Cameroon
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);

      // Move camera to user location
      final controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14,
          ),
        ),
      );

      // Load nearby alerts
      if (mounted) {
        context.read<AlertBloc>().add(WatchNearbyAlertsStarted(
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
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _updateMarkers(List<AlertEntity> alerts) {
    final markers = <Marker>{};

    // Add user location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Add alert markers
    for (final alert in alerts) {
      markers.add(
        Marker(
          markerId: MarkerId(alert.alertId),
          position: LatLng(
            alert.location.latitude,
            alert.location.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerHue(alert.level),
          ),
          infoWindow: InfoWindow(
            title: '${alert.dangerType.icon} ${alert.title}',
            snippet: 'Level ${alert.level} • ${alert.city}',
          ),
          onTap: () => _showAlertDetail(alert),
        ),
      );
    }

    // Add radius circle
    if (_currentPosition != null) {
      _circles = {
        Circle(
          circleId: const CircleId('search_radius'),
          center: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          radius: _currentRadius * 1000, // Convert km to meters
          strokeWidth: 2,
          strokeColor: AppTheme.primaryColor.withOpacity(0.5),
          fillColor: AppTheme.primaryColor.withOpacity(0.1),
        ),
      };
    }

    setState(() => _markers = markers);
  }

  double _getMarkerHue(int level) {
    switch (level) {
      case 1:
        return BitmapDescriptor.hueGreen;
      case 2:
        return BitmapDescriptor.hueYellow;
      case 3:
        return BitmapDescriptor.hueOrange;
      case 4:
        return 15.0; // Red-Orange
      case 5:
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _showAlertDetail(AlertEntity alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AlertDetailSheet(alert: alert),
    );
  }

  void _changeRadius(double newRadius) {
    setState(() => _currentRadius = newRadius);

    if (_currentPosition != null) {
      context.read<AlertBloc>().add(WatchNearbyAlertsStarted(
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            radiusInKm: newRadius,
          ));
    }
  }

  @override
  void dispose() {
    context.read<AlertBloc>().add(const WatchNearbyAlertsStopped());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _isLoadingLocation ? null : _getCurrentLocation,
            tooltip: 'My Location',
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showRadiusDialog(),
            tooltip: 'Adjust Radius',
          ),
        ],
      ),
      body: BlocConsumer<AlertBloc, AlertState>(
        listener: (context, state) {
          if (state is AlertsLoaded) {
            _updateMarkers(state.alerts);
          } else if (state is AlertEmpty) {
            setState(() => _markers = _markers.where((m) => m.markerId.value == 'user_location').toSet());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No alerts found in this area'),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is AlertError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: _initialPosition,
                onMapCreated: (controller) {
                  _mapController.complete(controller);
                },
                markers: _markers,
                circles: _circles,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                compassEnabled: true,
                zoomControlsEnabled: false,
              ),

              // Loading indicator
              if (state is AlertLoading || _isLoadingLocation)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading alerts...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Alert count badge
              if (state is AlertsLoaded)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${state.alerts.length} alert${state.alerts.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Radius info
              Positioned(
                top: 16,
                right: 16,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      'Radius: ${_currentRadius.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Stop watching alerts before navigating
          context.read<AlertBloc>().add(const WatchNearbyAlertsStopped());

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: context.read<AlertBloc>(),
                child: const AlertsListPage(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.list),
        label: const Text('List View'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showRadiusDialog() {
    double tempRadius = _currentRadius;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Search Radius'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                const SizedBox(height: 8),
                const Text(
                  '1 km - 50 km',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
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
              _changeRadius(tempRadius);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
