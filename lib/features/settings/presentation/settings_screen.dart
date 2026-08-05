import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/core/theme/app_theme.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';
import 'package:army_mess_inventory/core/utils/app_localizations.dart';
import 'package:army_mess_inventory/core/logging/logger.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _currentLanguage = 'en';
  String _apiKey = '';
  bool _aiEnabled = false;
  bool _autoAutomate = false;
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'en';
      _apiKeyController.text = prefs.getString('openai_api_key') ?? '';
      _apiKey = _apiKeyController.text;
      _aiEnabled = prefs.getBool('ai_enabled') ?? false;
      _autoAutomate = prefs.getBool('auto_automate') ?? false;
    });
  }

  Future<void> _saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    setState(() => _currentLanguage = langCode);
    AppLogger.i('Settings', 'Language changed to $langCode');
  }

  Future<void> _saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('openai_api_key', key);
    setState(() => _apiKey = key);
    AppLogger.i('Settings', 'API key saved');
  }

  Future<void> _toggleAI(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ai_enabled', enabled);
    setState(() => _aiEnabled = enabled);
  }

  Future<void> _toggleAutoAutomate(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_automate', enabled);
    setState(() => _autoAutomate = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('settings'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _buildSectionHeader(l10n.translate('language')),
        Card(child: Column(children: [
          SwitchListTile(title: Text(l10n.translate('english')), value: _currentLanguage == 'en', onChanged: (_) => _saveLanguage(_currentLanguage == 'en' ? 'hi' : 'en')),
          const Divider(height: 1),
          SwitchListTile(title: Text(l10n.translate('hindi')), value: _currentLanguage == 'hi', onChanged: (_) => _saveLanguage(_currentLanguage == 'hi' ? 'en' : 'hi')),
        ])),
        const SizedBox(height: 24),
        _buildSectionHeader(l10n.translate('ai_settings')),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          SwitchListTile(title: Text(l10n.translate('ai_enabled')), subtitle: const Text('Enable AI-powered suggestions'), value: _aiEnabled, onChanged: _toggleAI, contentPadding: EdgeInsets.zero),
          const SizedBox(height: 12),
          TextField(controller: _apiKeyController, decoration: InputDecoration(labelText: l10n.translate('ai_api_key'), hintText: 'sk-...', suffixIcon: IconButton(icon: const Icon(Icons.save), onPressed: () => _saveApiKey(_apiKeyController.text))), obscureText: true, onSubmitted: _saveApiKey),
          const SizedBox(height: 12),
          SwitchListTile(title: const Text('Auto Automate Tasks'), subtitle: const Text('AI automatically suggests actions'), value: _autoAutomate, onChanged: _toggleAutoAutomate, contentPadding: EdgeInsets.zero),
        ]))),
        const SizedBox(height: 24),
        _buildSectionHeader('Database'),
        Card(child: Column(children: [
          ListTile(leading: const Icon(Icons.backup), title: const Text('Backup Data'), subtitle: const Text('Export all data as JSON'), onTap: _backupData),
          const Divider(height: 1),
          ListTile(leading: const Icon(Icons.restore, color: AppColors.error), title: const Text('Clear All Data', style: TextStyle(color: AppColors.error)), subtitle: const Text('This cannot be undone'), onTap: _clearData),
        ])),
      ]),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)));
  }

  Future<void> _backupData() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final db = await dbHelper.database;
      final tables = ['items', 'officers', 'stock_entries', 'deduction_entries', 'party_entries', 'party_items'];
      int totalRecords = 0;
      for (var table in tables) {
        final rows = await db.query(table);
        totalRecords += rows.length;
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup created: $totalRecords records')));
      AppLogger.i('Settings', 'Data backed up: $totalRecords records');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup failed: $e'), backgroundColor: AppColors.error));
    }
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(title: const Text('Clear All Data'), content: const Text('This will delete all items, officers, and transactions. This cannot be undone.'), actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.error), onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear All')),
      ]),
    );
    if (confirmed == true) {
      try {
        final dbHelper = DatabaseHelper.instance;
        final db = await dbHelper.database;
        for (var table in ['party_items', 'stock_entries', 'deduction_entries', 'party_entries', 'items', 'officers']) {
          await db.delete(table);
        }
        ref.read(inventoryListProvider.notifier).refresh();
        ref.read(officerListProvider.notifier).refresh();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error));
      }
    }
  }
}
