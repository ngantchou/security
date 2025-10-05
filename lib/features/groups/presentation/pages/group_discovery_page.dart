import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/danger_group_entity.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';

class GroupDiscoveryPage extends StatefulWidget {
  const GroupDiscoveryPage({super.key});

  @override
  State<GroupDiscoveryPage> createState() => _GroupDiscoveryPageState();
}

class _GroupDiscoveryPageState extends State<GroupDiscoveryPage> {
  final _searchController = TextEditingController();
  DangerGroup? _selectedDangerGroup;
  DangerType? _selectedDangerType;
  bool _showGroupFilters = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<GroupBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover Groups'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search groups...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (query) {
                  if (query.trim().isNotEmpty) {
                    context
                        .read<GroupBloc>()
                        .add(SearchGroupsRequested(query.trim()));
                  }
                },
              ),
            ),
          ),
        ),
        body: BlocListener<GroupBloc, GroupState>(
          listener: (context, state) {
            if (state is GroupError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            } else if (state is GroupFollowed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.accentColor,
                ),
              );
            } else if (state is GroupUnfollowed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.textSecondaryColor,
                ),
              );
            }
          },
          child: Column(
            children: [
              // Danger group/type filter
              _buildFilterSection(),
              const Divider(height: 1),

              // Groups list
              Expanded(
                child: BlocBuilder<GroupBloc, GroupState>(
                  builder: (context, state) {
                    if (state is GroupLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is GroupsSearchResults) {
                      // Filter by selected group or type
                      List<DangerGroupEntity> groups = state.groups;

                      if (_selectedDangerGroup != null) {
                        // Filter by danger group (multiple types)
                        final groupTypes = _selectedDangerGroup!.dangerTypes;
                        groups = groups
                            .where((g) => groupTypes.contains(g.dangerType))
                            .toList();
                      } else if (_selectedDangerType != null) {
                        // Filter by specific danger type
                        groups = groups
                            .where((g) => g.dangerType == _selectedDangerType)
                            .toList();
                      }

                      if (groups.isEmpty) {
                        return _buildEmptyState('No groups found');
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          return _buildGroupCard(groups[index]);
                        },
                      );
                    }

                    return _buildEmptyState(
                      'Search for groups to discover communities',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toggle between group and type filters
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Filter by:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Groups'),
                      selected: _showGroupFilters,
                      onSelected: (selected) {
                        setState(() {
                          _showGroupFilters = true;
                          _selectedDangerType = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Types'),
                      selected: !_showGroupFilters,
                      onSelected: (selected) {
                        setState(() {
                          _showGroupFilters = false;
                          _selectedDangerGroup = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Filter chips
        if (_showGroupFilters)
          _buildGroupFilters()
        else
          _buildTypeFilters(),
      ],
    );
  }

  Widget _buildGroupFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All Groups'),
            selected: _selectedDangerGroup == null,
            onSelected: (selected) {
              setState(() {
                _selectedDangerGroup = null;
              });
            },
          ),
          const SizedBox(width: 8),
          ...DangerGroup.values.map((group) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Text(group.icon),
                label: Text(group.displayName),
                selected: _selectedDangerGroup == group,
                onSelected: (selected) {
                  setState(() {
                    _selectedDangerGroup = selected ? group : null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTypeFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All Types'),
            selected: _selectedDangerType == null,
            onSelected: (selected) {
              setState(() {
                _selectedDangerType = null;
              });
            },
          ),
          const SizedBox(width: 8),
          ...DangerType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Text(type.icon),
                label: Text(type.displayName),
                selected: _selectedDangerType == type,
                onSelected: (selected) {
                  setState(() {
                    _selectedDangerType = selected ? type : null;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGroupCard(DangerGroupEntity group) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group cover image
          if (group.coverImageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                group.coverImageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group header
                Row(
                  children: [
                    Text(
                      group.dangerType.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            group.dangerType.displayName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPrivacyBadge(group.privacy),
                  ],
                ),
                const SizedBox(height: 12),

                // Group description
                Text(
                  group.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Group stats
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group.memberCount} members',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      group.neighborhood ?? group.city,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group.alertCount} alerts',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Join button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is! Authenticated) {
                      return const SizedBox.shrink();
                    }

                    final isFollowing = authState.user.followedDangerGroups
                        .contains(group.groupId);

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (isFollowing) {
                            context.read<GroupBloc>().add(
                                  UnfollowGroupRequested(
                                    groupId: group.groupId,
                                    userId: authState.user.uid,
                                  ),
                                );
                          } else {
                            context.read<GroupBloc>().add(
                                  FollowGroupRequested(
                                    groupId: group.groupId,
                                    userId: authState.user.uid,
                                    userName: authState.user.displayName,
                                    userPhoto: authState.user.profilePhoto,
                                  ),
                                );
                          }
                        },
                        icon: Icon(
                          isFollowing ? Icons.check : Icons.add,
                        ),
                        label: Text(
                          isFollowing ? 'Joined' : 'Join Group',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowing
                              ? AppTheme.textSecondaryColor
                              : AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyBadge(GroupPrivacy privacy) {
    String label;
    IconData icon;
    Color color;

    switch (privacy) {
      case GroupPrivacy.public:
        label = 'Public';
        icon = Icons.public;
        color = AppTheme.accentColor;
        break;
      case GroupPrivacy.private:
        label = 'Private';
        icon = Icons.lock;
        color = AppTheme.errorColor;
        break;
      case GroupPrivacy.restricted:
        label = 'Restricted';
        icon = Icons.verified_user;
        color = AppTheme.primaryColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.explore_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
