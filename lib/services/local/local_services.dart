import 'package:shared_preferences/shared_preferences.dart';

class LocalService {
  static const String _accessTokenKey = 'user_token';
  static const String _isDriverKey = 'is_driver';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// Save the access token and driver flag
  static Future<void> saveToken({
    required String accessToken,
    required bool isDriver,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setBool(_isDriverKey, isDriver);
  }

  /// Get the access token
  static Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get the driver flag
  static Future<bool?> getIsDriver() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDriverKey);
  }

  /// Delete access and driver flag
  static Future<void> deleteTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_isDriverKey);
  }

  /// Check if onboarding has been completed
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Mark onboarding as completed
  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }
}
