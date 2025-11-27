// lib/features/token/repo/token_repo.dart

import '../../../core/constants/api_endpoints.dart';
import '../../../model/network/result.dart';
import '../../../services/network/api_service.dart';
import '../model/token.dart';

class TokenRepository {
  final ApiService apiService;

  TokenRepository({required this.apiService});

  /// Get wallet balance for the current driver
  Future<Result<TokenWallet>> getBalance() async {
    final result = await apiService.get(
      ApiEndpoints.tokenBalance,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final walletData = result.data is Map<String, dynamic>
            ? result.data as Map<String, dynamic>
            : <String, dynamic>{};
        final wallet = TokenWallet.fromJson(walletData);
        return Result.success(wallet);
      } catch (e) {
        return Result.error('Failed to parse wallet: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch wallet balance');
    }
  }

  /// Get lead token usage for a given distance
  Future<Result<LeadTokenUsage>> getLeadTokenUsage({required double distanceKm}) async {
    final result = await apiService.get(
      ApiEndpoints.leadTokenUsage,
      queryParams: {'distanceKm': distanceKm},
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final usageData = result.data is Map<String, dynamic>
            ? result.data as Map<String, dynamic>
            : <String, dynamic>{};
        final usage = LeadTokenUsage.fromJson(usageData);
        return Result.success(usage);
      } catch (e) {
        return Result.error('Failed to parse token usage: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch token usage');
    }
  }

  /// Get token transactions history
  Future<Result<List<TokenTransaction>>> getTransactions({
    int? page,
    int? limit,
  }) async {
    // Note: This endpoint needs to be implemented on the server
    // For now, we'll use a placeholder endpoint
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final result = await apiService.get(
      ApiEndpoints.tokenTransactions,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final List<dynamic> transactionsData = result.data is List
            ? result.data
            : (result.data['transactions'] ?? result.data['data'] ?? []);
        final List<TokenTransaction> transactions = transactionsData
            .map((txnJson) => TokenTransaction.fromJson(txnJson as Map<String, dynamic>))
            .toList();
        return Result.success(transactions);
      } catch (e) {
        return Result.error('Failed to parse transactions: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch transactions');
    }
  }

  /// Get all active token purchase plans
  Future<Result<List<TokenPlan>>> getTokenPlans() async {
    final result = await apiService.get(
      ApiEndpoints.tokenPlans,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final List<dynamic> plansData = result.data is List
            ? result.data
            : (result.data['plans'] ?? result.data['data'] ?? []);
        final List<TokenPlan> plans = plansData
            .map((planJson) => TokenPlan.fromJson(planJson as Map<String, dynamic>))
            .toList();
        return Result.success(plans);
      } catch (e) {
        return Result.error('Failed to parse token plans: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch token plans');
    }
  }

  /// Purchase a token plan
  Future<Result<dynamic>> purchaseTokenPlan({required String planId}) async {
    final result = await apiService.post(
      ApiEndpoints.purchaseTokens,
      body: {'planId': planId},
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      return Result.success(result.data);
    } else {
      return Result.error(result.message ?? 'Failed to purchase token plan');
    }
  }
}

