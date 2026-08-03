import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/officer_entity.dart';
import 'package:uuid/uuid.dart';

class OfficerListScreen extends ConsumerStatefulWidget {
  const OfficerListScreen({super.key});

  @override
  ConsumerState<OfficerListScreen> createState() => _OfficerListScreenState();
}

class _OfficerListScreenState extends ConsumerState<OfficerListScreen> {
  @override
  Widget build(BuildContext context) {
    final officersAsync = ref.watch(officerListProvider);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Officers Messing',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddOfficerDialog(context),
          ),
        ],
      ),
      body: officersAsync.when(
        data: (officers) {
          if (officers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No officers registered', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showAddOfficerDialog(context),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Officer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: officers.length,
            itemBuilder: (context, index) {
              final officer = officers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    child: Icon(Icons.person, color: Colors.purple.shade700),
                  ),
                  title: Text(
                    '${officer.rank} ${officer.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('PN: ${officer.personalNumber}'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    context.push(
                      '/party-items',
                      extra: {
                        'officerId': officer.id,
                        'officerName': '${officer.rank} ${officer.name}',
                      },
                    );
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

  void _showAddOfficerDialog(BuildContext context) {
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
            TextField(
              controller: rankController,
              decoration: const InputDecoration(labelText: 'Rank'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pnController,
              decoration: const InputDecoration(labelText: 'Personal Number'),
            ),
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
