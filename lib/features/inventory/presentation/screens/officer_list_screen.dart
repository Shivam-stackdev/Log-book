import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/officer_entity.dart';
import 'package:uuid/uuid.dart';

class OfficerListScreen extends ConsumerWidget {
  const OfficerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final officersAsync = ref.watch(officerListProvider);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Officers Messing',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddOfficerDialog(context, ref),
          ),
        ],
      ),
      body: officersAsync.when(
        data: (officers) {
          if (officers.isEmpty) {
            return const Center(child: Text('No officers registered'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: officers.length,
            itemBuilder: (context, index) {
              final officer = officers[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('${officer.rank} ${officer.name}'),
                  subtitle: Text('PN: ${officer.personalNumber}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to officer details/party entries
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showAddOfficerDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final rankController = TextEditingController();
    final pnController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register Officer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: rankController, decoration: const InputDecoration(labelText: 'Rank')),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: pnController, decoration: const InputDecoration(labelText: 'Personal Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final officer = OfficerEntity(
                id: const Uuid().v4(),
                name: nameController.text,
                rank: rankController.text,
                personalNumber: pnController.text,
              );
              ref.read(officerListProvider.notifier).addOfficer(officer);
              Navigator.pop(context);
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
