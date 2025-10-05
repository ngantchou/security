import 'package:flutter/material.dart';
import '../../domain/entities/watch_group_entity.dart';

class MembersPage extends StatelessWidget {
  final String groupId;
  final List<WatchMemberEntity> members;

  const MembersPage({
    super.key,
    required this.groupId,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: member.userPhoto != null
                  ? NetworkImage(member.userPhoto!)
                  : null,
              child: member.userPhoto == null
                  ? Text(member.userName[0].toUpperCase())
                  : null,
            ),
            title: Text(member.userName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getRoleText(member.role)),
                if (member.skills != null && member.skills!.isNotEmpty)
                  Text(
                    'Skills: ${member.skills}',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            trailing: _getRoleBadge(member.role),
          );
        },
      ),
    );
  }

  String _getRoleText(WatchRole role) {
    switch (role) {
      case WatchRole.coordinator:
        return 'Coordinator';
      case WatchRole.moderator:
        return 'Moderator';
      case WatchRole.member:
        return 'Member';
    }
  }

  Widget _getRoleBadge(WatchRole role) {
    IconData icon;
    Color color;

    switch (role) {
      case WatchRole.coordinator:
        icon = Icons.star;
        color = Colors.amber;
        break;
      case WatchRole.moderator:
        icon = Icons.shield;
        color = Colors.blue;
        break;
      case WatchRole.member:
        icon = Icons.person;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color);
  }
}
