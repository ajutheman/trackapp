// lib/features/token/model/token.dart

class TokenWallet {
  final String? id;
  final String driverId;
  final double balance;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TokenWallet({
    this.id,
    required this.driverId,
    required this.balance,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory TokenWallet.fromJson(Map<String, dynamic> json) {
    return TokenWallet(
      id: json['_id'] ?? json['id'],
      driverId: json['driver'] ?? json['driverId'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'driver': driverId,
      'balance': balance,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class TokenTransaction {
  final String? id;
  final String driverId;
  final String type; // 'credit' or 'debit'
  final double amount;
  final String? reason;
  final String? reference;
  final String? addedBy;
  final String? planId;
  final DateTime? createdAt;

  TokenTransaction({
    this.id,
    required this.driverId,
    required this.type,
    required this.amount,
    this.reason,
    this.reference,
    this.addedBy,
    this.planId,
    this.createdAt,
  });

  factory TokenTransaction.fromJson(Map<String, dynamic> json) {
    return TokenTransaction(
      id: json['_id'] ?? json['id'],
      driverId: json['driver'] ?? json['driverId'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      reason: json['reason'],
      reference: json['reference'],
      addedBy: json['addedBy'],
      planId: json['plan'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'driver': driverId,
      'type': type,
      'amount': amount,
      if (reason != null) 'reason': reason,
      if (reference != null) 'reference': reference,
      if (addedBy != null) 'addedBy': addedBy,
      if (planId != null) 'plan': planId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}

class TokenDeduction {
  final double tokensRequired;
  final double tokensDeducted;
  final DateTime? deductedAt;
  final bool hasSufficientTokens;

  TokenDeduction({
    required this.tokensRequired,
    this.tokensDeducted = 0,
    this.deductedAt,
    this.hasSufficientTokens = true,
  });

  factory TokenDeduction.fromJson(Map<String, dynamic> json) {
    return TokenDeduction(
      tokensRequired: ((json['tokensRequired'] ?? 0) as num).toDouble(),
      tokensDeducted: ((json['tokensDeducted'] ?? 0) as num).toDouble(),
      deductedAt: json['deductedAt'] != null ? DateTime.parse(json['deductedAt']) : null,
      hasSufficientTokens: json['hasSufficientTokens'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokensRequired': tokensRequired,
      'tokensDeducted': tokensDeducted,
      if (deductedAt != null) 'deductedAt': deductedAt!.toIso8601String(),
      'hasSufficientTokens': hasSufficientTokens,
    };
  }
}

class LeadTokenUsage {
  final double distanceKm;
  final double tokensRequired;
  final List<TokenBand> availableBands;

  LeadTokenUsage({
    required this.distanceKm,
    required this.tokensRequired,
    required this.availableBands,
  });

  factory LeadTokenUsage.fromJson(Map<String, dynamic> json) {
    return LeadTokenUsage(
      distanceKm: ((json['distanceKm'] ?? 0) as num).toDouble(),
      tokensRequired: ((json['tokensRequired'] ?? 0) as num).toDouble(),
      availableBands: (json['availableBands'] as List<dynamic>?)
              ?.map((band) => TokenBand.fromJson(band as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TokenBand {
  final String? id;
  final double distanceKmFrom;
  final double distanceKmTo;
  final double tokensRequired;
  final bool isActive;

  TokenBand({
    this.id,
    required this.distanceKmFrom,
    required this.distanceKmTo,
    required this.tokensRequired,
    this.isActive = true,
  });

  factory TokenBand.fromJson(Map<String, dynamic> json) {
    return TokenBand(
      id: json['_id'] ?? json['id'],
      distanceKmFrom: ((json['distanceKmFrom'] ?? 0) as num).toDouble(),
      distanceKmTo: ((json['distanceKmTo'] ?? 0) as num).toDouble(),
      tokensRequired: ((json['tokensRequired'] ?? 0) as num).toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }
}

