import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/settings.dart';

class SettingsService {
  static const _baseUrlKey = 'n8n_base_url';
  static const _apiKeyKey = 'n8n_api_key';

  final FlutterSecureStorage _storage;

  const SettingsService(this._storage);

  Future<AppSettings?> load() async {
    final url = await _storage.read(key: _baseUrlKey);
    final key = await _storage.read(key: _apiKeyKey);
    if (url == null || url.isEmpty || key == null || key.isEmpty) return null;
    return AppSettings.normalized(baseUrl: url, apiKey: key);
  }

  Future<void> save(AppSettings s) async {
    await _storage.write(key: _baseUrlKey, value: s.baseUrl);
    await _storage.write(key: _apiKeyKey, value: s.apiKey);
  }
}
