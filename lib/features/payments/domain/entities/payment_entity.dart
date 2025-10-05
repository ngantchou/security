import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String paymentId;
  final String userId;
  final String userName;
  final MobileMoneyProvider provider;
  final String phoneNumber;
  final double amount;
  final String currency;
  final PaymentType type;
  final String? campaignId; // For donations/fundraising
  final String? description;
  final PaymentStatus status;
  final String? transactionRef;
  final DateTime createdAt;
  final DateTime? completedAt;

  const PaymentEntity({
    required this.paymentId,
    required this.userId,
    required this.userName,
    required this.provider,
    required this.phoneNumber,
    required this.amount,
    this.currency = 'XAF', // Central African CFA franc
    required this.type,
    this.campaignId,
    this.description,
    this.status = PaymentStatus.pending,
    this.transactionRef,
    required this.createdAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [paymentId, transactionRef, status];
}

class CrowdfundingCampaignEntity extends Equatable {
  final String campaignId;
  final String creatorId;
  final String creatorName;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final CampaignCategory category;
  final String? alertId; // Link to emergency alert
  final String? beneficiaryName;
  final String? beneficiaryPhone;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> donorIds;
  final String? imageUrl;
  final DateTime createdAt;

  const CrowdfundingCampaignEntity({
    required this.campaignId,
    required this.creatorId,
    required this.creatorName,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.currency = 'XAF',
    required this.category,
    this.alertId,
    this.beneficiaryName,
    this.beneficiaryPhone,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.donorIds = const [],
    this.imageUrl,
    required this.createdAt,
  });

  double get progressPercentage =>
      targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;

  @override
  List<Object?> get props => [campaignId, currentAmount, isActive];
}

class DonationEntity extends Equatable {
  final String donationId;
  final String donorId;
  final String donorName;
  final String campaignId;
  final double amount;
  final String currency;
  final MobileMoneyProvider provider;
  final String phoneNumber;
  final bool isAnonymous;
  final String? message;
  final DateTime donatedAt;

  const DonationEntity({
    required this.donationId,
    required this.donorId,
    required this.donorName,
    required this.campaignId,
    required this.amount,
    this.currency = 'XAF',
    required this.provider,
    required this.phoneNumber,
    this.isAnonymous = false,
    this.message,
    required this.donatedAt,
  });

  @override
  List<Object?> get props => [donationId, campaignId, amount];
}

enum MobileMoneyProvider {
  mtnMomo, // MTN Mobile Money
  orangeMoney,
}

enum PaymentType {
  donation,
  communityFund,
  resourcePurchase,
  subscription,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}

enum CampaignCategory {
  medical,
  emergency,
  education,
  infrastructure,
  communityProject,
  disaster,
}
