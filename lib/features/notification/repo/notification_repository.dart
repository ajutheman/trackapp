import '../../../core/constants/api_endpoints.dart';
import '../../../model/network/result.dart';
import '../../../services/network/api_service.dart';

class NotificationRepository {
  final ApiService apiService;

  NotificationRepository({required this.apiService});

  Future<Result<bool>> updateFcmToken(String token) async {
    final result = await apiService.put(
      ApiEndpoints.updateFcmToken,
      body: {'fcmToken': token},
      isTokenRequired: true,
    );
    if (result.isSuccess) {
      return Result.success(true);
    }
    return Result.error(result.message!);
  }

  Future<Result<Map<String, dynamic>>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final result = await apiService.get(
      "${ApiEndpoints.getNotifications}?page=$page&limit=$limit",
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      // Assuming backend returns { notifications: [], pagination: {} }
      // and Result.data is that object.
      return Result.success(result.data);
    }
    return Result.error(result.message!);
  }

  Future<Result<bool>> markAsRead(String notificationId) async {
    // Replace :id placeholder if exists, or append. Backend: /:id/read
    // My ApiService probably doesn't support parameterized paths in constant, so I construct URL.
    // But ApiEndpoints usually are just paths.
    final url = "${ApiEndpoints.getNotifications}/$notificationId/read";

    final result = await apiService.put(url, isTokenRequired: true);

    if (result.isSuccess) {
      return Result.success(true);
    }
    return Result.error(result.message!);
  }

  Future<Result<bool>> markAllAsRead() async {
    final result = await apiService.put(
      ApiEndpoints.markAllRead,
      isTokenRequired: true,
    );
    if (result.isSuccess) {
      return Result.success(true);
    }
    return Result.error(result.message!);
  }
}
