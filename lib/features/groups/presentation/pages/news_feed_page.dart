import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';
import '../widgets/post_card.dart';
import 'create_post_page.dart';
import 'group_discovery_page.dart';

class NewsFeedPage extends StatelessWidget {
  const NewsFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthBloc>().state;
        final bloc = di.sl<GroupBloc>();
        if (authState is Authenticated) {
          bloc.add(LoadFeed(userId: authState.user.uid, limit: 50));
        }
        return bloc;
      },
      child: const _NewsFeedPageContent(),
    );
  }
}

class _NewsFeedPageContent extends StatefulWidget {
  const _NewsFeedPageContent();

  @override
  State<_NewsFeedPageContent> createState() => _NewsFeedPageContentState();
}

class _NewsFeedPageContentState extends State<_NewsFeedPageContent> {
  DangerGroup? _selectedGroupFilter;
  DangerType? _selectedTypeFilter;
  String _selectedSort = 'time';
  bool _showGroupFilters = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GroupDiscoveryPage(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _selectedSort = value;
              });
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                context.read<GroupBloc>().add(
                      SortFeedBy(
                        userId: authState.user.uid,
                        sortBy: value,
                      ),
                    );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'time',
                child: Text('Most Recent'),
              ),
              const PopupMenuItem(
                value: 'proximity',
                child: Text('Nearest'),
              ),
              const PopupMenuItem(
                value: 'severity',
                child: Text('Most Severe'),
              ),
            ],
          ),
        ],
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
          } else if (state is PostCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.accentColor,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Filter chips
            _buildFilterChips(),
            const Divider(height: 1),

            // Feed content
            Expanded(
              child: BlocBuilder<GroupBloc, GroupState>(
                builder: (context, state) {
                  if (state is GroupLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is FeedRefreshing) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is FeedEmpty) {
                    return _buildEmptyState(state.message);
                  }

                  if (state is FeedLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is Authenticated) {
                          context.read<GroupBloc>().add(
                                RefreshFeed(
                                  userId: authState.user.uid,
                                  filterByDangerType: _selectedTypeFilter,
                                  sortBy: _selectedSort,
                                ),
                              );
                        }
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: state.posts.length,
                        itemBuilder: (context, index) {
                          return PostCard(post: state.posts[index]);
                        },
                      ),
                    );
                  }

                  return _buildEmptyState('Pull down to refresh your feed');
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! Authenticated) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePostPage(),
                ),
              );

              if (result == true && context.mounted) {
                // Refresh feed after creating post
                context.read<GroupBloc>().add(
                      RefreshFeed(
                        userId: authState.user.uid,
                        filterByDangerType: _selectedTypeFilter,
                        sortBy: _selectedSort,
                      ),
                    );
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('New Post'),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
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
                          _selectedTypeFilter = null;
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
                          _selectedGroupFilter = null;
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
            selected: _selectedGroupFilter == null,
            onSelected: (selected) {
              setState(() {
                _selectedGroupFilter = null;
                _selectedTypeFilter = null;
              });
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                context.read<GroupBloc>().add(
                      FilterFeedByDangerType(
                        userId: authState.user.uid,
                        dangerType: null,
                      ),
                    );
              }
            },
          ),
          const SizedBox(width: 8),
          ...DangerGroup.values.map((group) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Text(group.icon),
                label: Text(group.displayName),
                selected: _selectedGroupFilter == group,
                onSelected: (selected) {
                  setState(() {
                    _selectedGroupFilter = selected ? group : null;
                    // When a group is selected, we don't filter by specific type
                    // The backend will need to handle filtering by danger types in the group
                    _selectedTypeFilter = selected ? group.dangerTypes.first : null;
                  });
                  final authState = context.read<AuthBloc>().state;
                  if (authState is Authenticated) {
                    // For now, filter by the first danger type in the group
                    // TODO: Backend should support filtering by multiple types (group)
                    context.read<GroupBloc>().add(
                          FilterFeedByDangerType(
                            userId: authState.user.uid,
                            dangerType: selected ? group.dangerTypes.firstOrNull : null,
                          ),
                        );
                  }
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
            selected: _selectedTypeFilter == null,
            onSelected: (selected) {
              setState(() {
                _selectedTypeFilter = null;
              });
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                context.read<GroupBloc>().add(
                      FilterFeedByDangerType(
                        userId: authState.user.uid,
                        dangerType: null,
                      ),
                    );
              }
            },
          ),
          const SizedBox(width: 8),
          ...DangerType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Text(type.icon),
                label: Text(type.displayName),
                selected: _selectedTypeFilter == type,
                onSelected: (selected) {
                  setState(() {
                    _selectedTypeFilter = selected ? type : null;
                  });
                  final authState = context.read<AuthBloc>().state;
                  if (authState is Authenticated) {
                    context.read<GroupBloc>().add(
                          FilterFeedByDangerType(
                            userId: authState.user.uid,
                            dangerType: selected ? type : null,
                          ),
                        );
                  }
                },
              ),
            );
          }),
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
            Icons.feed_outlined,
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GroupDiscoveryPage(),
                ),
              );
            },
            icon: const Icon(Icons.explore),
            label: const Text('Discover Groups'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
