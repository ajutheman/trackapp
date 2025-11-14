// lib/features/connect/bloc/connect_request_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../model/connect_request.dart';
import '../repo/connect_request_repo.dart';

// ==================== EVENTS ====================

abstract class ConnectRequestEvent extends Equatable {
  const ConnectRequestEvent();

  @override
  List<Object?> get props => [];
}

/// Event to send a new connection request
class SendConnectRequest extends ConnectRequestEvent {
  final String recipientId;
  final String? customerRequestId;
  final String? tripId;
  final String? message;

  const SendConnectRequest({
    required this.recipientId,
    this.customerRequestId,
    this.tripId,
    this.message,
  });

  @override
  List<Object?> get props => [recipientId, customerRequestId, tripId, message];
}

/// Event to fetch all connection requests
class FetchConnectRequests extends ConnectRequestEvent {
  final String? status;
  final int? page;
  final int? limit;

  const FetchConnectRequests({this.status, this.page, this.limit});

  @override
  List<Object?> get props => [status, page, limit];
}

/// Event to fetch a specific connection request by ID
class FetchConnectRequestById extends ConnectRequestEvent {
  final String requestId;

  const FetchConnectRequestById({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

/// Event to respond to a connection request (accept/reject)
class RespondToConnectRequest extends ConnectRequestEvent {
  final String requestId;
  final String action; // 'accept' or 'reject'

  const RespondToConnectRequest({
    required this.requestId,
    required this.action,
  });

  @override
  List<Object?> get props => [requestId, action];
}

/// Event to delete a connection request
class DeleteConnectRequest extends ConnectRequestEvent {
  final String requestId;

  const DeleteConnectRequest({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

/// Event to fetch contact details for a connection request
class FetchContactDetails extends ConnectRequestEvent {
  final String requestId;

  const FetchContactDetails({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

/// Event to refresh the connection requests list
class RefreshConnectRequests extends ConnectRequestEvent {
  final String? status;

  const RefreshConnectRequests({this.status});

  @override
  List<Object?> get props => [status];
}

// ==================== STATES ====================

abstract class ConnectRequestState extends Equatable {
  const ConnectRequestState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ConnectRequestInitial extends ConnectRequestState {}

/// Loading state
class ConnectRequestLoading extends ConnectRequestState {}

/// State when connection requests are loaded
class ConnectRequestsLoaded extends ConnectRequestState {
  final List<ConnectRequest> requests;
  final bool hasMore;
  final int currentPage;

  const ConnectRequestsLoaded({
    required this.requests,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [requests, hasMore, currentPage];
}

/// State when a single connection request is loaded
class ConnectRequestDetailLoaded extends ConnectRequestState {
  final ConnectRequest request;

  const ConnectRequestDetailLoaded({required this.request});

  @override
  List<Object?> get props => [request];
}

/// State when a connection request is sent successfully
class ConnectRequestSent extends ConnectRequestState {
  final ConnectRequest request;

  const ConnectRequestSent({required this.request});

  @override
  List<Object?> get props => [request];
}

/// State when a response is sent successfully
class ConnectRequestResponded extends ConnectRequestState {
  final ConnectRequest request;
  final String action;

  const ConnectRequestResponded({
    required this.request,
    required this.action,
  });

  @override
  List<Object?> get props => [request, action];
}

/// State when a connection request is deleted
class ConnectRequestDeleted extends ConnectRequestState {
  final String requestId;

  const ConnectRequestDeleted({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

/// State when contact details are loaded
class ContactDetailsLoaded extends ConnectRequestState {
  final ContactDetails contactDetails;
  final String requestId;

  const ContactDetailsLoaded({
    required this.contactDetails,
    required this.requestId,
  });

  @override
  List<Object?> get props => [contactDetails, requestId];
}

/// Error state
class ConnectRequestError extends ConnectRequestState {
  final String message;

  const ConnectRequestError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

class ConnectRequestBloc extends Bloc<ConnectRequestEvent, ConnectRequestState> {
  final ConnectRequestRepository repository;

  ConnectRequestBloc({required this.repository}) : super(ConnectRequestInitial()) {
    on<SendConnectRequest>(_onSendConnectRequest);
    on<FetchConnectRequests>(_onFetchConnectRequests);
    on<FetchConnectRequestById>(_onFetchConnectRequestById);
    on<RespondToConnectRequest>(_onRespondToConnectRequest);
    on<DeleteConnectRequest>(_onDeleteConnectRequest);
    on<FetchContactDetails>(_onFetchContactDetails);
    on<RefreshConnectRequests>(_onRefreshConnectRequests);
  }

  Future<void> _onSendConnectRequest(
    SendConnectRequest event,
    Emitter<ConnectRequestState> emit,
  ) async {
    emit(ConnectRequestLoading());

    try {
      final result = await repository.sendRequest(
        recipientId: event.recipientId,
        customerRequestId: event.customerRequestId,
        tripId: event.tripId,
        message: event.message,
      );

      if (result.isSuccess) {
        emit(ConnectRequestSent(request: result.data!));
      } else {
        emit(ConnectRequestError(message: result.message!));
      }
    } catch (e) {
      emit(ConnectRequestError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchConnectRequests(
    FetchConnectRequests event,
    Emitter<ConnectRequestState> emit,
  ) async {
    emit(ConnectRequestLoading());

    try {
      final result = await repository.getConnectRequests(
        status: event.status,
        page: event.page,
        limit: event.limit,
      );

      if (result.isSuccess) {
        emit(ConnectRequestsLoaded(
          requests: result.data!,
          hasMore: result.data!.length >= (event.limit ?? 10),
          currentPage: event.page ?? 1,
        ));
      } else {
        emit(ConnectRequestError(message: result.message!));
      }
    } catch (e) {
      emit(ConnectRequestError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchConnectRequestById(
    FetchConnectRequestById event,
    Emitter<ConnectRequestState> emit,
  ) async {
    emit(ConnectRequestLoading());

    try {
      final result = await repository.getConnectRequestById(event.requestId);

      if (result.isSuccess) {
        emit(ConnectRequestDetailLoaded(request: result.data!));
      } else {
        emit(ConnectRequestError(message: result.message!));
      }
    } catch (e) {
      emit(ConnectRequestError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onRespondToConnectRequest(
    RespondToConnectRequest event,
    Emitter<ConnectRequestState> emit,
  ) async {
    emit(ConnectRequestLoading());

    try {
      // First, fetch the current request to validate its status
      final currentRequestResult = await repository.getConnectRequestById(event.requestId);
      
      if (!currentRequestResult.isSuccess) {
        emit(ConnectRequestError(message: currentRequestResult.message ?? 'Failed to fetch request status'));
        return;
      }

      final currentRequest = currentRequestResult.data!;
      
      // Validate that the request is still in a valid state for the action
      if (event.action == 'accept') {
        if (currentRequest.status != ConnectRequestStatus.pending) {
          if (currentRequest.status == ConnectRequestStatus.hold) {
            emit(ConnectRequestError(
              message: 'This request is on hold. Waiting for driver to add tokens. You cannot accept it at this time.'
            ));
          } else {
            emit(ConnectRequestError(
              message: 'This request is no longer pending. Current status: ${currentRequest.status.toString().split('.').last}'
            ));
          }
          return;
        }
      } else if (event.action == 'reject') {
        if (currentRequest.status == ConnectRequestStatus.hold) {
          emit(ConnectRequestError(
            message: 'This request is on hold and cannot be rejected. Waiting for driver to add tokens.'
          ));
          return;
        }
        if (currentRequest.status != ConnectRequestStatus.pending) {
          emit(ConnectRequestError(
            message: 'This request cannot be rejected. Current status: ${currentRequest.status.toString().split('.').last}'
          ));
          return;
        }
      }

      // Proceed with the action
      final result = await repository.respondToRequest(
        requestId: event.requestId,
        action: event.action,
      );

      if (result.isSuccess) {
        emit(ConnectRequestResponded(
          request: result.data!,
          action: event.action,
        ));
      } else {
        emit(ConnectRequestError(message: result.message!));
      }
    } catch (e) {
      emit(ConnectRequestError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteConnectRequest(
    DeleteConnectRequest event,
    Emitter<ConnectRequestState> emit,
  ) async {
    emit(ConnectRequestLoading());

    try {
      final result = await repository.deleteConnectRequest(event.requestId);

      if (result.isSuccess) {
        emit(ConnectRequestDeleted(requestId: event.requestId));
      } else {
        emit(ConnectRequestError(message: result.message!));
      }
    } catch (e) {
      emit(ConnectRequestError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchContactDetails(
    FetchContactDetails event,
    Emitter<ConnectRequestState> emit,
  ) async {
    emit(ConnectRequestLoading());

    try {
      final result = await repository.getContactDetails(event.requestId);

      if (result.isSuccess) {
        emit(ContactDetailsLoaded(
          contactDetails: result.data!,
          requestId: event.requestId,
        ));
      } else {
        emit(ConnectRequestError(message: result.message!));
      }
    } catch (e) {
      emit(ConnectRequestError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshConnectRequests(
    RefreshConnectRequests event,
    Emitter<ConnectRequestState> emit,
  ) async {
    // Refresh without showing loading indicator
    try {
      final result = await repository.getConnectRequests(
        status: event.status,
        page: 1,
        limit: 20,
      );

      if (result.isSuccess) {
        emit(ConnectRequestsLoaded(
          requests: result.data!,
          hasMore: result.data!.length >= 20,
          currentPage: 1,
        ));
      } else {
        emit(ConnectRequestError(message: result.message!));
      }
    } catch (e) {
      emit(ConnectRequestError(message: 'An error occurred: ${e.toString()}'));
    }
  }
}

