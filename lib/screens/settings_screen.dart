import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final void Function(AppSettings) onSaved;
  final bool isFirstRun;

  const SettingsScreen({
    super.key,
    required this.onSaved,
    this.isFirstRun = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  bool _obscureKey = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    SettingsService().load().then((s) {
      if (s != null && mounted) {
        _urlCtrl.text = s.baseUrl;
        _keyCtrl.text = s.apiKey;
      }
    });
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final settings = AppSettings.normalized(
      baseUrl: _urlCtrl.text,
      apiKey: _keyCtrl.text,
    );
    await SettingsService().save(settings);
    if (!mounted) return;
    setState(() => _saving = false);
    widget.onSaved(settings);
    if (!widget.isFirstRun) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: !widget.isFirstRun,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Connect to your n8n instance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _urlCtrl,
                decoration: const InputDecoration(
                  labelText: 'n8n Base URL',
                  hintText: 'https://n8n.example.com',
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || !uri.hasScheme) return 'Enter a valid URL';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _keyCtrl,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: 'n8n_api_...',
                  prefixIcon: const Icon(Icons.vpn_key),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureKey ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  ),
                ),
                obscureText: _obscureKey,
                autocorrect: false,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: kOnSurface),
                      )
                    : const Text('Save & Connect'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
