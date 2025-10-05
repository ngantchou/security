import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../../domain/entities/watch_group_entity.dart';
import '../models/watch_group_model.dart';

abstract class WatchGroupRemoteDataSource {
  Future<WatchGroupModel> createGroup({
    required String name,
    required String description,
    required String region,
    required String city,
    required String neighborhood,
    required String coordinatorId,
    required String coordinatorName,
    String? coordinatorPhoto,
    String? coordinatorPhone,
    required double latitude,
    required double longitude,
    double radiusKm,
    bool isPrivate,
    bool requireApproval,
    int maxMembers,
  });

  Future<List<WatchGroupModel>> getNearbyGroups({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  Future<List<WatchGroupModel>> getUserGroups(String userId);
  Future<WatchGroupModel> getGroup(String groupId);
  Future<WatchGroupModel> updateGroup({
    required String groupId,
    String? name,
    String? description,
    String? coverImageUrl,
  });
  Future<void> deleteGroup(String groupId);

  Future<WatchMemberModel> joinGroup({
    required String groupId,
    required String userId,
    required String userName,
    String? userPhoto,
    String? phoneNumber,
    String? skills,
  });
  Future<void> leaveGroup({required String groupId, required String userId});
  Future<void> approveMember({
    required String groupId,
    required String memberId,
  });
  Future<void> rejectMember({
    required String groupId,
    required String memberId,
  });
  Future<List<WatchMemberModel>> getMembers(String groupId);
  Future<List<WatchMemberModel>> getPendingMembers(String groupId);
  Future<void> updateMemberRole({
    required String groupId,
    required String memberId,
    required WatchRole role,
  });

  Future<MeetingModel> createMeeting({
    required String groupId,
    required String title,
    required String description,
    required DateTime scheduledDate,
    required String location,
    String? locationAddress,
    required String organizerId,
    required String organizerName,
  });
  Future<List<MeetingModel>> getMeetings(String groupId);
  Future<void> rsvpMeeting({required String meetingId, required String userId});
  Future<void> cancelMeeting(String meetingId);
}

class WatchGroupRemoteDataSourceImpl implements WatchGroupRemoteDataSource {
  final FirebaseFirestore firestore;

  WatchGroupRemoteDataSourceImpl({required this.firestore});

  @override
  Future<WatchGroupModel> createGroup({
    required String name,
    required String description,
    required String region,
    required String city,
    required String neighborhood,
    required String coordinatorId,
    required String coordinatorName,
    String? coordinatorPhoto,
    String? coordinatorPhone,
    required double latitude,
    required double longitude,
    double radiusKm = 2.0,
    bool isPrivate = false,
    bool requireApproval = true,
    int maxMembers = 100,
  }) async {
    final groupRef = firestore.collection('watch_groups').doc();
    final now = DateTime.now();

    final geoFirePoint = GeoFirePoint(GeoPoint(latitude, longitude));

    final group = WatchGroupModel(
      groupId: groupRef.id,
      name: name,
      description: description,
      region: region,
      city: city,
      neighborhood: neighborhood,
      coordinatorId: coordinatorId,
      coordinatorName: coordinatorName,
      coordinatorPhoto: coordinatorPhoto,
      coordinatorPhone: coordinatorPhone,
      isPrivate: isPrivate,
      requireApproval: requireApproval,
      maxMembers: maxMembers,
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      createdAt: now,
      updatedAt: now,
    );

    final data = group.toJson();
    data['geopoint'] = geoFirePoint.geopoint;
    data['geohash'] = geoFirePoint.geohash;

    await groupRef.set(data);

    // Auto-add coordinator as member
    await _addMember(
      groupRef.id,
      coordinatorId,
      coordinatorName,
      coordinatorPhoto,
      coordinatorPhone,
      WatchRole.coordinator,
      MemberStatus.approved,
      null,
    );

    return group;
  }

  Future<void> _addMember(
    String groupId,
    String userId,
    String userName,
    String? userPhoto,
    String? phoneNumber,
    WatchRole role,
    MemberStatus status,
    String? skills,
  ) async {
    final memberRef = firestore
        .collection('watch_groups')
        .doc(groupId)
        .collection('members')
        .doc(userId);

    final member = WatchMemberModel(
      memberId: userId,
      groupId: groupId,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      phoneNumber: phoneNumber,
      role: role,
      status: status,
      joinedAt: DateTime.now(),
      skills: skills,
    );

    await memberRef.set(member.toJson());
  }

  @override
  Future<List<WatchGroupModel>> getNearbyGroups({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    final center = GeoFirePoint(GeoPoint(latitude, longitude));

    final stream = GeoCollectionReference(firestore.collection('watch_groups'))
        .subscribeWithin(
      center: center,
      radiusInKm: radiusKm,
      field: 'geopoint',
      geopointFrom: (data) => data['geopoint'] as GeoPoint,
      strictMode: true,
    );

    final snapshots = await stream.first;

    return snapshots
        .map((doc) => WatchGroupModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<WatchGroupModel>> getUserGroups(String userId) async {
    final membershipSnapshot = await firestore
        .collectionGroup('members')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'approved')
        .get();

    final groupIds = membershipSnapshot.docs
        .map((doc) => doc.data()['groupId'] as String)
        .toSet()
        .toList();

    if (groupIds.isEmpty) return [];

    final groups = <WatchGroupModel>[];
    for (final groupId in groupIds) {
      final groupDoc = await firestore.collection('watch_groups').doc(groupId).get();
      if (groupDoc.exists) {
        groups.add(WatchGroupModel.fromJson(groupDoc.data()!));
      }
    }

    return groups;
  }

  @override
  Future<WatchGroupModel> getGroup(String groupId) async {
    final doc = await firestore.collection('watch_groups').doc(groupId).get();
    if (!doc.exists) throw Exception('Group not found');
    return WatchGroupModel.fromJson(doc.data()!);
  }

  @override
  Future<WatchGroupModel> updateGroup({
    required String groupId,
    String? name,
    String? description,
    String? coverImageUrl,
  }) async {
    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updateData['name'] = name;
    if (description != null) updateData['description'] = description;
    if (coverImageUrl != null) updateData['coverImageUrl'] = coverImageUrl;

    await firestore.collection('watch_groups').doc(groupId).update(updateData);

    final doc = await firestore.collection('watch_groups').doc(groupId).get();
    return WatchGroupModel.fromJson(doc.data()!);
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    // Delete all members
    final membersSnapshot = await firestore
        .collection('watch_groups')
        .doc(groupId)
        .collection('members')
        .get();

    for (final doc in membersSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete all meetings
    final meetingsSnapshot = await firestore
        .collection('watch_groups')
        .doc(groupId)
        .collection('meetings')
        .get();

    for (final doc in meetingsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete group
    await firestore.collection('watch_groups').doc(groupId).delete();
  }

  @override
  Future<WatchMemberModel> joinGroup({
    required String groupId,
    required String userId,
    required String userName,
    String? userPhoto,
    String? phoneNumber,
    String? skills,
  }) async {
    final groupDoc = await firestore.collection('watch_groups').doc(groupId).get();
    if (!groupDoc.exists) throw Exception('Group not found');

    final groupData = groupDoc.data()!;
    final requireApproval = groupData['requireApproval'] as bool? ?? true;

    final member = WatchMemberModel(
      memberId: userId,
      groupId: groupId,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      phoneNumber: phoneNumber,
      role: WatchRole.member,
      status: requireApproval ? MemberStatus.pending : MemberStatus.approved,
      joinedAt: DateTime.now(),
      skills: skills,
    );

    await firestore
        .collection('watch_groups')
        .doc(groupId)
        .collection('members')
        .doc(userId)
        .set(member.toJson());

    if (!requireApproval) {
      await firestore.collection('watch_groups').doc(groupId).update({
        'memberCount': FieldValue.increment(1),
      });
    }

    return member;
  }

  @override
  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    await firestore
        .collection('watch_groups')
        .doc(groupId)
        .collection('members')
        .doc(userId)
        .delete();

    await firestore.collection('watch_groups').doc(groupId).update({
      'memberCount': FieldValue.increment(-1),
    });
  }

  @override
  Future<void> approveMember({
    required String groupId,
    required String memberId,
  }) async {
    await firestore
        .collection('watch_groups')
        .doc(groupId)
        .collection('members')
        .doc(memberId)
        .update({'status': 'approved'});

    await firestore.collection('watch_groups').doc(groupId).update({
      'memberCount': FieldValue.increment(1),
    });
  }

  @override
  Future<void> rejectMember({
    required String groupId,
    required String memberId,
  }) async {
    await firestore
        .collection('watch_groups')
        .doc(groupId)
        .collection('members')
        .doc(memberId)
        .update({'status': 'rejected'});
  }

  @override
  Future<List<WatchMemberModel>> getMembers(String groupId) async {
    final snapshot = await firestore
        .collection('watch_groups')
        .doc(groupId)
        .collection('members')
        .where('status', isEqualTo: 'approved')
        .orderBy('joinedAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => WatchMemberModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<List<WatchMemberModel>> getPendingMembers(String groupId) async {
    final snapshot = await firestore
        .collection('watch_groups')
        .doc(groupId)
        .collection('members')
        .where('status', isEqualTo: 'pending')
        .orderBy('joinedAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => WatchMemberModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> updateMemberRole({
    required String groupId,
    required String memberId,
    required WatchRole role,
  }) async {
    await firestore
        .collection('watch_groups')
        .doc(groupId)
        .collection('members')
        .doc(memberId)
        .update({'role': role.toString().split('.').last});
  }

  @override
  Future<MeetingModel> createMeeting({
    required String groupId,
    required String title,
    required String description,
    required DateTime scheduledDate,
    required String location,
    String? locationAddress,
    required String organizerId,
    required String organizerName,
  }) async {
    final meetingRef = firestore
        .collection('watch_groups')
        .doc(groupId)
        .collection('meetings')
        .doc();

    final meeting = MeetingModel(
      meetingId: meetingRef.id,
      groupId: groupId,
      title: title,
      description: description,
      scheduledDate: scheduledDate,
      location: location,
      locationAddress: locationAddress,
      organizerId: organizerId,
      organizerName: organizerName,
      createdAt: DateTime.now(),
    );

    await meetingRef.set(meeting.toJson());

    await firestore.collection('watch_groups').doc(groupId).update({
      'meetingCount': FieldValue.increment(1),
    });

    return meeting;
  }

  @override
  Future<List<MeetingModel>> getMeetings(String groupId) async {
    final snapshot = await firestore
        .collection('watch_groups')
        .doc(groupId)
        .collection('meetings')
        .orderBy('scheduledDate', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => MeetingModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> rsvpMeeting({
    required String meetingId,
    required String userId,
  }) async {
    final meetingsSnapshot = await firestore
        .collectionGroup('meetings')
        .where('meetingId', isEqualTo: meetingId)
        .get();

    if (meetingsSnapshot.docs.isEmpty) throw Exception('Meeting not found');

    await meetingsSnapshot.docs.first.reference.update({
      'attendeeIds': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> cancelMeeting(String meetingId) async {
    final meetingsSnapshot = await firestore
        .collectionGroup('meetings')
        .where('meetingId', isEqualTo: meetingId)
        .get();

    if (meetingsSnapshot.docs.isEmpty) throw Exception('Meeting not found');

    await meetingsSnapshot.docs.first.reference.update({
      'status': 'cancelled',
    });
  }
}
