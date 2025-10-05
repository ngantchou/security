import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/danger_group_entity.dart';
import '../../domain/entities/group_post_entity.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';

class CreatePostPage extends StatefulWidget {
  final String? groupId;
  final String? relatedAlertId;

  const CreatePostPage({
    super.key,
    this.groupId,
    this.relatedAlertId,
  });

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  PostType _selectedType = PostType.regular;
  DangerGroupEntity? _selectedGroup;
  List<File> _selectedImages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthBloc>().state;
        final bloc = di.sl<GroupBloc>();
        if (authState is Authenticated) {
          bloc.add(LoadUserGroups(authState.user.uid));
        }
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Post'),
          actions: [
            BlocBuilder<GroupBloc, GroupState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: _isLoading ? null : _submitPost,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Post',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
        body: BlocListener<GroupBloc, GroupState>(
          listener: (context, state) {
            if (state is GroupError) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            } else if (state is PostCreated) {
              Navigator.pop(context, true);
            }
          },
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Group selection
                _buildGroupSelector(),
                const SizedBox(height: 16),

                // Post type selection
                _buildPostTypeSelector(),
                const SizedBox(height: 16),

                // Content field
                TextFormField(
                  controller: _contentController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'What\'s happening in your area?',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter post content';
                    }
                    if (value.trim().length < 10) {
                      return 'Post must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Image picker
                _buildImagePicker(),
                const SizedBox(height: 16),

                // Selected images preview
                if (_selectedImages.isNotEmpty) _buildImagePreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupSelector() {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is UserGroupsLoaded) {
          final groups = state.groups;

          // If groupId was provided, pre-select that group
          if (widget.groupId != null && _selectedGroup == null) {
            _selectedGroup = groups.firstWhere(
              (g) => g.groupId == widget.groupId,
              orElse: () => groups.first,
            );
          } else if (_selectedGroup == null && groups.isNotEmpty) {
            _selectedGroup = groups.first;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Post to Group',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<DangerGroupEntity>(
                initialValue: _selectedGroup,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                items: groups.map((group) {
                  return DropdownMenuItem(
                    value: group,
                    child: Row(
                      children: [
                        Text(group.dangerType.icon),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            group.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (group) {
                  setState(() {
                    _selectedGroup = group;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a group';
                  }
                  return null;
                },
              ),
            ],
          );
        }

        if (state is GroupLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return const Center(
          child: Text('No groups available. Join a group to create posts.'),
        );
      },
    );
  }

  Widget _buildPostTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Post Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTypeChip(
                PostType.regular,
                'Regular',
                Icons.post_add,
                AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 8),
              _buildTypeChip(
                PostType.alert,
                'Alert',
                Icons.warning,
                AppTheme.errorColor,
              ),
              const SizedBox(width: 8),
              _buildTypeChip(
                PostType.announcement,
                'Announcement',
                Icons.campaign,
                AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              _buildTypeChip(
                PostType.resource,
                'Resource',
                Icons.info,
                AppTheme.accentColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip(
    PostType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == type;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? color : AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedType = type;
        });
      },
    );
  }

  Widget _buildImagePicker() {
    return OutlinedButton.icon(
      onPressed: _pickImages,
      icon: const Icon(Icons.image),
      label: Text(
        _selectedImages.isEmpty
            ? 'Add Images'
            : '${_selectedImages.length} image(s) selected',
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }

  Widget _buildImagePreview() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedImages[index],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImages.removeAt(index);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((xfile) => File(xfile.path)).toList();
      });
    }
  }

  void _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a group'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a post'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Upload images to Firebase Storage and get URLs
    final imageUrls = <String>[];

    context.read<GroupBloc>().add(
          CreatePostRequested(
            groupId: _selectedGroup!.groupId,
            authorId: authState.user.uid,
            authorName: authState.user.displayName,
            authorPhoto: authState.user.profilePhoto,
            content: _contentController.text.trim(),
            images: imageUrls,
            type: _selectedType,
            relatedAlertId: widget.relatedAlertId,
          ),
        );
  }
}
