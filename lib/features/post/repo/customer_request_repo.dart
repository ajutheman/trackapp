import '../../../core/constants/api_endpoints.dart';
import '../../../model/network/result.dart';
import '../../../services/network/api_service.dart';
import '../../home/model/post.dart';

/// Repository class for handling customer request (post)-related API calls.
class CustomerRequestRepository {
  final ApiService apiService;

  /// Constructor for CustomerRequestRepository.
  CustomerRequestRepository({required this.apiService});

  /// Fetches all available customer requests from the API.
  ///
  /// Returns a [Result] containing a list of [Post] objects on success,
  /// or an error message on failure.
  Future<Result<List<Post>>> getAllCustomerRequests({
    String? status,
    String? search,
    String? dateFrom,
    String? dateTo,
    String? startLocation,
    String? destination,
    String? currentLocation,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};

    // Location filtering verified:
    // - startLocation and destination use "longitude,latitude" format
    // - Server validates coordinates and handles invalid/missing values gracefully
    // - Null values are excluded (no filter applied)
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['q'] = search;
    if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
    if (dateTo != null) queryParams['dateTo'] = dateTo;
    if (startLocation != null) queryParams['startLocation'] = startLocation;
    if (destination != null) queryParams['destination'] = destination;
    if (currentLocation != null) queryParams['currentLocation'] = currentLocation;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final result = await apiService.get(
      ApiEndpoints.getAllCustomerRequests,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final List<dynamic> requestsData = result.data is List
            ? result.data
            : (result.data['requests'] ?? result.data['data'] ?? []);

        final List<Post> requests = requestsData
            .map((requestJson) => Post.fromJson(requestJson as Map<String, dynamic>))
            .toList();

        return Result.success(requests);
      } catch (e) {
        return Result.error('Failed to parse customer requests data: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch customer requests');
    }
  }

  /// Fetches customer requests created by the current user.
  Future<Result<List<Post>>> getMyCustomerRequests({
    int? page,
    int? limit,
    String? status,
    String? search,
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['q'] = search;
    if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
    if (dateTo != null) queryParams['dateTo'] = dateTo;

    final result = await apiService.get(
      ApiEndpoints.getMyCustomerRequests,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        // Backend returns requests directly as a list, or wrapped in data
        final List<dynamic> requestsData = result.data is List
            ? result.data
            : (result.data['requests'] ?? result.data['data'] ?? []);

        final List<Post> requests = requestsData
            .map((requestJson) => Post.fromJson(requestJson as Map<String, dynamic>))
            .toList();

        return Result.success(requests);
      } catch (e) {
        return Result.error('Failed to parse my customer requests data: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch my customer requests');
    }
  }

  /// Creates a new customer request with comprehensive data.
  Future<Result<Post>> createCustomerRequest({
    required String title,
    required String description,
    required TripLocation pickupLocation,
    required TripLocation dropoffLocation,
    required Distance distance,
    required TripDuration duration,
    required PackageDetails packageDetails,
    required List<String> images,
    List<String>? documents,
    DateTime? pickupTime,
    String? status,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
      'pickupLocation': pickupLocation.toJson(),
      'dropoffLocation': dropoffLocation.toJson(),
      'distance': distance.toJson(),
      'duration': duration.toJson(),
      'packageDetails': packageDetails.toJson(),
      'images': images,
      if (documents != null && documents.isNotEmpty) 'documents': documents,
      if (pickupTime != null) 'pickupTime': pickupTime.toIso8601String(),
      if (status != null) 'status': status,
    };

    final result = await apiService.post(
      ApiEndpoints.createCustomerRequest,
      body: body,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final requestData = result.data is Map
            ? result.data
            : (result.data['request'] ?? result.data);
        final Post request = Post.fromJson(requestData as Map<String, dynamic>);
        return Result.success(request);
      } catch (e) {
        return Result.error('Failed to parse created customer request: ${e.toString()}');
      }
    } else {
      return Result.error(
        result.message ?? 'Failed to create customer request',
        errors: result.errors,
      );
    }
  }

  /// Updates an existing customer request.
  Future<Result<Post>> updateCustomerRequest({
    required String requestId,
    String? title,
    String? description,
    TripLocation? pickupLocation,
    TripLocation? dropoffLocation,
    Distance? distance,
    TripDuration? duration,
    PackageDetails? packageDetails,
    List<String>? images,
    List<String>? documents,
    DateTime? pickupTime,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (pickupLocation != null) body['pickupLocation'] = pickupLocation.toJson();
    if (dropoffLocation != null) body['dropoffLocation'] = dropoffLocation.toJson();
    if (distance != null) body['distance'] = distance.toJson();
    if (duration != null) body['duration'] = duration.toJson();
    if (packageDetails != null) body['packageDetails'] = packageDetails.toJson();
    if (images != null) body['images'] = images;
    if (documents != null) body['documents'] = documents;
    if (pickupTime != null) body['pickupTime'] = pickupTime.toIso8601String();
    if (status != null) body['status'] = status;

    final result = await apiService.put(
      '${ApiEndpoints.updateCustomerRequest}/$requestId',
      body: body,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final requestData = result.data is Map
            ? result.data
            : (result.data['request'] ?? result.data);
        final Post request = Post.fromJson(requestData as Map<String, dynamic>);
        return Result.success(request);
      } catch (e) {
        return Result.error('Failed to parse updated customer request: ${e.toString()}');
      }
    } else {
      return Result.error(
        result.message ?? 'Failed to update customer request',
        errors: result.errors,
      );
    }
  }

  /// Deletes a customer request.
  Future<Result<bool>> deleteCustomerRequest(String requestId) async {
    final result = await apiService.delete(
      '${ApiEndpoints.deleteCustomerRequest}/$requestId',
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      return Result.success(true);
    } else {
      return Result.error(result.message ?? 'Failed to delete customer request');
    }
  }

  /// Fetches a specific customer request by ID.
  Future<Result<Post>> getCustomerRequestById(String requestId) async {
    final result = await apiService.get(
      '${ApiEndpoints.getCustomerRequestById}/$requestId',
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        // Backend may return request wrapped in 'request' key
        final Map<String, dynamic> requestData = result.data is Map
            ? result.data
            : (result.data['request'] ?? result.data);
        final Post request = Post.fromJson(requestData);
        return Result.success(request);
      } catch (e) {
        return Result.error('Failed to parse customer request data: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch customer request');
    }
  }
}

