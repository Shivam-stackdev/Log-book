import 'package:flutter/material.dart';
import 'package:army_mess_inventory/features/backup/data/backup_service.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backupService = BackupService();

    return Scaffold(
      appBar: const GlassAppBar(title: 'Backup & Restore'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const GlassContainer(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Backups include all inventory data, officer records, and transaction history.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.cloud_upload, color: Colors.green),
              title: const Text('Create Backup'),
              subtitle: const Text('Export database to a file and share'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                try {
                  await backupService.createBackup();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup created successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup failed: $e')),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore, color: Colors.orange),
              title: const Text('Restore Data'),
              subtitle: const Text('Import database from a backup file'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Implement file picker and restore logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Restore functionality requires file picker integration')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
