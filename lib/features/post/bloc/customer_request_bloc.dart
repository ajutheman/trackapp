import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../home/model/post.dart';
import '../repo/customer_request_repo.dart';

/// Events for Customer Request BLoC
abstract class CustomerRequestEvent extends Equatable {
  const CustomerRequestEvent();

  @override
  List<Object> get props => [];
}

/// Event to fetch all customer requests
class FetchAllCustomerRequests extends CustomerRequestEvent {
  final String? status;
  final String? search;
  final String? dateFrom;
  final String? dateTo;
  final String? startLocation;
  final String? destination;
  final String? currentLocation;
  final int? page;
  final int? limit;

  const FetchAllCustomerRequests({
    this.status,
    this.search,
    this.dateFrom,
    this.dateTo,
    this.startLocation,
    this.destination,
    this.currentLocation,
    this.page,
    this.limit,
  });

  @override
  List<Object> get props => [
        status ?? '',
        search ?? '',
        dateFrom ?? '',
        dateTo ?? '',
        startLocation ?? '',
        destination ?? '',
        currentLocation ?? '',
        page ?? 0,
        limit ?? 0,
      ];
}

/// Event to fetch user's own customer requests
class FetchMyCustomerRequests extends CustomerRequestEvent {
  final int? page;
  final int? limit;
  final String? status;
  final String? search;
  final String? dateFrom;
  final String? dateTo;

  const FetchMyCustomerRequests({
    this.page,
    this.limit,
    this.status,
    this.search,
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object> get props => [
        page ?? 0,
        limit ?? 0,
        status ?? '',
        search ?? '',
        dateFrom ?? '',
        dateTo ?? '',
      ];
}

/// Event to create a new customer request
class CreateCustomerRequest extends CustomerRequestEvent {
  final String title;
  final String description;
  final TripLocation pickupLocation;
  final TripLocation dropoffLocation;
  final Distance distance;
  final TripDuration duration;
  final PackageDetails packageDetails;
  final List<String> images;
  final List<String>? documents;
  final DateTime? pickupTime;
  final String? status;

  const CreateCustomerRequest({
    required this.title,
    required this.description,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.distance,
    required this.duration,
    required this.packageDetails,
    required this.images,
    this.documents,
    this.pickupTime,
    this.status,
  });

  @override
  List<Object> get props => [
        title,
        description,
        pickupLocation,
        dropoffLocation,
        distance,
        duration,
        packageDetails,
        images,
        documents ?? [],
        pickupTime ?? DateTime.now(),
        status ?? '',
      ];
}

/// Event to update an existing customer request
class UpdateCustomerRequest extends CustomerRequestEvent {
  final String requestId;
  final String? title;
  final String? description;
  final TripLocation? pickupLocation;
  final TripLocation? dropoffLocation;
  final Distance? distance;
  final TripDuration? duration;
  final PackageDetails? packageDetails;
  final List<String>? images;
  final List<String>? documents;
  final DateTime? pickupTime;
  final String? status;

  const UpdateCustomerRequest({
    required this.requestId,
    this.title,
    this.description,
    this.pickupLocation,
    this.dropoffLocation,
    this.distance,
    this.duration,
    this.packageDetails,
    this.images,
    this.documents,
    this.pickupTime,
    this.status,
  });

  @override
  List<Object> get props => [
        requestId,
        title ?? '',
        description ?? '',
        pickupLocation ?? '',
        dropoffLocation ?? '',
        distance ?? '',
        duration ?? '',
        packageDetails ?? '',
        images ?? [],
        documents ?? [],
        pickupTime ?? DateTime.now(),
        status ?? '',
      ];
}

/// Event to delete a customer request
class DeleteCustomerRequest extends CustomerRequestEvent {
  final String requestId;

  const DeleteCustomerRequest({required this.requestId});

  @override
  List<Object> get props => [requestId];
}

/// Event to fetch a specific customer request by ID
class FetchCustomerRequestById extends CustomerRequestEvent {
  final String requestId;

  const FetchCustomerRequestById({required this.requestId});

  @override
  List<Object> get props => [requestId];
}

/// States for Customer Request BLoC
abstract class CustomerRequestState extends Equatable {
  const CustomerRequestState();

  @override
  List<Object> get props => [];
}

/// Initial state
class CustomerRequestInitial extends CustomerRequestState {}

/// Loading state
class CustomerRequestLoading extends CustomerRequestState {}

/// Success state with customer requests data
class CustomerRequestsLoaded extends CustomerRequestState {
  final List<Post> requests;
  final bool hasMore;
  final int currentPage;

  const CustomerRequestsLoaded({
    required this.requests,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object> get props => [requests, hasMore, currentPage];
}

/// Success state for user's own customer requests
class MyCustomerRequestsLoaded extends CustomerRequestState {
  final List<Post> requests;
  final bool hasMore;
  final int currentPage;

  const MyCustomerRequestsLoaded({
    required this.requests,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object> get props => [requests, hasMore, currentPage];
}

/// Success state for customer request creation
class CustomerRequestCreated extends CustomerRequestState {
  final Post request;

  const CustomerRequestCreated({required this.request});

  @override
  List<Object> get props => [request];
}

/// Success state for customer request update
class CustomerRequestUpdated extends CustomerRequestState {
  final Post request;

  const CustomerRequestUpdated({required this.request});

  @override
  List<Object> get props => [request];
}

/// Success state for customer request deletion
class CustomerRequestDeleted extends CustomerRequestState {
  final String requestId;

  const CustomerRequestDeleted({required this.requestId});

  @override
  List<Object> get props => [requestId];
}

/// Success state for fetching a single customer request
class CustomerRequestDetailLoaded extends CustomerRequestState {
  final Post request;

  const CustomerRequestDetailLoaded({required this.request});

  @override
  List<Object> get props => [request];
}

/// Error state
class CustomerRequestError extends CustomerRequestState {
  final String message;

  const CustomerRequestError({required this.message});

  @override
  List<Object> get props => [message];
}

/// BLoC for managing customer request state and events
class CustomerRequestBloc extends Bloc<CustomerRequestEvent, CustomerRequestState> {
  final CustomerRequestRepository repository;

  CustomerRequestBloc({required this.repository}) : super(CustomerRequestInitial()) {
    on<FetchAllCustomerRequests>(_onFetchAllCustomerRequests);
    on<FetchMyCustomerRequests>(_onFetchMyCustomerRequests);
    on<CreateCustomerRequest>(_onCreateCustomerRequest);
    on<UpdateCustomerRequest>(_onUpdateCustomerRequest);
    on<DeleteCustomerRequest>(_onDeleteCustomerRequest);
    on<FetchCustomerRequestById>(_onFetchCustomerRequestById);
  }

  Future<void> _onFetchAllCustomerRequests(
    FetchAllCustomerRequests event,
    Emitter<CustomerRequestState> emit,
  ) async {
    emit(CustomerRequestLoading());

    try {
      final result = await repository.getAllCustomerRequests(
        status: event.status,
        search: event.search,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
        startLocation: event.startLocation,
        destination: event.destination,
        currentLocation: event.currentLocation,
        page: event.page,
        limit: event.limit,
      );

      if (result.isSuccess) {
        emit(CustomerRequestsLoaded(
          requests: result.data!,
          hasMore: result.data!.length >= (event.limit ?? 10),
          currentPage: event.page ?? 1,
        ));
      } else {
        emit(CustomerRequestError(message: result.message!));
      }
    } catch (e) {
      emit(CustomerRequestError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchMyCustomerRequests(
    FetchMyCustomerRequests event,
    Emitter<CustomerRequestState> emit,
  ) async {
    emit(CustomerRequestLoading());

    try {
      final result = await repository.getMyCustomerRequests(
        page: event.page,
        limit: event.limit,
        status: event.status,
        search: event.search,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      if (result.isSuccess) {
        emit(MyCustomerRequestsLoaded(
          requests: result.data!,
          hasMore: result.data!.length >= (event.limit ?? 10),
          currentPage: event.page ?? 1,
        ));
      } else {
        emit(CustomerRequestError(message: result.message!));
      }
    } catch (e) {
      emit(CustomerRequestError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onCreateCustomerRequest(
    CreateCustomerRequest event,
    Emitter<CustomerRequestState> emit,
  ) async {
    emit(CustomerRequestLoading());

    try {
      final result = await repository.createCustomerRequest(
        title: event.title,
        description: event.description,
        pickupLocation: event.pickupLocation,
        dropoffLocation: event.dropoffLocation,
        distance: event.distance,
        duration: event.duration,
        packageDetails: event.packageDetails,
        images: event.images,
        documents: event.documents,
        pickupTime: event.pickupTime,
        status: event.status,
      );

      if (result.isSuccess) {
        emit(CustomerRequestCreated(request: result.data!));
      } else {
        emit(CustomerRequestError(message: result.message!));
      }
    } catch (e) {
      emit(CustomerRequestError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCustomerRequest(
    UpdateCustomerRequest event,
    Emitter<CustomerRequestState> emit,
  ) async {
    emit(CustomerRequestLoading());

    try {
      final result = await repository.updateCustomerRequest(
        requestId: event.requestId,
        title: event.title,
        description: event.description,
        pickupLocation: event.pickupLocation,
        dropoffLocation: event.dropoffLocation,
        distance: event.distance,
        duration: event.duration,
        packageDetails: event.packageDetails,
        images: event.images,
        documents: event.documents,
        pickupTime: event.pickupTime,
        status: event.status,
      );

      if (result.isSuccess) {
        emit(CustomerRequestUpdated(request: result.data!));
      } else {
        emit(CustomerRequestError(message: result.message!));
      }
    } catch (e) {
      emit(CustomerRequestError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCustomerRequest(
    DeleteCustomerRequest event,
    Emitter<CustomerRequestState> emit,
  ) async {
    emit(CustomerRequestLoading());

    try {
      final result = await repository.deleteCustomerRequest(event.requestId);

      if (result.isSuccess) {
        emit(CustomerRequestDeleted(requestId: event.requestId));
      } else {
        emit(CustomerRequestError(message: result.message!));
      }
    } catch (e) {
      emit(CustomerRequestError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchCustomerRequestById(
    FetchCustomerRequestById event,
    Emitter<CustomerRequestState> emit,
  ) async {
    emit(CustomerRequestLoading());

    try {
      final result = await repository.getCustomerRequestById(event.requestId);

      if (result.isSuccess) {
        emit(CustomerRequestDetailLoaded(request: result.data!));
      } else {
        emit(CustomerRequestError(message: result.message!));
      }
    } catch (e) {
      emit(CustomerRequestError(message: 'An error occurred: ${e.toString()}'));
    }
  }
}

