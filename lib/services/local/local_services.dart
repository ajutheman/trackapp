import 'package:shared_preferences/shared_preferences.dart';

class LocalService {
  static const String _accessTokenKey = 'user_token';

  /// Save the access
  static Future<void> saveToken({required String accessToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
  }

  /// Get the access token
  static Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Delete access
  static Future<void> deleteTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }
}
