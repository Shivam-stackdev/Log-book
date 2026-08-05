import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/main.dart';
import 'package:army_mess_inventory/features/backup/data/backup_service.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/core/utils/app_localizations.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(themeChangeProvider);
    final localeProvider = ref.watch(localeChangeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backupService = BackupService();
    final l10n = AppLocalizations(localeProvider.locale);

    return Scaffold(
      appBar: GlassAppBar(title: l10n.translate('settings')),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Appearance Section
          Text(
            l10n.translate('appearance'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? Colors.amber : Colors.blueGrey,
                  ),
                  title: Text(l10n.translate('dark_mode')),
                  subtitle: Text(isDark ? l10n.translate('dark_theme_enabled') : l10n.translate('light_theme_enabled')),
                  value: themeProvider.isDarkMode,
                  onChanged: (val) => themeProvider.setDarkMode(val),
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Language Section
          Text(
            l10n.translate('language'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(l10n.translate('english')),
                  value: 'en',
                  groupValue: localeProvider.locale.languageCode,
                  onChanged: (val) {
                    if (val != null) localeProvider.setLocale(Locale(val));
                  },
                  secondary: const Icon(Icons.language, color: Colors.blue),
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: Text(l10n.translate('hindi')),
                  value: 'hi',
                  groupValue: localeProvider.locale.languageCode,
                  onChanged: (val) {
                    if (val != null) localeProvider.setLocale(Locale(val));
                  },
                  secondary: const Icon(Icons.translate, color: Colors.orange),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data Section
          Text(
            l10n.translate('data_history'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_month, color: Colors.purple),
                  title: Text(l10n.translate('monthly_history')),
                  subtitle: const Text('View monthly consumption & cost breakdown'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/monthly-history'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.blue),
                  title: Text(l10n.translate('all_transactions')),
                  subtitle: const Text('View complete transaction history'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/history'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Backup Section
          Text(
            l10n.translate('backup_restore'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.translate('backup_info'),
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_upload, color: Colors.green),
                  title: Text(l10n.translate('create_backup')),
                  subtitle: Text(l10n.translate('export_backup')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    try {
                      await backupService.createBackup();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.translate('create_backup') + ' successful')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Backup failed: $e')),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_backup_restore, color: Colors.orange),
                  title: Text(l10n.translate('restore_data')),
                  subtitle: Text(l10n.translate('import_backup')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Restore functionality requires file picker integration')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          Text(
            l10n.translate('about'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.military_tech, color: Colors.amber),
              title: Text(l10n.translate('app_name')),
              subtitle: Text(l10n.translate('version')),
            ),
          ),
        ],
      ),
    );
  }
}
