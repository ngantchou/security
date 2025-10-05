import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/resource_entity.dart';

class ResourceModel extends ResourceEntity {
  const ResourceModel({
    required super.resourceId,
    required super.ownerId,
    required super.ownerName,
    super.ownerPhoto,
    super.ownerPhone,
    required super.type,
    required super.name,
    required super.description,
    super.status,
    required super.region,
    required super.city,
    required super.neighborhood,
    super.address,
    required super.latitude,
    required super.longitude,
    required super.availableFrom,
    super.availableUntil,
    super.quantity,
    super.conditions,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      resourceId: json['resourceId'] as String,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      ownerPhoto: json['ownerPhoto'] as String?,
      ownerPhone: json['ownerPhone'] as String?,
      type: ResourceType.values.firstWhere(
        (e) => e.toString() == 'ResourceType.${json['type']}',
      ),
      name: json['name'] as String,
      description: json['description'] as String,
      status: ResourceStatus.values.firstWhere(
        (e) => e.toString() == 'ResourceStatus.${json['status']}',
        orElse: () => ResourceStatus.available,
      ),
      region: json['region'] as String,
      city: json['city'] as String,
      neighborhood: json['neighborhood'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      availableFrom: (json['availableFrom'] as Timestamp).toDate(),
      availableUntil: json['availableUntil'] != null
          ? (json['availableUntil'] as Timestamp).toDate()
          : null,
      quantity: json['quantity'] as int? ?? 1,
      conditions: json['conditions'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceId': resourceId,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhoto': ownerPhoto,
      'ownerPhone': ownerPhone,
      'type': type.toString().split('.').last,
      'name': name,
      'description': description,
      'status': status.toString().split('.').last,
      'region': region,
      'city': city,
      'neighborhood': neighborhood,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'availableFrom': Timestamp.fromDate(availableFrom),
      'availableUntil':
          availableUntil != null ? Timestamp.fromDate(availableUntil!) : null,
      'quantity': quantity,
      'conditions': conditions,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class ResourceRequestModel extends ResourceRequestEntity {
  const ResourceRequestModel({
    required super.requestId,
    required super.requesterId,
    required super.requesterName,
    super.requesterPhone,
    required super.resourceId,
    required super.message,
    super.status,
    required super.requestedAt,
    super.respondedAt,
  });

  factory ResourceRequestModel.fromJson(Map<String, dynamic> json) {
    return ResourceRequestModel(
      requestId: json['requestId'] as String,
      requesterId: json['requesterId'] as String,
      requesterName: json['requesterName'] as String,
      requesterPhone: json['requesterPhone'] as String?,
      resourceId: json['resourceId'] as String,
      message: json['message'] as String,
      status: RequestStatus.values.firstWhere(
        (e) => e.toString() == 'RequestStatus.${json['status']}',
        orElse: () => RequestStatus.pending,
      ),
      requestedAt: (json['requestedAt'] as Timestamp).toDate(),
      respondedAt: json['respondedAt'] != null
          ? (json['respondedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterPhone': requesterPhone,
      'resourceId': resourceId,
      'message': message,
      'status': status.toString().split('.').last,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }
}
