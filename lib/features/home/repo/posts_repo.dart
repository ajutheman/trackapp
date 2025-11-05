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
  Future<Result<List<Post>>> getAllPosts({String? postType, String? pickupLocation, String? dropLocation, int? page, int? limit}) async {
    final queryParams = <String, dynamic>{};

    if (postType != null) queryParams['postType'] = postType;
    if (pickupLocation != null) queryParams['pickupLocation'] = pickupLocation;
    if (dropLocation != null) queryParams['dropLocation'] = dropLocation;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final result = await apiService.get(ApiEndpoints.getAllPosts, queryParams: queryParams.isNotEmpty ? queryParams : null, isTokenRequired: true);

    if (result.isSuccess) {
      try {
        final List<dynamic> postsData = result.data is List ? result.data : (result.data['posts'] ?? result.data['data'] ?? []);

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
        final List<dynamic> postsData = result.data is List ? result.data : (result.data['trips'] ?? result.data['data'] ?? []);

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
        final Post post = Post.fromJson(result.data as Map<String, dynamic>);
        return Result.success(post);
      } catch (e) {
        return Result.error('Failed to parse created post: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to create post');
    }
  }

  /// Updates an existing post.
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
  }) async {
    final result = await apiService.patch(
      '${ApiEndpoints.updatePost}/$postId',
      body: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (postType != null) 'postType': postType,
        if (pickupLocation != null) 'pickupLocation': pickupLocation,
        if (dropLocation != null) 'dropLocation': dropLocation,
        if (goodsType != null) 'goodsType': goodsType,
        if (vehicleType != null) 'vehicleType': vehicleType,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (isActive != null) 'isActive': isActive,
      },
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final Post post = Post.fromJson(result.data as Map<String, dynamic>);
        return Result.success(post);
      } catch (e) {
        return Result.error('Failed to parse updated post: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to update post');
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
  Future<Result<Post>> getPostById(String postId) async {
    final result = await apiService.get('${ApiEndpoints.getPostById}/$postId', isTokenRequired: true);

    if (result.isSuccess) {
      try {
        // Backend may return trip wrapped in 'trip' key
        final Map<String, dynamic> tripData = result.data is Map ? result.data : (result.data['trip'] ?? result.data);
        final Post post = Post.fromJson(tripData);
        return Result.success(post);
      } catch (e) {
        return Result.error('Failed to parse post data: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch post');
    }
  }

  /// Updates trip status (isActive)
  Future<Result<Post>> updateTripStatus({required String tripId, required bool isActive}) async {
    final result = await apiService.put('${ApiEndpoints.updatePost}/$tripId', body: {'isActive': isActive}, isTokenRequired: true);

    if (result.isSuccess) {
      try {
        // Backend may return trip wrapped in 'trip' key
        final Map<String, dynamic> tripData = result.data is Map ? result.data : (result.data['trip'] ?? result.data);
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
