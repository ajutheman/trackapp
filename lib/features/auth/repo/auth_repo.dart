// features/auth/repository/auth_repository.dart

import '../../../core/constants/api_endpoints.dart';
import '../../../model/network/result.dart';
import '../../../services/network/api_service.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository({required this.apiService});

  Future<Result<String>> sendOTP(String phone) async {
    final result = await apiService.post(ApiEndpoints.sendOTP, body: {'phone': phone}, isTokenRequired: false);
    if (result.isSuccess) {
      return Result.success(result.data["otpRequestToken"]);
    }
    return Result.error(result.message!);
  }

  Future<Result<Map<String,dynamic>>> verifyOTP(String otp, String token) async {
    final result = await apiService.post(ApiEndpoints.verifyOTP, body: {"otp": otp}, isTokenRequired: false,token: token);
    if (result.isSuccess) {
      return Result.success(result.data);
    }
    return Result.error(result.message!);
  }
}
