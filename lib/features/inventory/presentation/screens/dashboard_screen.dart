import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:army_mess_inventory/main.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/core/utils/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardChangeProvider);
    final theme = ref.watch(themeChangeProvider);
    final localeProvider = ref.watch(localeChangeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations(localeProvider.locale);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.translate('app_name'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.amber : Colors.blueGrey,
            ),
            onPressed: () => theme.toggleTheme(),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0D1117),
                    const Color(0xFF161B22),
                    const Color(0xFF0D1117),
                  ]
                : [
                    Colors.green.shade50,
                    Colors.white,
                    Colors.blue.shade50,
                  ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => dashboard.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildStatsGrid(context, dashboard),
                  const SizedBox(height: 30),
                  Text(
                    l10n.translate('quick_actions'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildActionGrid(context),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeProvider = ProviderScope.containerOf(context).read(localeChangeProvider);
    final l10n = AppLocalizations(localeProvider.locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('welcome'),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.green.shade300 : Colors.green.shade900,
          ),
        ),
        Text(
          'Mess Inventory Status: Operational',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, dynamic dashboard) {
    final formatter = NumberFormat('#,##0', 'en_IN');
    final costFormatter = NumberFormat('#,##0.00', 'en_IN');

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(context, 'Total Items', '${dashboard.totalItems}', Icons.inventory, Colors.blue),
        _buildStatCard(context, 'Low Stock', '${dashboard.lowStockCount}', Icons.warning_amber, Colors.orange),
        _buildStatCard(
          context,
          'Daily Deduction',
          'Rs ${costFormatter.format(dashboard.dailyDeduction)}',
          Icons.trending_down,
          Colors.red,
        ),
        _buildStatCard(
          context,
          'Monthly Cost',
          'Rs ${costFormatter.format(dashboard.monthlyCost)}',
          Icons.account_balance_wallet,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final localeProvider = ProviderScope.containerOf(context).read(localeChangeProvider);
    final l10n = AppLocalizations(localeProvider.locale);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildActionCard(context, l10n.translate('stock_management'), l10n.translate('manage_inventory'), Icons.list_alt, '/stock'),
        _buildActionCard(context, l10n.translate('daily_deduction'), l10n.translate('record_usage'), Icons.remove_circle_outline, '/deduction'),
        _buildActionCard(context, l10n.translate('officer_party'), l10n.translate('manage_party_bills'), Icons.celebration, '/party'),
        _buildActionCard(context, l10n.translate('party_orders'), l10n.translate('pre_party_ordering'), Icons.shopping_bag_outlined, '/party-orders'),
        _buildActionCard(context, l10n.translate('ocr_bill_scan'), l10n.translate('import_bills_auto'), Icons.document_scanner, '/ocr'),
        _buildActionCard(context, l10n.translate('reports'), l10n.translate('view_analytics'), Icons.analytics, '/reports'),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isDark ? Colors.green.shade300 : Colors.green.shade700,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeProvider = ProviderScope.containerOf(context).read(localeChangeProvider);
    final l10n = AppLocalizations(localeProvider.locale);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: NavigationBar(
          backgroundColor: isDark
              ? const Color(0xFF1A1A2E).withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.dashboard), label: l10n.translate('home')),
            NavigationDestination(icon: const Icon(Icons.analytics), label: l10n.translate('reports')),
            NavigationDestination(icon: const Icon(Icons.history), label: l10n.translate('history')),
            NavigationDestination(icon: const Icon(Icons.settings), label: l10n.translate('settings')),
          ],
          onDestinationSelected: (index) {
            if (index == 1) context.push('/reports');
            if (index == 2) context.push('/history');
            if (index == 3) context.push('/settings');
          },
        ),
      ),
    );
  }
}
