// features/auth/bloc/auth_event.dart

abstract class AuthEvent {}

/// Event to request an OTP be sent to the user's phone.
class SendOTPRequested extends AuthEvent {
  final String phone;

  SendOTPRequested({required this.phone});
}

/// Event to verify the OTP provided by the user, along with the token received after requesting OTP.
class VerifyOTPRequested extends AuthEvent {
  final String otp;
  final String token; // This token is required for the API call as per your AuthRepository

  VerifyOTPRequested({required this.otp, required this.token});
}
