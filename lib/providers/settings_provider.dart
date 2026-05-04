import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>(
  (_) => const SettingsService(FlutterSecureStorage()),
);

class SettingsNotifier extends AsyncNotifier<AppSettings?> {
  @override
  Future<AppSettings?> build() async {
    return ref.read(settingsServiceProvider).load();
  }

  Future<void> save(AppSettings settings) async {
    await ref.read(settingsServiceProvider).save(settings);
    state = AsyncData(settings);
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings?>(
  SettingsNotifier.new,
);
