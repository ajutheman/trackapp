// lib/features/connect/bloc/driver_connection_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../model/driver_connection.dart';
import '../repo/driver_connection_repo.dart';

// ==================== EVENTS ====================

abstract class DriverConnectionEvent extends Equatable {
  const DriverConnectionEvent();

  @override
  List<Object?> get props => [];
}

class SendFriendRequest extends DriverConnectionEvent {
  final String mobileNumber;

  const SendFriendRequest({required this.mobileNumber});

  @override
  List<Object?> get props => [mobileNumber];
}

class FetchFriendRequests extends DriverConnectionEvent {
  final String type; // 'received' or 'sent'

  const FetchFriendRequests({this.type = 'received'});

  @override
  List<Object?> get props => [type];
}

class RespondToFriendRequest extends DriverConnectionEvent {
  final String connectionId;
  final String action; // 'accept' or 'reject'

  const RespondToFriendRequest({
    required this.connectionId,
    required this.action,
  });

  @override
  List<Object?> get props => [connectionId, action];
}

class FetchFriendsList extends DriverConnectionEvent {
  const FetchFriendsList();
}

class RemoveFriend extends DriverConnectionEvent {
  final String connectionId;

  const RemoveFriend({required this.connectionId});

  @override
  List<Object?> get props => [connectionId];
}

class RefreshDriverConnections extends DriverConnectionEvent {
  const RefreshDriverConnections();
}

// ==================== STATES ====================

abstract class DriverConnectionState extends Equatable {
  const DriverConnectionState();

  @override
  List<Object?> get props => [];
}

class DriverConnectionInitial extends DriverConnectionState {}

class DriverConnectionLoading extends DriverConnectionState {}

class FriendRequestsLoaded extends DriverConnectionState {
  final List<DriverConnection> requests;
  final String type;

  const FriendRequestsLoaded({
    required this.requests,
    required this.type,
  });

  @override
  List<Object?> get props => [requests, type];
}

class FriendsListLoaded extends DriverConnectionState {
  final List<DriverFriend> friends;

  const FriendsListLoaded({required this.friends});

  @override
  List<Object?> get props => [friends];
}

class FriendRequestSent extends DriverConnectionState {
  final DriverConnection connection;

  const FriendRequestSent({required this.connection});

  @override
  List<Object?> get props => [connection];
}

class FriendRequestResponded extends DriverConnectionState {
  final DriverConnection connection;
  final String action;

  const FriendRequestResponded({
    required this.connection,
    required this.action,
  });

  @override
  List<Object?> get props => [connection, action];
}

class FriendRemoved extends DriverConnectionState {
  final String connectionId;

  const FriendRemoved({required this.connectionId});

  @override
  List<Object?> get props => [connectionId];
}

class DriverConnectionError extends DriverConnectionState {
  final String message;

  const DriverConnectionError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

class DriverConnectionBloc extends Bloc<DriverConnectionEvent, DriverConnectionState> {
  final DriverConnectionRepository repository;

  DriverConnectionBloc({required this.repository}) : super(DriverConnectionInitial()) {
    on<SendFriendRequest>(_onSendFriendRequest);
    on<FetchFriendRequests>(_onFetchFriendRequests);
    on<RespondToFriendRequest>(_onRespondToFriendRequest);
    on<FetchFriendsList>(_onFetchFriendsList);
    on<RemoveFriend>(_onRemoveFriend);
    on<RefreshDriverConnections>(_onRefreshDriverConnections);
  }

  Future<void> _onSendFriendRequest(
    SendFriendRequest event,
    Emitter<DriverConnectionState> emit,
  ) async {
    emit(DriverConnectionLoading());

    try {
      final result = await repository.sendFriendRequest(event.mobileNumber);

      if (result.isSuccess) {
        emit(FriendRequestSent(connection: result.data!));
      } else {
        emit(DriverConnectionError(message: result.message!));
      }
    } catch (e) {
      emit(DriverConnectionError(message: 'Failed to send friend request: ${e.toString()}'));
    }
  }

  Future<void> _onFetchFriendRequests(
    FetchFriendRequests event,
    Emitter<DriverConnectionState> emit,
  ) async {
    emit(DriverConnectionLoading());

    try {
      final result = await repository.getFriendRequests(type: event.type);

      if (result.isSuccess) {
        emit(FriendRequestsLoaded(requests: result.data!, type: event.type));
      } else {
        emit(DriverConnectionError(message: result.message!));
      }
    } catch (e) {
      emit(DriverConnectionError(message: 'Failed to fetch friend requests: ${e.toString()}'));
    }
  }

  Future<void> _onRespondToFriendRequest(
    RespondToFriendRequest event,
    Emitter<DriverConnectionState> emit,
  ) async {
    emit(DriverConnectionLoading());

    try {
      final result = await repository.respondToFriendRequest(
        connectionId: event.connectionId,
        action: event.action,
      );

      if (result.isSuccess) {
        emit(FriendRequestResponded(connection: result.data!, action: event.action));
      } else {
        emit(DriverConnectionError(message: result.message!));
      }
    } catch (e) {
      emit(DriverConnectionError(message: 'Failed to respond to friend request: ${e.toString()}'));
    }
  }

  Future<void> _onFetchFriendsList(
    FetchFriendsList event,
    Emitter<DriverConnectionState> emit,
  ) async {
    emit(DriverConnectionLoading());

    try {
      final result = await repository.getFriendsList();

      if (result.isSuccess) {
        emit(FriendsListLoaded(friends: result.data!));
      } else {
        emit(DriverConnectionError(message: result.message!));
      }
    } catch (e) {
      emit(DriverConnectionError(message: 'Failed to fetch friends list: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveFriend(
    RemoveFriend event,
    Emitter<DriverConnectionState> emit,
  ) async {
    emit(DriverConnectionLoading());

    try {
      final result = await repository.removeFriend(event.connectionId);

      if (result.isSuccess) {
        emit(FriendRemoved(connectionId: event.connectionId));
      } else {
        emit(DriverConnectionError(message: result.message!));
      }
    } catch (e) {
      emit(DriverConnectionError(message: 'Failed to remove friend: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshDriverConnections(
    RefreshDriverConnections event,
    Emitter<DriverConnectionState> emit,
  ) async {
    // Fetch both friends list and requests
    add(const FetchFriendsList());
    add(const FetchFriendRequests(type: 'received'));
    add(const FetchFriendRequests(type: 'sent'));
  }
}

