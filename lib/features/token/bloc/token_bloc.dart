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

class FetchTokenTransactions extends TokenEvent {
  final int? page;
  final int? limit;

  const FetchTokenTransactions({this.page, this.limit});

  @override
  List<Object?> get props => [page, limit];
}

class RefreshTokenBalance extends TokenEvent {
  const RefreshTokenBalance();
}

class FetchTokenPlans extends TokenEvent {
  const FetchTokenPlans();
}

class PurchaseTokenPlan extends TokenEvent {
  final String planId;

  const PurchaseTokenPlan({required this.planId});

  @override
  List<Object?> get props => [planId];
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

class TokenTransactionsLoaded extends TokenState {
  final List<TokenTransaction> transactions;
  final bool hasMore;
  final int currentPage;

  const TokenTransactionsLoaded({
    required this.transactions,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [transactions, hasMore, currentPage];
}

class TokenError extends TokenState {
  final String message;

  const TokenError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TokenPlansLoaded extends TokenState {
  final List<TokenPlan> plans;

  const TokenPlansLoaded({required this.plans});

  @override
  List<Object?> get props => [plans];
}

class TokenPurchaseSuccess extends TokenState {
  final double newBalance;
  final int tokensCredited;
  final String planName;

  const TokenPurchaseSuccess({
    required this.newBalance,
    required this.tokensCredited,
    required this.planName,
  });

  @override
  List<Object?> get props => [newBalance, tokensCredited, planName];
}

// ==================== BLOC ====================

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  final TokenRepository repository;

  TokenBloc({required this.repository}) : super(TokenInitial()) {
    on<FetchTokenBalance>(_onFetchTokenBalance);
    on<FetchLeadTokenUsage>(_onFetchLeadTokenUsage);
    on<FetchTokenTransactions>(_onFetchTokenTransactions);
    on<RefreshTokenBalance>(_onRefreshTokenBalance);
    on<FetchTokenPlans>(_onFetchTokenPlans);
    on<PurchaseTokenPlan>(_onPurchaseTokenPlan);
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

  Future<void> _onFetchTokenTransactions(
    FetchTokenTransactions event,
    Emitter<TokenState> emit,
  ) async {
    emit(TokenLoading());

    try {
      final result = await repository.getTransactions(
        page: event.page,
        limit: event.limit,
      );

      if (result.isSuccess) {
        emit(TokenTransactionsLoaded(
          transactions: result.data!,
          hasMore: result.data!.length >= (event.limit ?? 10),
          currentPage: event.page ?? 1,
        ));
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

  Future<void> _onFetchTokenPlans(
    FetchTokenPlans event,
    Emitter<TokenState> emit,
  ) async {
    emit(TokenLoading());

    try {
      final result = await repository.getTokenPlans();

      if (result.isSuccess) {
        emit(TokenPlansLoaded(plans: result.data!));
      } else {
        emit(TokenError(message: result.message!));
      }
    } catch (e) {
      emit(TokenError(message: 'An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onPurchaseTokenPlan(
    PurchaseTokenPlan event,
    Emitter<TokenState> emit,
  ) async {
    emit(TokenLoading());

    try {
      final result = await repository.purchaseTokenPlan(planId: event.planId);

      if (result.isSuccess) {
        final data = result.data as Map<String, dynamic>;
        emit(TokenPurchaseSuccess(
          newBalance: (data['walletBalance'] ?? 0).toDouble(),
          tokensCredited: data['tokensCredited'] ?? 0,
          planName: data['plan']?['name'] ?? 'Token Plan',
        ));
        // Refresh balance after purchase
        add(const FetchTokenBalance());
      } else {
        emit(TokenError(message: result.message!));
      }
    } catch (e) {
      emit(TokenError(message: 'An error occurred: ${e.toString()}'));
    }
  }
}

