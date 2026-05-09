import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'models/settings.dart';
import 'screens/settings_screen.dart';
import 'screens/workflows_screen.dart';
import 'services/settings_service.dart';

void main() {
  runApp(const N8nMonitorApp());
}

class N8nMonitorApp extends StatelessWidget {
  const N8nMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'n8n Monitor',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      home: const _HomeGate(),
    );
  }
}

class _HomeGate extends StatefulWidget {
  const _HomeGate();

  @override
  State<_HomeGate> createState() => _HomeGateState();
}

class _HomeGateState extends State<_HomeGate> {
  bool _loading = true;
  AppSettings? _settings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await SettingsService().load();
    if (mounted) setState(() { _settings = s; _loading = false; });
  }

  void _onSettingsSaved(AppSettings s) {
    setState(() => _settings = s);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_settings == null) {
      return SettingsScreen(onSaved: _onSettingsSaved, isFirstRun: true);
    }
    return WorkflowsScreen(
      settings: _settings!,
      onSettingsSaved: _onSettingsSaved,
    );
  }
}
