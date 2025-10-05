import 'package:equatable/equatable.dart';

class DonorEntity extends Equatable {
  final String donorId;
  final String userId;
  final String name;
  final String phoneNumber;
  final BloodType bloodType;
  final String region;
  final String city;
  final String neighborhood;
  final double latitude;
  final double longitude;
  final bool isAvailable;
  final DateTime? lastDonation;
  final int totalDonations;
  final DateTime registeredAt;

  const DonorEntity({
    required this.donorId,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.bloodType,
    required this.region,
    required this.city,
    required this.neighborhood,
    required this.latitude,
    required this.longitude,
    this.isAvailable = true,
    this.lastDonation,
    this.totalDonations = 0,
    required this.registeredAt,
  });

  bool get canDonate {
    if (!isAvailable) return false;
    if (lastDonation == null) return true;
    // Must wait 3 months between donations
    return DateTime.now().difference(lastDonation!).inDays >= 90;
  }

  @override
  List<Object?> get props => [donorId, userId, bloodType, isAvailable];
}

class BloodRequestEntity extends Equatable {
  final String requestId;
  final String requesterId;
  final String requesterName;
  final String requesterPhone;
  final BloodType bloodType;
  final String hospitalName;
  final String urgency;
  final String message;
  final DateTime createdAt;
  final bool isActive;

  const BloodRequestEntity({
    required this.requestId,
    required this.requesterId,
    required this.requesterName,
    required this.requesterPhone,
    required this.bloodType,
    required this.hospitalName,
    this.urgency = 'normal',
    required this.message,
    required this.createdAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [requestId, bloodType, isActive];
}

enum BloodType {
  aPositive,
  aNegative,
  bPositive,
  bNegative,
  oPositive,
  oNegative,
  abPositive,
  abNegative,
}
