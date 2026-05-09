import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

class SettingsService {
  static const _baseUrlKey = 'n8n_base_url';
  static const _apiKeyKey = 'n8n_api_key';

  Future<AppSettings?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_baseUrlKey);
    final key = prefs.getString(_apiKeyKey);
    if (url == null || url.isEmpty || key == null || key.isEmpty) return null;
    return AppSettings.normalized(baseUrl: url, apiKey: key);
  }

  Future<void> save(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, s.baseUrl);
    await prefs.setString(_apiKeyKey, s.apiKey);
  }
}
