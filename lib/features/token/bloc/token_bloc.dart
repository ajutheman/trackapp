// lib/features/token/bloc/token_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../model/token.dart';
import '../repo/token_repo.dart';

// ==================== EVENTS ====================

abstract class TokenEvent extends Equatable {
  const TokenEvent();

  @override
  List<Object?> get props => [];
}

class FetchTokenBalance extends TokenEvent {
  const FetchTokenBalance();
}

class FetchLeadTokenUsage extends TokenEvent {
  final double distanceKm;

  const FetchLeadTokenUsage({required this.distanceKm});

  @override
  List<Object?> get props => [distanceKm];
}

class RefreshTokenBalance extends TokenEvent {
  const RefreshTokenBalance();
}

// ==================== STATES ====================

abstract class TokenState extends Equatable {
  const TokenState();

  @override
  List<Object?> get props => [];
}

class TokenInitial extends TokenState {}

class TokenLoading extends TokenState {}

class TokenBalanceLoaded extends TokenState {
  final TokenWallet wallet;

  const TokenBalanceLoaded({required this.wallet});

  @override
  List<Object?> get props => [wallet];
}

class LeadTokenUsageLoaded extends TokenState {
  final LeadTokenUsage usage;

  const LeadTokenUsageLoaded({required this.usage});

  @override
  List<Object?> get props => [usage];
}

class TokenError extends TokenState {
  final String message;

  const TokenError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  final TokenRepository repository;

  TokenBloc({required this.repository}) : super(TokenInitial()) {
    on<FetchTokenBalance>(_onFetchTokenBalance);
    on<FetchLeadTokenUsage>(_onFetchLeadTokenUsage);
    on<RefreshTokenBalance>(_onRefreshTokenBalance);
  }

  Future<void> _onFetchTokenBalance(
    FetchTokenBalance event,
    Emitter<TokenState> emit,
  ) async {
    emit(TokenLoading());

    try {
      final result = await repository.getBalance();

      if (result.isSuccess) {
        emit(TokenBalanceLoaded(wallet: result.data!));
      } else {
        emit(TokenError(message: result.message!));
      }
    } catch (e) {
      emit(TokenError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onFetchLeadTokenUsage(
    FetchLeadTokenUsage event,
    Emitter<TokenState> emit,
  ) async {
    emit(TokenLoading());

    try {
      final result = await repository.getLeadTokenUsage(distanceKm: event.distanceKm);

      if (result.isSuccess) {
        emit(LeadTokenUsageLoaded(usage: result.data!));
      } else {
        emit(TokenError(message: result.message!));
      }
    } catch (e) {
      emit(TokenError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshTokenBalance(
    RefreshTokenBalance event,
    Emitter<TokenState> emit,
  ) async {
    try {
      final result = await repository.getBalance();

      if (result.isSuccess) {
        emit(TokenBalanceLoaded(wallet: result.data!));
      } else {
        emit(TokenError(message: result.message!));
      }
    } catch (e) {
      emit(TokenError(message: 'An error occurred: ${e.toString()}'));
    }
  }
}

