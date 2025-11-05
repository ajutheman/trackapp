// lib/features/connect/repo/driver_connection_repo.dart

import '../../../model/network/result.dart';
import '../../../services/network/api_service.dart';
import '../model/driver_connection.dart';

/// Repository class for handling driver connection-related API calls.
class DriverConnectionRepository {
  final ApiService apiService;

  DriverConnectionRepository({required this.apiService});

  /// Sends a friend request by mobile number.
  Future<Result<DriverConnection>> sendFriendRequest(String mobileNumber) async {
    final result = await apiService.post(
      'api/v1/driver-connections/request',
      body: {'mobileNumber': mobileNumber},
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final connectionData = result.data is Map 
            ? result.data 
            : (result.data['connection'] ?? result.data);
        final connection = DriverConnection.fromJson(connectionData);
        return Result.success(connection);
      } catch (e) {
        return Result.error('Failed to parse connection: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to send friend request');
    }
  }

  /// Gets friend requests (sent or received).
  Future<Result<List<DriverConnection>>> getFriendRequests({String type = 'received'}) async {
    final result = await apiService.get(
      'api/v1/driver-connections/requests',
      queryParams: {'type': type},
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final List<dynamic> connectionsData = result.data is List
            ? result.data
            : (result.data['connections'] ?? result.data['data'] ?? []);
        final List<DriverConnection> connections = connectionsData
            .map((connJson) => DriverConnection.fromJson(connJson as Map<String, dynamic>))
            .toList();
        return Result.success(connections);
      } catch (e) {
        return Result.error('Failed to parse connections: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch friend requests');
    }
  }

  /// Responds to a friend request (accept or reject).
  Future<Result<DriverConnection>> respondToFriendRequest({
    required String connectionId,
    required String action, // 'accept' or 'reject'
  }) async {
    final result = await apiService.put(
      'api/v1/driver-connections/$connectionId/respond',
      body: {'action': action},
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final connectionData = result.data is Map 
            ? result.data 
            : (result.data['connection'] ?? result.data);
        final connection = DriverConnection.fromJson(connectionData);
        return Result.success(connection);
      } catch (e) {
        return Result.error('Failed to parse connection: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to respond to friend request');
    }
  }

  /// Gets the confirmed friends list.
  Future<Result<List<DriverFriend>>> getFriendsList() async {
    final result = await apiService.get(
      'api/v1/driver-connections/friends',
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final List<dynamic> friendsData = result.data is List
            ? result.data
            : (result.data['friends'] ?? result.data['data'] ?? []);
        final List<DriverFriend> friends = friendsData
            .map((friendJson) => DriverFriend.fromJson(friendJson as Map<String, dynamic>))
            .toList();
        return Result.success(friends);
      } catch (e) {
        return Result.error('Failed to parse friends list: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch friends list');
    }
  }

  /// Removes a friend connection.
  Future<Result<bool>> removeFriend(String connectionId) async {
    final result = await apiService.delete(
      'api/v1/driver-connections/$connectionId',
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      return Result.success(true);
    } else {
      return Result.error(result.message ?? 'Failed to remove friend');
    }
  }
}

