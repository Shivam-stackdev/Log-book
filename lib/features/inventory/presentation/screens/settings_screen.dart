import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _currentLanguage = 'en';
  String _aiApiKey = '';
  bool _aiEnabled = false;
  bool _autoAutomate = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final dbHelper = ref.read(databaseHelperProvider);
    final settings = await dbHelper.getAllSettings();
    
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _currentLanguage = settings['language'] ?? prefs.getString('language') ?? 'en';
      _aiApiKey = settings['ai_api_key'] ?? '';
      _aiEnabled = settings['ai_enabled'] == 'true';
      _autoAutomate = settings['ai_auto_automate'] == 'true';
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, String value) async {
    final dbHelper = ref.read(databaseHelperProvider);
    await dbHelper.updateSetting(key, value);
  }

  Future<void> _changeLanguage(String langCode) async {
    setState(() => _currentLanguage = langCode);
    await _saveSetting('language', langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(langCode == 'hi' ? 'भाषा हिन्दी में बदल गई' : 'Language changed to English'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlassAppBar(title: 'Settings'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionHeader('General'),
                const SizedBox(height: 8),
                _buildLanguageSection(),
                const SizedBox(height: 24),
                _buildSectionHeader('AI Integration'),
                const SizedBox(height: 8),
                _buildAISettingsSection(),
                const SizedBox(height: 24),
                _buildSectionHeader('Data Management'),
                const SizedBox(height: 8),
                _buildBackupSection(),
                const SizedBox(height: 24),
                _buildSectionHeader('About'),
                const SizedBox(height: 8),
                _buildAboutSection(),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade800,
        ),
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language, color: Colors.green.shade700),
                const SizedBox(width: 12),
                const Text(
                  'Language / भाषा',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('English'),
              subtitle: const Text('English language'),
              value: 'en',
              groupValue: _currentLanguage,
              activeColor: Colors.green.shade700,
              onChanged: (val) {
                if (val != null) _changeLanguage(val);
              },
            ),
            RadioListTile<String>(
              title: const Text('हिन्दी (Hindi)'),
              subtitle: const Text('Hindi language'),
              value: 'hi',
              groupValue: _currentLanguage,
              activeColor: Colors.green.shade700,
              onChanged: (val) {
                if (val != null) _changeLanguage(val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAISettingsSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy, color: Colors.green.shade700),
                const SizedBox(width: 12),
                const Text(
                  'AI Integration',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // AI Toggle
            SwitchListTile(
              title: const Text('Enable AI'),
              subtitle: const Text('Use AI to automate tasks'),
              value: _aiEnabled,
              activeColor: Colors.green.shade700,
              onChanged: (val) async {
                setState(() => _aiEnabled = val);
                await _saveSetting('ai_enabled', val.toString());
              },
            ),
            // Auto Automate Toggle
            SwitchListTile(
              title: const Text('Auto Automate Tasks'),
              subtitle: const Text('Automatically suggest deductions, stock fill and more'),
              value: _autoAutomate,
              activeColor: Colors.green.shade700,
              onChanged: (val) async {
                setState(() => _autoAutomate = val);
                await _saveSetting('ai_auto_automate', val.toString());
              },
            ),
            const Divider(height: 24),
            // API Key Input
            const Text(
              'OpenAI API Key',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: _aiApiKey),
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'sk-...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    final value = (context.findAncestorStateOfType<_SettingsScreenState>());
                  },
                ),
              ),
              onSubmitted: (val) async {
                setState(() => _aiApiKey = val);
                await _saveSetting('ai_api_key', val);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API Key saved successfully')),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your OpenAI API key to enable AI features. Your key is stored securely on device.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.cloud_upload, color: Colors.green.shade700),
            title: const Text('Create Backup'),
            subtitle: const Text('Export database to a file and share'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup feature available')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.settings_backup_restore, color: Colors.orange.shade700),
            title: const Text('Restore Data'),
            subtitle: const Text('Import database from a backup file'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Restore feature available')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Army Mess Inventory',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text('Version 2.0.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            const Text(
              'A comprehensive inventory management system for Army Mess operations including bill scanning, deduction tracking, officer party management, and AI-powered automation.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
