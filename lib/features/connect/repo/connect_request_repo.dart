// lib/features/connect/repo/connect_request_repo.dart

import '../../../core/constants/api_endpoints.dart';
import '../../../model/network/result.dart';
import '../../../services/network/api_service.dart';
import '../model/connect_request.dart';

/// Repository class for handling connection request-related API calls.
class ConnectRequestRepository {
  final ApiService apiService;

  /// Constructor for ConnectRequestRepository.
  ConnectRequestRepository({required this.apiService});

  /// Sends a new connection request.
  ///
  /// Returns a [Result] containing the created [ConnectRequest] on success,
  /// or an error message on failure.
  Future<Result<ConnectRequest>> sendRequest({
    required String recipientId,
    String? customerRequestId,
    String? tripId,
    String? message,
  }) async {
    final body = <String, dynamic>{
      'recipientId': recipientId,
      if (customerRequestId != null) 'customerRequestId': customerRequestId,
      if (tripId != null) 'tripId': tripId,
      if (message != null) 'message': message,
    };

    final result = await apiService.post(
      ApiEndpoints.connectRequests,
      body: body,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        // Extract connectRequest from response data
        Map<String, dynamic> data;
        if (result.data is Map<String, dynamic>) {
          data = result.data as Map<String, dynamic>;
        } else if (result.data is Map) {
          data = Map<String, dynamic>.from(result.data);
        } else {
          data = <String, dynamic>{};
        }
        
        final connectRequestData = data['connectRequest'] ?? data;
        Map<String, dynamic> requestMap;
        if (connectRequestData is Map<String, dynamic>) {
          requestMap = connectRequestData;
        } else if (connectRequestData is Map) {
          requestMap = Map<String, dynamic>.from(connectRequestData);
        } else {
          requestMap = <String, dynamic>{};
        }
        final connectRequest = ConnectRequest.fromJson(requestMap);
        return Result.success(connectRequest);
      } catch (e) {
        return Result.error('Failed to parse connection request: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to send connection request');
    }
  }

  /// Fetches all connection requests for the current user.
  ///
  /// Returns a [Result] containing a list of [ConnectRequest] objects on success,
  /// or an error message on failure.
  Future<Result<List<ConnectRequest>>> getConnectRequests({
    String? status,
    String? type, // 'sent' or 'received'
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};

    if (status != null) queryParams['status'] = status;
    if (type != null) queryParams['type'] = type;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final result = await apiService.get(
      ApiEndpoints.connectRequests,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final List<dynamic> requestsData = result.data is List
            ? result.data
            : (result.data['requests'] ?? result.data['data'] ?? []);
        final List<ConnectRequest> requests = requestsData
            .map((requestJson) => ConnectRequest.fromJson(requestJson as Map<String, dynamic>))
            .toList();

        return Result.success(requests);
      } catch (e) {
        return Result.error('Failed to parse connection requests: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch connection requests');
    }
  }

  /// Fetches a specific connection request by ID.
  ///
  /// Returns a [Result] containing the [ConnectRequest] on success,
  /// or an error message on failure.
  Future<Result<ConnectRequest>> getConnectRequestById(String requestId) async {
    final result = await apiService.get(
      '${ApiEndpoints.connectRequests}/$requestId',
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        // Extract connectRequest from response data
        Map<String, dynamic> data;
        if (result.data is Map<String, dynamic>) {
          data = result.data as Map<String, dynamic>;
        } else if (result.data is Map) {
          data = Map<String, dynamic>.from(result.data);
        } else {
          data = <String, dynamic>{};
        }
        
        final connectRequestData = data['connectRequest'] ?? data;
        Map<String, dynamic> requestMap;
        if (connectRequestData is Map<String, dynamic>) {
          requestMap = connectRequestData;
        } else if (connectRequestData is Map) {
          requestMap = Map<String, dynamic>.from(connectRequestData);
        } else {
          requestMap = <String, dynamic>{};
        }
        final connectRequest = ConnectRequest.fromJson(requestMap);
        return Result.success(connectRequest);
      } catch (e) {
        return Result.error('Failed to parse connection request: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch connection request');
    }
  }

  /// Responds to a connection request (accept or reject).
  ///
  /// [action] should be either 'accept' or 'reject'.
  ///
  /// Returns a [Result] containing the updated [ConnectRequest] on success,
  /// or an error message on failure.
  Future<Result<ConnectRequest>> respondToRequest({
    required String requestId,
    required String action,
  }) async {
    final body = {'action': action};

    final result = await apiService.put(
      '${ApiEndpoints.connectRequests}/$requestId/respond',
      body: body,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        // Extract connectRequest from response data
        Map<String, dynamic> data;
        if (result.data is Map<String, dynamic>) {
          data = result.data as Map<String, dynamic>;
        } else if (result.data is Map) {
          data = Map<String, dynamic>.from(result.data);
        } else {
          data = <String, dynamic>{};
        }
        
        final connectRequestData = data['connectRequest'] ?? data;
        Map<String, dynamic> requestMap;
        if (connectRequestData is Map<String, dynamic>) {
          requestMap = connectRequestData;
        } else if (connectRequestData is Map) {
          requestMap = Map<String, dynamic>.from(connectRequestData);
        } else {
          requestMap = <String, dynamic>{};
        }
        final connectRequest = ConnectRequest.fromJson(requestMap);
        return Result.success(connectRequest);
      } catch (e) {
        return Result.error('Failed to parse connection request: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to respond to connection request');
    }
  }

  /// Deletes a connection request.
  ///
  /// Returns a [Result] with success status or an error message on failure.
  Future<Result<void>> deleteConnectRequest(String requestId) async {
    final result = await apiService.delete(
      '${ApiEndpoints.connectRequests}/$requestId',
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      return Result.success(null);
    } else {
      return Result.error(result.message ?? 'Failed to delete connection request');
    }
  }

  /// Fetches contact details for a specific connection request.
  ///
  /// This endpoint is typically available only for accepted requests.
  ///
  /// Returns a [Result] containing [ContactDetails] on success,
  /// or an error message on failure.
  Future<Result<ContactDetails>> getContactDetails(String requestId) async {
    final result = await apiService.get(
      '${ApiEndpoints.connectRequests}/$requestId/contacts',
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final contactDetails = ContactDetails.fromJson(result.data);
        return Result.success(contactDetails);
      } catch (e) {
        return Result.error('Failed to parse contact details: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch contact details');
    }
  }
}

