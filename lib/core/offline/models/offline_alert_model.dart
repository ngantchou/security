import 'package:hive/hive.dart';

part 'offline_alert_model.g.dart';

@HiveType(typeId: 0)
class OfflineAlertModel extends HiveObject {
  @HiveField(0)
  final String localId; // UUID for local tracking

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String dangerType;

  @HiveField(4)
  final int level;

  @HiveField(5)
  final double latitude;

  @HiveField(6)
  final double longitude;

  @HiveField(7)
  final String? neighborhood;

  @HiveField(8)
  final String? city;

  @HiveField(9)
  final String? region;

  @HiveField(10)
  final List<String>? imageUrls;

  @HiveField(11)
  final String? audioCommentUrl;

  @HiveField(12)
  final String userId;

  @HiveField(13)
  final String userName;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final bool isSynced;

  @HiveField(16)
  final String? syncError;

  @HiveField(17)
  final int syncAttempts;

  OfflineAlertModel({
    required this.localId,
    required this.title,
    required this.description,
    required this.dangerType,
    required this.level,
    required this.latitude,
    required this.longitude,
    this.neighborhood,
    this.city,
    this.region,
    this.imageUrls,
    this.audioCommentUrl,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.isSynced = false,
    this.syncError,
    this.syncAttempts = 0,
  });

  OfflineAlertModel copyWith({
    String? localId,
    String? title,
    String? description,
    String? dangerType,
    int? level,
    double? latitude,
    double? longitude,
    String? neighborhood,
    String? city,
    String? region,
    List<String>? imageUrls,
    String? audioCommentUrl,
    String? userId,
    String? userName,
    DateTime? createdAt,
    bool? isSynced,
    String? syncError,
    int? syncAttempts,
  }) {
    return OfflineAlertModel(
      localId: localId ?? this.localId,
      title: title ?? this.title,
      description: description ?? this.description,
      dangerType: dangerType ?? this.dangerType,
      level: level ?? this.level,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      region: region ?? this.region,
      imageUrls: imageUrls ?? this.imageUrls,
      audioCommentUrl: audioCommentUrl ?? this.audioCommentUrl,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      syncError: syncError ?? this.syncError,
      syncAttempts: syncAttempts ?? this.syncAttempts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localId': localId,
      'title': title,
      'description': description,
      'dangerType': dangerType,
      'level': level,
      'latitude': latitude,
      'longitude': longitude,
      'neighborhood': neighborhood,
      'city': city,
      'region': region,
      'imageUrls': imageUrls,
      'audioCommentUrl': audioCommentUrl,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced,
      'syncError': syncError,
      'syncAttempts': syncAttempts,
    };
  }
}
