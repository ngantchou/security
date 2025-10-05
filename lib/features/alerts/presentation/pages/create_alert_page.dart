import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/audio_recorder_widget.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/offline/offline_storage_service.dart';
import '../../../../core/offline/models/offline_alert_model.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import '../bloc/alert_state.dart';

class CreateAlertPage extends StatefulWidget {
  const CreateAlertPage({super.key});

  @override
  State<CreateAlertPage> createState() => _CreateAlertPageState();
}

class _CreateAlertPageState extends State<CreateAlertPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _regionController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _addressController = TextEditingController();

  DangerType _selectedDangerType = DangerType.other;
  int _alertLevel = 3;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String? _audioPath;
  bool _isUploadingAudio = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check permission
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

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        return;
      }

      // Get position
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
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

  Future<void> _submitAlert() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location is required. Please wait...'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be signed in to create an alert'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    // Upload audio if recorded
    String? audioUrl;
    if (_audioPath != null) {
      try {
        setState(() => _isUploadingAudio = true);

        final storageService = di.sl<StorageService>();
        audioUrl = await storageService.uploadAudioFile(
          filePath: _audioPath!,
          userId: authState.user.uid,
        );

        setState(() => _isUploadingAudio = false);
      } catch (e) {
        setState(() => _isUploadingAudio = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload audio: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        return;
      }
    }

    if (!mounted) return;

    // Check network connectivity
    final networkInfo = di.sl<NetworkInfo>();
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      // Save for offline sync
      final offlineStorage = di.sl<OfflineStorageService>();
      final offlineAlert = OfflineAlertModel(
        localId: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dangerType: _selectedDangerType.toString().split('.').last,
        level: _alertLevel,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        neighborhood: _neighborhoodController.text.isEmpty
            ? null
            : _neighborhoodController.text.trim(),
        city: _cityController.text.isEmpty ? null : _cityController.text.trim(),
        region:
            _regionController.text.isEmpty ? null : _regionController.text.trim(),
        audioCommentUrl: _audioPath, // Store local path for later upload
        userId: authState.user.uid,
        userName: authState.user.displayName,
        createdAt: DateTime.now(),
      );

      await offlineStorage.savePendingAlert(offlineAlert);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '📴 Offline: Alert saved and will be submitted when online',
            ),
            backgroundColor: AppTheme.warningColor,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    // Online mode - create alert normally
    if (!mounted) return;

    context.read<AlertBloc>().add(CreateAlertRequested(
          creatorId: authState.user.uid,
          creatorName: authState.user.displayName,
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          dangerType: _selectedDangerType.toString().split('.').last,
          level: _alertLevel,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          audioCommentUrl: audioUrl,
          region: _regionController.text.trim(),
          city: _cityController.text.trim(),
          neighborhood: _neighborhoodController.text.trim(),
          address: _addressController.text.isEmpty
              ? null
              : _addressController.text.trim(),
        ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _regionController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AlertBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Alert'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<AlertBloc, AlertState>(
          listener: (context, state) {
            if (state is AlertCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alert created successfully!'),
                  backgroundColor: AppTheme.accentColor,
                ),
              );
              Navigator.pop(context, state.alert);
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
            final isCreating = state is AlertCreating;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Location Status
                    Card(
                      color: _currentPosition != null
                          ? AppTheme.accentColor.withOpacity(0.1)
                          : AppTheme.warningColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              _currentPosition != null
                                  ? Icons.location_on
                                  : Icons.location_off,
                              color: _currentPosition != null
                                  ? AppTheme.accentColor
                                  : AppTheme.warningColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _isLoadingLocation
                                    ? 'Getting your location...'
                                    : _currentPosition != null
                                        ? 'Location detected: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}'
                                        : 'Location not available',
                                style: TextStyle(
                                  color: _currentPosition != null
                                      ? AppTheme.accentColor
                                      : AppTheme.warningColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (!_isLoadingLocation && _currentPosition == null)
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: _getCurrentLocation,
                                color: AppTheme.warningColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Danger Type
                    Text(
                      'Danger Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<DangerType>(
                      initialValue: _selectedDangerType,
                      decoration: InputDecoration(
                        hintText: 'Select danger type',
                        prefixIcon: Icon(
                          Icons.warning_rounded,
                          color: AppTheme.dangerTypeColors[
                                  _selectedDangerType
                                      .toString()
                                      .split('.')
                                      .last] ??
                              AppTheme.textSecondaryColor,
                        ),
                      ),
                      items: DangerType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Text(
                                type.icon,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(type.localizedName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedDangerType = value);
                        }
                      },
                      validator: (value) =>
                          value == null ? 'Please select a danger type' : null,
                    ),
                    const SizedBox(height: 20),

                    // Alert Level
                    Text(
                      'Alert Level: $_alertLevel',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _alertLevel.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            activeColor: AppTheme.getAlertLevelColor(_alertLevel),
                            label: 'Level $_alertLevel',
                            onChanged: (value) {
                              setState(() => _alertLevel = value.toInt());
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.getAlertLevelColor(_alertLevel),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'L$_alertLevel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Alert Title',
                        hintText: 'Brief description of the danger',
                        prefixIcon: Icon(Icons.title),
                      ),
                      maxLength: 100,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        if (value.trim().length < 5) {
                          return 'Title must be at least 5 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Detailed information about the danger',
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      maxLength: 500,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }
                        if (value.trim().length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Region
                    TextFormField(
                      controller: _regionController,
                      decoration: const InputDecoration(
                        labelText: 'Region',
                        hintText: 'e.g., Littoral, Centre, Southwest',
                        prefixIcon: Icon(Icons.map),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Region is required'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // City
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        hintText: 'e.g., Douala, Yaoundé, Bamenda',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'City is required'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Neighborhood
                    TextFormField(
                      controller: _neighborhoodController,
                      decoration: const InputDecoration(
                        labelText: 'Neighborhood/Quarter',
                        hintText: 'e.g., Bonaberi, Bastos',
                        prefixIcon: Icon(Icons.home),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Neighborhood is required'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Address (Optional)
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address (Optional)',
                        hintText: 'Specific address or landmark',
                        prefixIcon: Icon(Icons.place),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Audio Recording (Optional)
                    const Text(
                      'Voice Note (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AudioRecorderWidget(
                      onRecordingComplete: (audioPath) {
                        setState(() {
                          _audioPath = audioPath;
                        });
                      },
                      maxDurationSeconds: 120,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: (isCreating || _isUploadingAudio) ? null : _submitAlert,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: _isUploadingAudio
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Uploading Audio...'),
                              ],
                            )
                          : isCreating
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Creating Alert...'),
                                  ],
                                )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.emergency),
                                SizedBox(width: 8),
                                Text('Create Alert'),
                              ],
                            ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
