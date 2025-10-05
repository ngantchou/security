import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/watch_group_bloc.dart';
import '../bloc/watch_group_event.dart';
import '../bloc/watch_group_state.dart';

class CreateWatchGroupPage extends StatefulWidget {
  const CreateWatchGroupPage({super.key});

  @override
  State<CreateWatchGroupPage> createState() => _CreateWatchGroupPageState();
}

class _CreateWatchGroupPageState extends State<CreateWatchGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _regionController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPrivate = false;
  bool _requireApproval = true;
  double _radiusKm = 2.0;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _regionController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    final position = await Geolocator.getCurrentPosition();

    if (mounted) {
      context.read<WatchGroupBloc>().add(
            CreateWatchGroupRequested(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              region: _regionController.text.trim(),
              city: _cityController.text.trim(),
              neighborhood: _neighborhoodController.text.trim(),
              coordinatorId: authState.user.uid,
              coordinatorName: authState.user.displayName,
              coordinatorPhoto: authState.user.profilePhoto,
              coordinatorPhone: _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              latitude: position.latitude,
              longitude: position.longitude,
              radiusKm: _radiusKm,
              isPrivate: _isPrivate,
              requireApproval: _requireApproval,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Watch Group')),
      body: BlocListener<WatchGroupBloc, WatchGroupState>(
        listener: (context, state) {
          if (state is WatchGroupCreated) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Group created successfully!')),
            );
          }
          if (state is WatchGroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regionController,
                decoration: const InputDecoration(
                  labelText: 'Region *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _neighborhoodController,
                decoration: const InputDecoration(
                  labelText: 'Neighborhood *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Text('Coverage Radius: ${_radiusKm.toStringAsFixed(1)} km'),
              Slider(
                value: _radiusKm,
                min: 0.5,
                max: 10.0,
                divisions: 19,
                onChanged: (v) => setState(() => _radiusKm = v),
              ),
              SwitchListTile(
                title: const Text('Private Group'),
                subtitle: const Text('Only invited members can see'),
                value: _isPrivate,
                onChanged: (v) => setState(() => _isPrivate = v),
              ),
              SwitchListTile(
                title: const Text('Require Approval'),
                subtitle: const Text('Coordinator must approve new members'),
                value: _requireApproval,
                onChanged: (v) => setState(() => _requireApproval = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createGroup,
                child: const Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
