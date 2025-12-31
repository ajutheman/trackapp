import 'package:flutter/material.dart';
// Force refresh
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/model/post.dart';
import '../bloc/customer_request_bloc.dart';

/// Helper class for Customer Request API calls and BLoC interactions.
class CustomerRequestHelper {
  /// Creates a new customer request
  static Future<void> createRequest({
    required BuildContext context,
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
    RouteGeoJSON? routeGeoJSON,
  }) async {
    context.read<CustomerRequestBloc>().add(
      CreateCustomerRequest(
        title: title,
        description: description,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        distance: distance,
        duration: duration,
        packageDetails: packageDetails,
        images: images,
        documents: documents,
        pickupTime: pickupTime,
        status: status,
        routeGeoJSON: routeGeoJSON,
      ),
    );
  }

  /// Fetches all customer requests with optional filters
  static Future<void> fetchRequests({
    required BuildContext context,
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
    context.read<CustomerRequestBloc>().add(
      FetchAllCustomerRequests(
        status: status,
        search: search,
        dateFrom: dateFrom,
        dateTo: dateTo,
        startLocation: startLocation,
        destination: destination,
        currentLocation: currentLocation,
        page: page,
        limit: limit,
      ),
    );
  }

  /// Fetches user's own customer requests
  static Future<void> fetchMyRequests({
    required BuildContext context,
    int? page,
    int? limit,
    String? status,
    String? search,
    String? dateFrom,
    String? dateTo,
  }) async {
    context.read<CustomerRequestBloc>().add(
      FetchMyCustomerRequests(
        page: page,
        limit: limit,
        status: status,
        search: search,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
    );
  }

  /// Updates an existing customer request
  static Future<void> updateRequest({
    required BuildContext context,
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
    RouteGeoJSON? routeGeoJSON,
  }) async {
    context.read<CustomerRequestBloc>().add(
      UpdateCustomerRequest(
        requestId: requestId,
        title: title,
        description: description,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        distance: distance,
        duration: duration,
        packageDetails: packageDetails,
        images: images,
        documents: documents,
        pickupTime: pickupTime,
        status: status,
        routeGeoJSON: routeGeoJSON,
      ),
    );
  }

  /// Deletes a customer request
  static Future<void> deleteRequest({
    required BuildContext context,
    required String requestId,
  }) async {
    context.read<CustomerRequestBloc>().add(
      DeleteCustomerRequest(requestId: requestId),
    );
  }

  /// Fetches a specific customer request by ID
  static Future<void> fetchRequestById({
    required BuildContext context,
    required String requestId,
  }) async {
    context.read<CustomerRequestBloc>().add(
      FetchCustomerRequestById(requestId: requestId),
    );
  }
}
