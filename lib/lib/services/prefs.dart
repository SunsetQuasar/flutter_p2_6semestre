import 'package:shared_preferences/shared_preferences.dart';

sealed class Prefs {
  static Future<void> salvarTema(bool light) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lightTheme', light);
  }

  static Future<bool?> carregarTema() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('lightTheme');
  }
}
