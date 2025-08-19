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
  final bool isNewUser;

  OTPVerifiedSuccess({required this.isNewUser});
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
