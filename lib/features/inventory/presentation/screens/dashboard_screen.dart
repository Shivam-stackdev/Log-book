import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:army_mess_inventory/core/theme/app_theme.dart';
import 'package:army_mess_inventory/core/utils/app_localizations.dart';
import 'package:army_mess_inventory/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/ui_widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final inventoryAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.read(inventoryListProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, l10n)),
              SliverToBoxAdapter(child: _buildStatsSection(inventoryAsync, l10n)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(l10n.translate('quick_actions'), style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 1.2,
                    mainAxisSpacing: AppSpacing.md, crossAxisSpacing: AppSpacing.md,
                  ),
                  delegate: SliverChildListDelegate([
                    ActionButton(title: l10n.translate('stock_management'), subtitle: l10n.translate('record_daily_usage'), icon: Icons.inventory_2, onTap: () => context.go('/stock')),
                    ActionButton(title: l10n.translate('daily_deduction'), subtitle: l10n.translate('record_daily_usage'), icon: Icons.remove_circle_outline, color: AppColors.error, onTap: () => context.go('/deduction')),
                    ActionButton(title: l10n.translate('officer_party'), subtitle: l10n.translate('officer_party'), icon: Icons.groups, color: AppColors.secondary, onTap: () => context.go('/officers')),
                    ActionButton(title: l10n.translate('ocr_bill_scan'), subtitle: l10n.translate('import_bills'), icon: Icons.document_scanner, color: AppColors.accent, onTap: () => context.go('/ocr')),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(l10n.translate('reports'), style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 1.2,
                    mainAxisSpacing: AppSpacing.md, crossAxisSpacing: AppSpacing.md,
                  ),
                  delegate: SliverChildListDelegate([
                    ActionButton(title: l10n.translate('reports'), subtitle: 'Generate PDF reports', icon: Icons.picture_as_pdf, color: AppColors.accent, onTap: () => context.go('/reports')),
                    ActionButton(title: l10n.translate('history'), subtitle: 'View past transactions', icon: Icons.history, color: AppColors.secondary, onTap: () => context.go('/history')),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => context.go('/settings'), child: const Icon(Icons.settings)),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.translate('welcome'), style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _buildStatsSection(AsyncValue inventoryAsync, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: inventoryAsync.when(
        data: (items) {
          final lowStockCount = items.where((dynamic i) => i.isLowStock).length;
          return Row(children: [
            Expanded(child: StatCard(title: l10n.translate('total_items'), value: '${items.length}', icon: Icons.inventory_2)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: StatCard(title: l10n.translate('low_stock'), value: '$lowStockCount', icon: Icons.warning, color: lowStockCount > 0 ? AppColors.warning : AppColors.success)),
          ]);
        },
        loading: () => const LinearProgressIndicator(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}
