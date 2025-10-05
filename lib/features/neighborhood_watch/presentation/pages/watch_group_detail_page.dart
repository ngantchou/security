import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/watch_group_bloc.dart';
import '../bloc/watch_group_event.dart';
import '../bloc/watch_group_state.dart';
import '../../domain/entities/watch_group_entity.dart';
import 'members_page.dart';
import 'meetings_page.dart';

class WatchGroupDetailPage extends StatefulWidget {
  final String groupId;

  const WatchGroupDetailPage({super.key, required this.groupId});

  @override
  State<WatchGroupDetailPage> createState() => _WatchGroupDetailPageState();
}

class _WatchGroupDetailPageState extends State<WatchGroupDetailPage> {
  WatchGroupEntity? _group;

  @override
  void initState() {
    super.initState();
    context.read<WatchGroupBloc>().add(LoadGroupMembers(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Details'),
      ),
      body: BlocConsumer<WatchGroupBloc, WatchGroupState>(
        listener: (context, state) {
          if (state is WatchGroupJoined) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<WatchGroupBloc>().add(LoadGroupMembers(widget.groupId));
          }
          if (state is WatchGroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WatchGroupLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GroupMembersLoaded) {
            // Mock group for demo (in real app, you'd fetch the group separately)
            _group ??= WatchGroupEntity(
              groupId: widget.groupId,
              name: 'Demo Watch Group',
              description: 'Community safety group for our neighborhood',
              region: 'Centre',
              city: 'Yaoundé',
              neighborhood: 'Bastos',
              coordinatorId: '123',
              coordinatorName: 'John Doe',
              latitude: 3.8480,
              longitude: 11.5021,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              memberCount: state.members.length,
            );

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.shield, size: 32, color: AppTheme.primaryColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _group!.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_group!.neighborhood}, ${_group!.city}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        const Text(
                          'About',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _group!.description,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 24),

                        // Stats
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                Icons.people,
                                '${state.members.length}',
                                'Members',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                Icons.event,
                                '${_group!.meetingCount}',
                                'Meetings',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                Icons.warning,
                                '${_group!.alertCount}',
                                'Alerts',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Coordinator
                        const Text(
                          'Coordinator',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: Text(_group!.coordinatorName[0].toUpperCase()),
                          ),
                          title: Text(_group!.coordinatorName),
                          subtitle: const Text('Group Coordinator'),
                          trailing: const Icon(Icons.verified, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(height: 24),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MembersPage(
                                        groupId: widget.groupId,
                                        members: state.members,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.people),
                                label: const Text('Members'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                        create: (context) => di.sl<WatchGroupBloc>(),
                                        child: MeetingsPage(groupId: widget.groupId),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.event),
                                label: const Text('Meetings'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Loading group details...'));
        },
      ),
      floatingActionButton: authState is Authenticated
          ? FloatingActionButton.extended(
              onPressed: () {
                context.read<WatchGroupBloc>().add(
                      JoinWatchGroupRequested(
                        groupId: widget.groupId,
                        userId: authState.user.uid,
                        userName: authState.user.displayName,
                        userPhoto: authState.user.profilePhoto,
                        phoneNumber: authState.user.phoneNumber,
                      ),
                    );
              },
              icon: const Icon(Icons.add),
              label: const Text('Join Group'),
            )
          : null,
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
