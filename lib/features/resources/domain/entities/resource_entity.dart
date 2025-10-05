import 'package:equatable/equatable.dart';

class ResourceEntity extends Equatable {
  final String resourceId;
  final String ownerId;
  final String ownerName;
  final String? ownerPhoto;
  final String? ownerPhone;
  final ResourceType type;
  final String name;
  final String description;
  final ResourceStatus status;
  final String region;
  final String city;
  final String neighborhood;
  final String? address;
  final double latitude;
  final double longitude;
  final DateTime availableFrom;
  final DateTime? availableUntil;
  final int quantity;
  final String? conditions; // Free, paid, trade, etc
  final DateTime createdAt;
  final DateTime updatedAt;

  const ResourceEntity({
    required this.resourceId,
    required this.ownerId,
    required this.ownerName,
    this.ownerPhoto,
    this.ownerPhone,
    required this.type,
    required this.name,
    required this.description,
    this.status = ResourceStatus.available,
    required this.region,
    required this.city,
    required this.neighborhood,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.availableFrom,
    this.availableUntil,
    this.quantity = 1,
    this.conditions,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        resourceId,
        ownerId,
        type,
        name,
        status,
        latitude,
        longitude,
        availableFrom,
        createdAt,
      ];
}

class ResourceRequestEntity extends Equatable {
  final String requestId;
  final String requesterId;
  final String requesterName;
  final String? requesterPhone;
  final String resourceId;
  final String message;
  final RequestStatus status;
  final DateTime requestedAt;
  final DateTime? respondedAt;

  const ResourceRequestEntity({
    required this.requestId,
    required this.requesterId,
    required this.requesterName,
    this.requesterPhone,
    required this.resourceId,
    required this.message,
    this.status = RequestStatus.pending,
    required this.requestedAt,
    this.respondedAt,
  });

  @override
  List<Object?> get props => [requestId, resourceId, requesterId, status];
}

enum ResourceType {
  generator,
  medicalSupplies,
  safeHouse,
  waterSource,
  foodSupplies,
  vehicle,
  communication,
  tools,
  other,
}

enum ResourceStatus {
  available,
  reserved,
  unavailable,
}

enum RequestStatus {
  pending,
  approved,
  rejected,
  completed,
}
