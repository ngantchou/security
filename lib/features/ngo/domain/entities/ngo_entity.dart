import 'package:equatable/equatable.dart';

class NGOEntity extends Equatable {
  final String ngoId;
  final String name;
  final String description;
  final NGOType type;
  final List<String> focusAreas; // Health, Education, Relief, etc.
  final String contactEmail;
  final String contactPhone;
  final String? website;
  final String region;
  final String city;
  final String address;
  final double latitude;
  final double longitude;
  final bool isVerified;
  final String? logoUrl;
  final int volunteersNeeded;
  final List<String> currentProjects;
  final DateTime registeredAt;

  const NGOEntity({
    required this.ngoId,
    required this.name,
    required this.description,
    required this.type,
    this.focusAreas = const [],
    required this.contactEmail,
    required this.contactPhone,
    this.website,
    required this.region,
    required this.city,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isVerified = false,
    this.logoUrl,
    this.volunteersNeeded = 0,
    this.currentProjects = const [],
    required this.registeredAt,
  });

  @override
  List<Object?> get props => [ngoId, name, isVerified];
}

class NGOAlertChannelEntity extends Equatable {
  final String channelId;
  final String ngoId;
  final String ngoName;
  final String channelName;
  final String description;
  final List<String> subscriberIds;
  final int alertCount;
  final DateTime createdAt;

  const NGOAlertChannelEntity({
    required this.channelId,
    required this.ngoId,
    required this.ngoName,
    required this.channelName,
    required this.description,
    this.subscriberIds = const [],
    this.alertCount = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [channelId, ngoId];
}

class VolunteerOpportunityEntity extends Equatable {
  final String opportunityId;
  final String ngoId;
  final String ngoName;
  final String title;
  final String description;
  final List<String> requiredSkills;
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  final int volunteersNeeded;
  final int volunteersRegistered;
  final bool isActive;
  final DateTime createdAt;

  const VolunteerOpportunityEntity({
    required this.opportunityId,
    required this.ngoId,
    required this.ngoName,
    required this.title,
    required this.description,
    this.requiredSkills = const [],
    required this.location,
    required this.startDate,
    this.endDate,
    this.volunteersNeeded = 10,
    this.volunteersRegistered = 0,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [opportunityId, ngoId, isActive];
}

enum NGOType {
  international,
  national,
  local,
  faithBased,
  community,
}
