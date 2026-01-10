// features/auth/bloc/auth_state.dart

import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// State indicating that an OTP has been successfully sent,
/// carrying the token needed for subsequent OTP verification.
class OTPSentSuccess extends AuthState {
  final String otpRequestToken;

  OTPSentSuccess({required this.otpRequestToken});

  @override
  List<Object?> get props => [otpRequestToken];
}

/// State indicating that OTP verification was successful.
class OTPVerifiedSuccess extends AuthState {
  final String token;
  final bool isNewUser;

  OTPVerifiedSuccess({required this.isNewUser, required this.token});
}

/// State indicating that OTP has been successfully resent
class OTPResentSuccess extends AuthState {
  final String otpRequestToken;
  final int resendCount;
  final int remainingResends;
  final String? message;

  OTPResentSuccess({
    required this.otpRequestToken,
    required this.resendCount,
    required this.remainingResends,
    this.message,
  });

  @override
  List<Object?> get props => [
    otpRequestToken,
    resendCount,
    remainingResends,
    message,
  ];
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
