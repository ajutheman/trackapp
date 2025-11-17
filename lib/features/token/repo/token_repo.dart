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
}

