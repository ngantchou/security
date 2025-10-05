import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/watch_group_bloc.dart';
import '../bloc/watch_group_event.dart';
import '../bloc/watch_group_state.dart';
import '../../domain/entities/watch_group_entity.dart';
import 'create_watch_group_page.dart';
import 'watch_group_detail_page.dart';

class WatchGroupsPage extends StatefulWidget {
  const WatchGroupsPage({super.key});

  @override
  State<WatchGroupsPage> createState() => _WatchGroupsPageState();
}

class _WatchGroupsPageState extends State<WatchGroupsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGroups();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    final authState = context.read<AuthBloc>().state;

    if (_tabController.index == 0) {
      // Load nearby groups
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        context.read<WatchGroupBloc>().add(
              LoadNearbyWatchGroups(
                latitude: position.latitude,
                longitude: position.longitude,
                radiusKm: 10.0,
              ),
            );
      }
    } else {
      // Load user's groups
      if (authState is Authenticated) {
        context.read<WatchGroupBloc>().add(
              LoadUserWatchGroups(authState.user.uid),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Neighborhood Watch'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => _loadGroups(),
          tabs: const [
            Tab(icon: Icon(Icons.explore), text: 'Nearby'),
            Tab(icon: Icon(Icons.group), text: 'My Groups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGroupsList(),
          authState is Authenticated
              ? _buildGroupsList()
              : const Center(child: Text('Please sign in to see your groups')),
        ],
      ),
      floatingActionButton: authState is Authenticated
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => di.sl<WatchGroupBloc>(),
                      child: const CreateWatchGroupPage(),
                    ),
                  ),
                );
                if (result == true && mounted) {
                  _loadGroups();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Group'),
            )
          : null,
    );
  }

  Widget _buildGroupsList() {
    return BlocBuilder<WatchGroupBloc, WatchGroupState>(
      builder: (context, state) {
        if (state is WatchGroupLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WatchGroupError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadGroups,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is WatchGroupsLoaded) {
          if (state.groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _tabController.index == 0
                        ? 'No groups nearby'
                        : 'You haven\'t joined any groups yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadGroups(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                return _buildGroupCard(state.groups[index]);
              },
            ),
          );
        }

        return const Center(child: Text('Pull down to load groups'));
      },
    );
  }

  Widget _buildGroupCard(WatchGroupEntity group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => di.sl<WatchGroupBloc>(),
                child: WatchGroupDetailPage(groupId: group.groupId),
              ),
            ),
          );
          _loadGroups();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.shield, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${group.neighborhood}, ${group.city}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (group.isPrivate)
                    Icon(Icons.lock, size: 18, color: Colors.grey[600]),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                group.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStat(Icons.people, '${group.memberCount}'),
                  const SizedBox(width: 16),
                  _buildStat(Icons.event, '${group.meetingCount}'),
                  const Spacer(),
                  Text(
                    'Coordinator: ${group.coordinatorName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
