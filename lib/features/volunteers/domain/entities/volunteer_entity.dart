import 'package:equatable/equatable.dart';

class VolunteerEntity extends Equatable {
  final String volunteerId;
  final String userId;
  final String name;
  final String? photo;
  final String phoneNumber;
  final List<VolunteerSkill> skills;
  final String region;
  final String city;
  final String neighborhood;
  final double latitude;
  final double longitude;
  final double responseRadiusKm;
  final bool isAvailable;
  final int responsesCompleted;
  final double rating;
  final DateTime registeredAt;

  const VolunteerEntity({
    required this.volunteerId,
    required this.userId,
    required this.name,
    this.photo,
    required this.phoneNumber,
    required this.skills,
    required this.region,
    required this.city,
    required this.neighborhood,
    required this.latitude,
    required this.longitude,
    this.responseRadiusKm = 5.0,
    this.isAvailable = true,
    this.responsesCompleted = 0,
    this.rating = 0.0,
    required this.registeredAt,
  });

  @override
  List<Object?> get props => [volunteerId, userId, isAvailable];
}

enum VolunteerSkill {
  firstAid,
  medic,
  rescue,
  firefighting,
  security,
  translation,
  counseling,
  logistics,
  communication,
  other,
}
