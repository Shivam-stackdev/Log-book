import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/main.dart';
import 'package:army_mess_inventory/features/backup/data/backup_service.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(themeChangeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backupService = BackupService();

    return Scaffold(
      appBar: const GlassAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Appearance Section
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: isDark ? Colors.amber : Colors.blueGrey,
              ),
              title: const Text('Dark Mode'),
              subtitle: Text(isDark ? 'Dark theme enabled' : 'Light theme enabled'),
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.setDarkMode(val),
              activeColor: Colors.green,
            ),
          ),

          const SizedBox(height: 24),

          // Data Section
          Text(
            'Data & History',
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
                  title: const Text('Monthly History'),
                  subtitle: const Text('View monthly consumption & cost breakdown'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/monthly-history'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.blue),
                  title: const Text('All Transactions'),
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
            'Backup & Restore',
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
                    'Backups include all inventory data, party records, orders, and transaction history.',
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
                  title: const Text('Create Backup'),
                  subtitle: const Text('Export database to a file and share'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    try {
                      await backupService.createBackup();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Backup created successfully')),
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
                  title: const Text('Restore Data'),
                  subtitle: const Text('Import database from a backup file'),
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
            'About',
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
              title: const Text('Army Mess Inventory'),
              subtitle: const Text('Version 2.0.0'),
            ),
          ),
        ],
      ),
    );
  }
}
