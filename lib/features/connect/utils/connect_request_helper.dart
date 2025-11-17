// lib/features/connect/utils/connect_request_helper.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/connect_request_bloc.dart';

/// Helper class for ConnectRequest API calls and BLoC interactions.
class ConnectRequestHelper {
  /// Sends a new connection request
  static Future<void> sendRequest({required BuildContext context, required String recipientId, String? customerRequestId, String? tripId, String? message}) async {
    context.read<ConnectRequestBloc>().add(SendConnectRequest(recipientId: recipientId, customerRequestId: customerRequestId, tripId: tripId, message: message));
  }

  /// Fetches all connection requests with optional filters
  static Future<void> fetchRequests({required BuildContext context, String? status, String? type, int? page, int? limit}) async {
    context.read<ConnectRequestBloc>().add(FetchConnectRequests(status: status, type: type, page: page, limit: limit));
  }

  /// Fetches a specific connection request by ID
  static Future<void> fetchRequestById({required BuildContext context, required String requestId}) async {
    context.read<ConnectRequestBloc>().add(FetchConnectRequestById(requestId: requestId));
  }

  /// Responds to a connection request (accept or reject)
  static Future<void> respondToRequest({
    required BuildContext context,
    required String requestId,
    required String action, // 'accept' or 'reject'
  }) async {
    context.read<ConnectRequestBloc>().add(RespondToConnectRequest(requestId: requestId, action: action));
  }

  /// Deletes a connection request
  static Future<void> deleteRequest({required BuildContext context, required String requestId}) async {
    context.read<ConnectRequestBloc>().add(DeleteConnectRequest(requestId: requestId));
  }

  /// Fetches contact details for a connection request
  static Future<void> fetchContactDetails({required BuildContext context, required String requestId}) async {
    context.read<ConnectRequestBloc>().add(FetchContactDetails(requestId: requestId));
  }

  /// Refreshes the connection requests list
  static Future<void> refreshRequests({required BuildContext context, String? status}) async {
    context.read<ConnectRequestBloc>().add(RefreshConnectRequests(status: status));
  }

  /// Helper method to show success message
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
  }

  /// Helper method to show error message
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
  }
}
