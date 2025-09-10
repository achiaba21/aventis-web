import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  static Future<String?> get token async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString("token");
  }

  static Future<bool> setToken(String token) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString("token", token);
  }
}
