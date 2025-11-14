import '../../../core/constants/api_endpoints.dart';
import '../../../model/network/result.dart';
import '../../../services/network/api_service.dart';
import '../model/post.dart';

/// Repository class for handling posts/trips-related API calls.
class PostsRepository {
  final ApiService apiService;

  /// Constructor for PostsRepository.
  PostsRepository({required this.apiService});

  /// Fetches all available posts/trips from the API.
  ///
  /// Returns a [Result] containing a list of [Post] objects on success,
  /// or an error message on failure.
  Future<Result<List<Post>>> getAllPosts({
    String? postType,
    String? pickupLocation,
    String? dropoffLocation,
    String? currentLocation,
    bool? pickupDropoffBoth,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};

    if (postType != null) queryParams['postType'] = postType;
    if (pickupLocation != null) queryParams['pickupLocation'] = pickupLocation;
    if (dropoffLocation != null) queryParams['dropoffLocation'] = dropoffLocation;
    if (currentLocation != null) queryParams['currentLocation'] = currentLocation;
    if (pickupDropoffBoth != null) queryParams['pickupDropoffBoth'] = pickupDropoffBoth.toString();
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final result = await apiService.get(ApiEndpoints.getAllPosts, queryParams: queryParams.isNotEmpty ? queryParams : null, isTokenRequired: true);

    if (result.isSuccess) {
      try {
        // Backend returns trips directly as a list, or wrapped in data
        final Map<String, dynamic>? responseData = result.data is Map ? result.data as Map<String, dynamic> : null;
        final List<dynamic> postsData = result.data is List 
            ? result.data 
            : (responseData?['data'] ?? responseData?['trips'] ?? []);

        final List<Post> posts = postsData.map((postJson) => Post.fromJson(postJson as Map<String, dynamic>)).toList();

        return Result.success(posts);
      } catch (e) {
        return Result.error('Failed to parse posts data: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch posts');
    }
  }

  /// Fetches posts created by the current user.
  Future<Result<List<Post>>> getUserPosts({int? page, int? limit, String? status, String? search, String? dateFrom, String? dateTo, bool? includeAssigned}) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;
    if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
    if (dateTo != null) queryParams['dateTo'] = dateTo;
    if (includeAssigned != null) queryParams['includeAssigned'] = includeAssigned.toString();

    final result = await apiService.get(ApiEndpoints.getUserPosts, queryParams: queryParams.isNotEmpty ? queryParams : null, isTokenRequired: true);

    if (result.isSuccess) {
      try {
        // Backend returns trips directly as a list, or wrapped in data
        final Map<String, dynamic>? responseData = result.data is Map ? result.data as Map<String, dynamic> : null;
        final List<dynamic> postsData = result.data is List 
            ? result.data 
            : (responseData?['data'] ?? responseData?['trips'] ?? []);

        final List<Post> posts = postsData.map((postJson) => Post.fromJson(postJson as Map<String, dynamic>)).toList();

        return Result.success(posts);
      } catch (e) {
        return Result.error('Failed to parse user posts data: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch user posts');
    }
  }

  /// Creates a new post/trip with comprehensive trip data.
  Future<Result<Post>> createPost({
    required String title,
    required String description,
    String? postType,
    String? pickupLocation,
    String? dropLocation,
    String? goodsType,
    String? vehicleType,
    String? imageUrl,
    // Trip-specific parameters
    TripLocation? tripStartLocation,
    TripLocation? tripDestination,
    List<TripLocation>? viaRoutes,
    RouteGeoJSON? routeGeoJSON,
    String? vehicle,
    bool? selfDrive,
    String? driver,
    Distance? distance,
    TripDuration? duration,
    String? goodsTypeId,
    double? weight,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
      if (postType != null) 'postType': postType,
      if (pickupLocation != null) 'pickupLocation': pickupLocation,
      if (dropLocation != null) 'dropLocation': dropLocation,
      if (goodsType != null) 'goodsType': goodsType,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'isActive': true,
      // Trip-specific fields
      if (tripStartLocation != null) 'tripStartLocation': tripStartLocation.toJson(),
      if (tripDestination != null) 'tripDestination': tripDestination.toJson(),
      if (viaRoutes != null) 'viaRoutes': viaRoutes.map((route) => route.toJson()).toList(),
      if (routeGeoJSON != null) 'routeGeoJSON': routeGeoJSON.toJson(),
      if (vehicle != null) 'vehicle': vehicle,
      if (selfDrive != null) 'selfDrive': selfDrive,
      if (driver != null) 'driver': driver,
      if (distance != null) 'distance': distance.toJson(),
      if (duration != null) 'duration': duration.toJson(),
      if (goodsTypeId != null) 'goodsType': goodsTypeId,
      if (weight != null) 'weight': weight,
      if (tripStartDate != null) 'tripStartDate': tripStartDate.toIso8601String(),
      if (tripEndDate != null) 'tripEndDate': tripEndDate.toIso8601String(),
    };

    final result = await apiService.post(ApiEndpoints.createPost, body: body, isTokenRequired: true);

    if (result.isSuccess) {
      try {
        // Backend returns { trip: {...}, tokensDeducted: ..., tripDistance: ... }
        final Map<String, dynamic> responseData = result.data is Map ? result.data as Map<String, dynamic> : {};
        final Map<String, dynamic> tripData = responseData['trip'] ?? responseData;
        final Post post = Post.fromJson(tripData);
        return Result.success(post);
      } catch (e) {
        return Result.error('Failed to parse created post: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to create post');
    }
  }

  /// Updates an existing post/trip with comprehensive trip data.
  Future<Result<Post>> updatePost({
    required String postId,
    String? title,
    String? description,
    String? postType,
    String? pickupLocation,
    String? dropLocation,
    String? goodsType,
    String? vehicleType,
    String? imageUrl,
    bool? isActive,
    // Trip-specific parameters
    TripLocation? tripStartLocation,
    TripLocation? tripDestination,
    List<TripLocation>? viaRoutes,
    RouteGeoJSON? routeGeoJSON,
    String? vehicle,
    bool? selfDrive,
    String? driver,
    Distance? distance,
    TripDuration? duration,
    String? goodsTypeId,
    double? weight,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
  }) async {
    final body = <String, dynamic>{
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (postType != null) 'postType': postType,
      if (pickupLocation != null) 'pickupLocation': pickupLocation,
      if (dropLocation != null) 'dropLocation': dropLocation,
      if (goodsType != null) 'goodsType': goodsType,
      if (vehicleType != null) 'vehicleType': vehicleType,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (isActive != null) 'isActive': isActive,
      // Trip-specific fields
      if (tripStartLocation != null) 'tripStartLocation': tripStartLocation.toJson(),
      if (tripDestination != null) 'tripDestination': tripDestination.toJson(),
      if (viaRoutes != null) 'viaRoutes': viaRoutes.map((route) => route.toJson()).toList(),
      if (routeGeoJSON != null) 'routeGeoJSON': routeGeoJSON.toJson(),
      if (vehicle != null) 'vehicle': vehicle,
      if (selfDrive != null) 'selfDrive': selfDrive,
      if (driver != null) 'driver': driver,
      if (distance != null) 'distance': distance.toJson(),
      if (duration != null) 'duration': duration.toJson(),
      if (goodsTypeId != null) 'goodsType': goodsTypeId,
      if (weight != null) 'weight': weight,
      if (tripStartDate != null) 'tripStartDate': tripStartDate.toIso8601String(),
      if (tripEndDate != null) 'tripEndDate': tripEndDate.toIso8601String(),
    };

    // Try trip endpoint first
    var result = await apiService.put(
      '${ApiEndpoints.updatePost}/$postId',
      body: body,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        // Backend returns { trip: {...}, tokenChange: ... }
        final Map<String, dynamic> responseData = result.data is Map ? result.data as Map<String, dynamic> : {};
        final Map<String, dynamic> tripData = responseData['trip'] ?? responseData;
        final Post post = Post.fromJson(tripData);
        return Result.success(post);
      } catch (e) {
        // If parsing fails, try customer request endpoint
        return await _updateCustomerRequest(postId, body);
      }
    } else {
      // If trip endpoint fails, try customer request endpoint
      return await _updateCustomerRequest(postId, body);
    }
  }

  /// Helper to update customer request
  Future<Result<Post>> _updateCustomerRequest(String requestId, Map<String, dynamic> body) async {
    // Convert trip fields to customer request fields if needed
    final customerRequestBody = <String, dynamic>{};
    
    // Map trip fields to customer request fields
    if (body.containsKey('tripStartLocation')) {
      customerRequestBody['pickupLocation'] = body['tripStartLocation'];
    }
    if (body.containsKey('tripDestination')) {
      customerRequestBody['dropoffLocation'] = body['tripDestination'];
    }
    
    // Copy other common fields
    if (body.containsKey('title')) customerRequestBody['title'] = body['title'];
    if (body.containsKey('description')) customerRequestBody['description'] = body['description'];
    if (body.containsKey('packageDetails')) customerRequestBody['packageDetails'] = body['packageDetails'];
    if (body.containsKey('images')) customerRequestBody['images'] = body['images'];
    if (body.containsKey('documents')) customerRequestBody['documents'] = body['documents'];
    if (body.containsKey('pickupTime')) customerRequestBody['pickupTime'] = body['pickupTime'];
    if (body.containsKey('distance')) customerRequestBody['distance'] = body['distance'];
    if (body.containsKey('duration')) customerRequestBody['duration'] = body['duration'];

    final result = await apiService.put(
      '${ApiEndpoints.updateCustomerRequest}/$requestId',
      body: customerRequestBody,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        // Backend returns { request: {...} }
        final Map<String, dynamic> responseData = result.data is Map ? result.data as Map<String, dynamic> : {};
        final Map<String, dynamic> requestData = responseData['request'] ?? responseData;
        final Post post = Post.fromJson(requestData);
        return Result.success(post);
      } catch (e) {
        return Result.error('Failed to parse updated customer request: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to update customer request');
    }
  }

  /// Deletes a post.
  Future<Result<bool>> deletePost(String postId) async {
    final result = await apiService.delete('${ApiEndpoints.deletePost}/$postId', isTokenRequired: true);

    if (result.isSuccess) {
      return Result.success(true);
    } else {
      return Result.error(result.message ?? 'Failed to delete post');
    }
  }

  /// Fetches a specific post by ID.
  /// Tries trip endpoint first, then customer request endpoint if trip fails
  Future<Result<Post>> getPostById(String postId) async {
    // Try trip endpoint first
    var result = await apiService.get('${ApiEndpoints.getPostById}/$postId', isTokenRequired: true);

    if (result.isSuccess) {
      try {
        // Backend returns { trip: {...}, bookings: [...] }
        final Map<String, dynamic> responseData = result.data is Map ? result.data as Map<String, dynamic> : {};
        final Map<String, dynamic> tripData = responseData['trip'] ?? responseData;
        final Post post = Post.fromJson(tripData);
        return Result.success(post);
      } catch (e) {
        // If parsing fails, try customer request endpoint
        return await _getCustomerRequestById(postId);
      }
    } else {
      // If trip endpoint fails, try customer request endpoint
      return await _getCustomerRequestById(postId);
    }
  }

  /// Helper to fetch customer request by ID
  Future<Result<Post>> _getCustomerRequestById(String requestId) async {
    final result = await apiService.get('${ApiEndpoints.getCustomerRequestById}/$requestId', isTokenRequired: true);

    if (result.isSuccess) {
      try {
        // Backend returns { request: {...} }
        final Map<String, dynamic> responseData = result.data is Map ? result.data as Map<String, dynamic> : {};
        final Map<String, dynamic> requestData = responseData['request'] ?? responseData;
        final Post post = Post.fromJson(requestData);
        return Result.success(post);
      } catch (e) {
        return Result.error('Failed to parse customer request data: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch customer request');
    }
  }

  /// Updates trip status (isActive)
  Future<Result<Post>> updateTripStatus({required String tripId, required bool isActive}) async {
    final result = await apiService.put('${ApiEndpoints.updatePost}/$tripId', body: {'isActive': isActive}, isTokenRequired: true);

    if (result.isSuccess) {
      try {
        // Backend may return trip wrapped in 'trip' key
        final Map<String, dynamic> responseData = result.data is Map ? result.data as Map<String, dynamic> : {};
        final Map<String, dynamic> tripData = responseData['trip'] ?? responseData;
        final Post post = Post.fromJson(tripData);
        return Result.success(post);
      } catch (e) {
        return Result.error('Failed to parse updated trip: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to update trip status');
    }
  }
}
