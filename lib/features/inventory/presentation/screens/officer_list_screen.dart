import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:army_mess_inventory/core/theme/app_theme.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/ui_widgets.dart';
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
      appBar: AppBar(title: const Text('Officer Party')),
      body: officersAsync.when(
        data: (officers) {
          if (officers.isEmpty) {
            return EmptyState(
              icon: Icons.groups, title: 'No officers added',
              subtitle: 'Add officers to track their party expenses',
              actionButton: FilledButton.icon(onPressed: () => _showAddOfficerDialog(), icon: const Icon(Icons.add), label: const Text('Add Officer')),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.read(officerListProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: officers.length,
              itemBuilder: (context, index) => _buildOfficerCard(officers[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddOfficerDialog(), child: const Icon(Icons.add)),
    );
  }

  Widget _buildOfficerCard(OfficerEntity officer) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        leading: CircleAvatar(backgroundColor: AppColors.secondary.withOpacity(0.1), child: const Icon(Icons.person, color: AppColors.secondary)),
        title: Text(officer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${officer.rank} • ${officer.personalNumber}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/party-items', extra: {'officerId': officer.id, 'officerName': officer.name}),
      ),
    );
  }

  void _showAddOfficerDialog() {
    final nameCtrl = TextEditingController();
    final rankCtrl = TextEditingController();
    final pNoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Officer'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name'), autofocus: true),
          const SizedBox(height: AppSpacing.sm),
          TextField(controller: rankCtrl, decoration: const InputDecoration(labelText: 'Rank')),
          const SizedBox(height: AppSpacing.sm),
          TextField(controller: pNoCtrl, decoration: const InputDecoration(labelText: 'Personal Number')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () async {
            Navigator.pop(ctx);
            if (nameCtrl.text.isEmpty) return;
            final officer = OfficerEntity(id: const Uuid().v4(), name: nameCtrl.text, rank: rankCtrl.text, personalNumber: pNoCtrl.text);
            await ref.read(officerListProvider.notifier).addOfficer(officer);
          }, child: const Text('Add')),
        ],
      ),
    );
  }
}
