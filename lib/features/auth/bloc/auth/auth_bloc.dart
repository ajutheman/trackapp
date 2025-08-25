// features/auth/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/constants/app_user_type.dart';

// Removed unused imports like google_sign_in, env_config, local_services
// if they are not used by the remaining OTP-focused logic.
// If you plan to use LocalService for saving tokens after OTP verification,
// you might need to re-add that import and logic in _onVerifyOTPRequested.

import '../../../../services/local/local_services.dart';
import '../../repo/auth_repo.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    // Only listen to OTP-related events
    on<SendOTPRequested>(_onSendOTPRequested);
    on<VerifyOTPRequested>(_onVerifyOTPRequested);
  }

  /// Handles the [SendOTPRequested] event.
  /// Calls the repository to send an OTP and emits [OTPSentSuccess] on success,
  /// carrying the `otpRequestToken` received from the repository.
  Future<void> _onSendOTPRequested(SendOTPRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await repository.sendOTP(event.phone);
      if (result.isSuccess) {
        emit(OTPSentSuccess(otpRequestToken: result.data!)); // Pass the token received from sendOTP
      } else {
        emit(AuthFailure(error: result.message ?? "Failed to send OTP"));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Handles the [VerifyOTPRequested] event.
  /// Calls the repository to verify the OTP, passing the OTP code and the token.
  Future<void> _onVerifyOTPRequested(VerifyOTPRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await repository.verifyOTP(event.otp, event.token); // Use the otp and token from the event
      if (result.isSuccess) {
        // If your verifyOTP API returns tokens to be saved locally after successful verification,
        // you would add that logic here, e.g.:
        bool isNewUser = result.data?['isNewUser'] ?? false;
        String token = result.data?['phoneVerifiedToken'] ?? '';
        if (!isNewUser) {
          await LocalService.saveToken(accessToken: token, isDriver: result.data?['user']['user_type'] == AppUserType.driver);
        }
        emit(OTPVerifiedSuccess(isNewUser: isNewUser, token: token)); // A dedicated state for successful OTP verification
      } else {
        emit(AuthFailure(error: result.message ?? "An unknown error occurred during OTP verification"));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
}
