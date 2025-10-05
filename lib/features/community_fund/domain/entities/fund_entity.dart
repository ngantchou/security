import 'package:equatable/equatable.dart';

class CommunityFundEntity extends Equatable {
  final String fundId;
  final String communityName; // Region, City, or Neighborhood
  final String region;
  final String city;
  final String? neighborhood;
  final double totalBalance;
  final String currency;
  final int totalContributors;
  final int totalDisbursements;
  final List<String> administratorIds;
  final FundRules rules;
  final DateTime createdAt;

  const CommunityFundEntity({
    required this.fundId,
    required this.communityName,
    required this.region,
    required this.city,
    this.neighborhood,
    this.totalBalance = 0.0,
    this.currency = 'XAF',
    this.totalContributors = 0,
    this.totalDisbursements = 0,
    this.administratorIds = const [],
    required this.rules,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [fundId, totalBalance];
}

class FundContributionEntity extends Equatable {
  final String contributionId;
  final String fundId;
  final String contributorId;
  final String contributorName;
  final double amount;
  final String currency;
  final ContributionType type;
  final bool isRecurring;
  final String? recurringPeriod; // monthly, quarterly, etc.
  final String? paymentRef;
  final DateTime contributedAt;

  const FundContributionEntity({
    required this.contributionId,
    required this.fundId,
    required this.contributorId,
    required this.contributorName,
    required this.amount,
    this.currency = 'XAF',
    this.type = ContributionType.oneTime,
    this.isRecurring = false,
    this.recurringPeriod,
    this.paymentRef,
    required this.contributedAt,
  });

  @override
  List<Object?> get props => [contributionId, fundId, amount];
}

class DisbursementRequestEntity extends Equatable {
  final String requestId;
  final String fundId;
  final String requesterId;
  final String requesterName;
  final String requesterPhone;
  final double amountRequested;
  final String currency;
  final EmergencyCategory category;
  final String reason;
  final String? alertId; // Link to emergency alert
  final List<String> supportingDocuments; // URLs
  final RequestStatus status;
  final List<String> approverIds;
  final int votesFor;
  final int votesAgainst;
  final String? disbursementRef;
  final DateTime requestedAt;
  final DateTime? processedAt;

  const DisbursementRequestEntity({
    required this.requestId,
    required this.fundId,
    required this.requesterId,
    required this.requesterName,
    required this.requesterPhone,
    required this.amountRequested,
    this.currency = 'XAF',
    required this.category,
    required this.reason,
    this.alertId,
    this.supportingDocuments = const [],
    this.status = RequestStatus.pending,
    this.approverIds = const [],
    this.votesFor = 0,
    this.votesAgainst = 0,
    this.disbursementRef,
    required this.requestedAt,
    this.processedAt,
  });

  @override
  List<Object?> get props => [requestId, status, votesFor];
}

class FundTransactionEntity extends Equatable {
  final String transactionId;
  final String fundId;
  final TransactionType type;
  final double amount;
  final String currency;
  final String? contributorId;
  final String? recipientId;
  final String description;
  final String? reference;
  final DateTime transactionDate;

  const FundTransactionEntity({
    required this.transactionId,
    required this.fundId,
    required this.type,
    required this.amount,
    this.currency = 'XAF',
    this.contributorId,
    this.recipientId,
    required this.description,
    this.reference,
    required this.transactionDate,
  });

  @override
  List<Object?> get props => [transactionId, fundId, amount];
}

class FundRules extends Equatable {
  final double minimumContribution;
  final double maximumDisbursement;
  final int requiredApprovals; // Number of admin approvals needed
  final bool allowPublicContributions;
  final bool requireDocumentation;
  final int votingPeriodDays;

  const FundRules({
    this.minimumContribution = 1000.0, // 1000 XAF
    this.maximumDisbursement = 500000.0, // 500,000 XAF
    this.requiredApprovals = 2,
    this.allowPublicContributions = true,
    this.requireDocumentation = true,
    this.votingPeriodDays = 3,
  });

  @override
  List<Object?> get props => [
        minimumContribution,
        maximumDisbursement,
        requiredApprovals,
      ];
}

enum ContributionType {
  oneTime,
  monthly,
  quarterly,
  annual,
}

enum RequestStatus {
  pending,
  underReview,
  approved,
  rejected,
  disbursed,
}

enum TransactionType {
  contribution,
  disbursement,
  refund,
  adjustment,
}

enum EmergencyCategory {
  medical,
  housing,
  food,
  education,
  disaster,
  funeral,
  other,
}
