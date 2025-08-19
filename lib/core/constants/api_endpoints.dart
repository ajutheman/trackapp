class ApiEndpoints {
  static const String baseDevelopmentUrl = 'https://truck-api-qyew.onrender.com/';
  static const String baseProductionUrl = 'https://truck-api-qyew.onrender.com/';

  static const String baseUrl = baseProductionUrl;

  static const String sendOTP = 'api/v1/auth/request-otp';
  static const String verifyOTP = 'api/v1/auth/verify-otp';
  static const String registerProfile = 'api/v1/users/profile';
}
