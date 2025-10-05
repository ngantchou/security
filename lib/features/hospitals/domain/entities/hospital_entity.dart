import 'package:equatable/equatable.dart';

class HospitalEntity extends Equatable {
  final String hospitalId;
  final String name;
  final HospitalType type;
  final String phoneNumber;
  final String? emergencyLine;
  final String region;
  final String city;
  final String neighborhood;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> specializations;
  final String operatingHours;
  final bool has24HourService;
  final bool hasAmbulance;
  final bool hasEmergencyRoom;
  final DateTime createdAt;

  const HospitalEntity({
    required this.hospitalId,
    required this.name,
    required this.type,
    required this.phoneNumber,
    this.emergencyLine,
    required this.region,
    required this.city,
    required this.neighborhood,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.specializations = const [],
    this.operatingHours = '24/7',
    this.has24HourService = true,
    this.hasAmbulance = false,
    this.hasEmergencyRoom = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [hospitalId, name, latitude, longitude];
}

enum HospitalType {
  publicHospital,
  privateHospital,
  clinic,
  healthCenter,
  pharmacy,
}
