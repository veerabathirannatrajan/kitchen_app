import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/kds_config.dart';

class AuthService {
  static const String _usernameKey = 'saved_username';

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  static Future<String> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? '';
  }

  static Future<Map<String, dynamic>?> validateUser({
    required String username,
    required String password,
    String outletCode = 'A1',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${KDSConfig.baseUrl}/ValidateUser'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sUserId': username,
          'sPassword': password,
          'sOutletCode': outletCode,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static bool isLoginSuccessful(Map<String, dynamic>? response) {
    if (response == null) return false;
    return response['LoginStatus'] == 'S';
  }

  static String getErrorMessage(Map<String, dynamic>? response) {
    if (response == null) return 'Connection failed. Check network.';
    return response['ErrDesc']?.toString() ?? 'Login failed.';
  }
}