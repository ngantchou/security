import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/watch_group_bloc.dart';
import '../bloc/watch_group_event.dart';
import '../bloc/watch_group_state.dart';
import '../../domain/entities/watch_group_entity.dart';
import 'create_meeting_page.dart';

class MeetingsPage extends StatefulWidget {
  final String groupId;

  const MeetingsPage({super.key, required this.groupId});

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<WatchGroupBloc>().add(LoadGroupMeetings(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetings'),
      ),
      body: BlocConsumer<WatchGroupBloc, WatchGroupState>(
        listener: (context, state) {
          if (state is MeetingRsvped) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<WatchGroupBloc>().add(LoadGroupMeetings(widget.groupId));
          }
        },
        builder: (context, state) {
          if (state is WatchGroupLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GroupMeetingsLoaded) {
            if (state.meetings.isEmpty) {
              return const Center(
                child: Text('No meetings scheduled'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.meetings.length,
              itemBuilder: (context, index) {
                return _buildMeetingCard(state.meetings[index], authState);
              },
            );
          }

          return const Center(child: Text('Loading meetings...'));
        },
      ),
      floatingActionButton: authState is Authenticated
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => di.sl<WatchGroupBloc>(),
                      child: CreateMeetingPage(groupId: widget.groupId),
                    ),
                  ),
                );
                if (result == true && mounted) {
                  context.read<WatchGroupBloc>().add(LoadGroupMeetings(widget.groupId));
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Schedule Meeting'),
            )
          : null,
    );
  }

  Widget _buildMeetingCard(MeetingEntity meeting, AuthState authState) {
    final isAttending = authState is Authenticated &&
        meeting.attendeeIds.contains(authState.user.uid);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event,
                  color: _getStatusColor(meeting.status),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    meeting.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d, yyyy • h:mm a').format(meeting.scheduledDate),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    meeting.location,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              meeting.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${meeting.attendeeIds.length} attending',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                if (authState is Authenticated)
                  OutlinedButton.icon(
                    onPressed: isAttending
                        ? null
                        : () {
                            context.read<WatchGroupBloc>().add(
                                  RsvpMeetingRequested(
                                    meetingId: meeting.meetingId,
                                    userId: authState.user.uid,
                                  ),
                                );
                          },
                    icon: Icon(isAttending ? Icons.check : Icons.event_available),
                    label: Text(isAttending ? 'Attending' : 'RSVP'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.scheduled:
        return AppTheme.primaryColor;
      case MeetingStatus.inProgress:
        return AppTheme.accentColor;
      case MeetingStatus.completed:
        return Colors.grey;
      case MeetingStatus.cancelled:
        return Colors.red;
    }
  }
}
