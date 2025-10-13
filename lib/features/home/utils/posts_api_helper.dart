import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/features/home/bloc/posts_bloc.dart';
import 'package:truck_app/features/home/model/post.dart';

/// Helper class for Posts API operations
class PostsApiHelper {
  /// Creates a new post/trip with comprehensive trip data
  static Future<void> createPost({
    required BuildContext context,
    required String title,
    required String description,
    String? postType, // 'load' or 'truck'
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
    context.read<PostsBloc>().add(
      CreatePost(
        title: title,
        description: description,
        postType: postType,
        pickupLocation: pickupLocation,
        dropLocation: dropLocation,
        goodsType: goodsType,
        vehicleType: vehicleType,
        imageUrl: imageUrl,
        // Trip-specific fields
        tripStartLocation: tripStartLocation,
        tripDestination: tripDestination,
        viaRoutes: viaRoutes,
        routeGeoJSON: routeGeoJSON,
        vehicle: vehicle,
        selfDrive: selfDrive,
        driver: driver,
        distance: distance,
        duration: duration,
        goodsTypeId: goodsTypeId,
        weight: weight,
        tripStartDate: tripStartDate,
        tripEndDate: tripEndDate,
      ),
    );
  }

  /// Fetches posts with optional filters
  static Future<void> fetchPosts({required BuildContext context, String? postType, String? pickupLocation, String? dropLocation, int? page, int? limit}) async {
    context.read<PostsBloc>().add(FetchAllPosts(postType: postType, pickupLocation: pickupLocation, dropLocation: dropLocation, page: page, limit: limit));
  }

  /// Refreshes posts with current filters
  static Future<void> refreshPosts({required BuildContext context, String? postType, String? pickupLocation, String? dropLocation}) async {
    context.read<PostsBloc>().add(RefreshPosts(postType: postType, pickupLocation: pickupLocation, dropLocation: dropLocation));
  }

  /// Updates an existing post
  static Future<void> updatePost({
    required BuildContext context,
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
    context.read<PostsBloc>().add(
      UpdatePost(
        postId: postId,
        title: title,
        description: description,
        postType: postType,
        pickupLocation: pickupLocation,
        dropLocation: dropLocation,
        goodsType: goodsType,
        vehicleType: vehicleType,
        imageUrl: imageUrl,
        isActive: isActive,
      ),
    );
  }

  /// Deletes a post
  static Future<void> deletePost({required BuildContext context, required String postId}) async {
    context.read<PostsBloc>().add(DeletePost(postId: postId));
  }

  /// Fetches user's own posts
  static Future<void> fetchUserPosts({required BuildContext context, int? page, int? limit}) async {
    context.read<PostsBloc>().add(FetchUserPosts(page: page, limit: limit));
  }
}
