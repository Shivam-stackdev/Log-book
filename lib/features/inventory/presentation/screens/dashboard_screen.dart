import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(title: 'Army Mess Inventory'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildStatsGrid(),
                const SizedBox(height: 30),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                _buildActionGrid(context),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, Quartermaster',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade900,
          ),
        ),
        const Text(
          'Mess Inventory Status: Operational',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Items', '124', Icons.inventory, Colors.blue),
        _buildStatCard('Low Stock', '12', Icons.warning_amber, Colors.orange),
        _buildStatCard('Daily Deduction', '₹ 4,500', Icons.trending_down, Colors.red),
        _buildStatCard('Monthly Cost', '₹ 1.2L', Icons.account_balance_wallet, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildActionCard(
          context,
          'Stock Management',
          'Manage inventory items',
          Icons.list_alt,
          '/stock',
        ),
        _buildActionCard(
          context,
          'Daily Deduction',
          'Record daily usage',
          Icons.remove_circle_outline,
          '/deduction',
        ),
        _buildActionCard(
          context,
          'Officer Party',
          'Manage officer bills',
          Icons.people_outline,
          '/officers',
        ),
        _buildActionCard(
          context,
          'OCR Bill Scan',
          'Import bills automatically',
          Icons.document_scanner,
          '/ocr',
        ),
      ],
    );
  }

  Widget _buildActionCard(
      BuildContext context, String title, String subtitle, IconData icon, String route) {
    return InkWell(
      onTap: () => context.push(route),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green.shade700),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: NavigationBar(
          backgroundColor: Colors.white.withOpacity(0.7),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.analytics), label: 'Reports'),
            NavigationDestination(icon: Icon(Icons.history), label: 'History'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
          ],
          onDestinationSelected: (index) {
            if (index == 1) context.push('/reports');
            if (index == 2) context.push('/history');
            if (index == 3) context.push('/backup');
          },
        ),
      ),
    );
  }
}
