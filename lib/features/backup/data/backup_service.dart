import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  Future<void> createBackup() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'army_mess.db');
    final file = File(path);

    if (await file.exists()) {
      final directory = await getTemporaryDirectory();
      final backupPath = join(directory.path, 'army_mess_backup_${DateTime.now().millisecondsSinceEpoch}.db');
      await file.copy(backupPath);
      
      await Share.shareXFiles([XFile(backupPath)], text: 'Army Mess Inventory Backup');
    }
  }

  Future<void> restoreBackup(String backupFilePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'army_mess.db');
    
    final backupFile = File(backupFilePath);
    if (await backupFile.exists()) {
      await backupFile.copy(path);
    }
  }
}
