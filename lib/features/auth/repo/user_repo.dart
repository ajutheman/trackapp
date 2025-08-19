
import '../../../core/constants/api_endpoints.dart';
import '../../../model/network/result.dart';
import '../../../services/network/api_service.dart';

class UserRepository {
  final ApiService apiService;

  UserRepository({required this.apiService});

  Future<Result<Map<String, dynamic>>> createProfile({
    required String name,
    required String whatsappNumber,
    required String email,
    required String userType,
    required String token,
  }) async {
    final res = await apiService.post(
      ApiEndpoints.registerProfile,
      body: {
        "name": name,
        "whatsappNumber": whatsappNumber,
        "email": email,
        "user_type": userType,
      },
      isTokenRequired: false,
      token: token,
    );

    if (res.isSuccess) return Result.success(res.data as Map<String, dynamic>);
    return Result.error(res.message ?? 'Failed to create profile');
  }

  /// Fetch the currently authenticated user's profile
  // Future<Result<Map<String, dynamic>>> getMyProfile({
  //   required String token,
  // }) async {
  //   final res = await apiService.get(
  //     ApiEndpoints.userProfile,
  //     isTokenRequired: true,
  //     token: token,
  //   );
  //
  //   if (res.isSuccess) return Result.success(res.data as Map<String, dynamic>);
  //   return Result.error(res.message ?? 'Failed to fetch profile');
  // }
  //
  // /// Update profile fields (partial update).
  // /// Pass only the fields you want to change.
  // Future<Result<Map<String, dynamic>>> updateProfile({
  //   required Map<String, dynamic> fields,
  //   required String token,
  // }) async {
  //   // If your ApiService supports patch(), prefer that. Otherwise keep put().
  //   final res = await apiService.put(
  //     ApiEndpoints.userProfile,
  //     body: fields,
  //     isTokenRequired: true,
  //     token: token,
  //   );
  //
  //   if (res.isSuccess) return Result.success(res.data as Map<String, dynamic>);
  //   return Result.error(res.message ?? 'Failed to update profile');
  // }
}
