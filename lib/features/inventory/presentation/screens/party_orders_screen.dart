import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/main.dart';
import 'package:army_mess_inventory/features/inventory/presentation/widgets/glass_widgets.dart';
import 'package:army_mess_inventory/features/inventory/domain/entities/stock_order_entity.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class PartyOrdersScreen extends ConsumerStatefulWidget {
  const PartyOrdersScreen({super.key});

  @override
  ConsumerState<PartyOrdersScreen> createState() => _PartyOrdersScreenState();
}

class _PartyOrdersScreenState extends ConsumerState<PartyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = ref.watch(orderChangeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Party Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          indicatorColor: Colors.green,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.grey,
          tabs: [
            Tab(text: 'Pending (${orderProvider.pendingOrders.where((o) => o.type == "party").length})'),
            Tab(text: 'Fulfilled (${orderProvider.fulfilledOrders.where((o) => o.type == "party").length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(orderProvider.pendingOrders.where((o) => o.type == 'party').toList(), isDark, pending: true),
          _buildOrderList(orderProvider.fulfilledOrders.where((o) => o.type == 'party').toList(), isDark, pending: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateOrderDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }

  Widget _buildOrderList(List<StockOrderEntity> orders, bool isDark, {required bool pending}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              pending ? Icons.pending_actions : Icons.check_circle_outline,
              size: 64,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              pending ? 'No pending orders' : 'No fulfilled orders',
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white54 : Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: pending
                  ? Colors.orange.withValues(alpha: 0.15)
                  : Colors.green.withValues(alpha: 0.15),
              child: Icon(
                pending ? Icons.hourglass_empty : Icons.check,
                color: pending ? Colors.orange : Colors.green,
              ),
            ),
            title: Text(order.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${order.quantity.toStringAsFixed(1)} ${order.unit} | Est: Rs ${order.estimatedCost.toStringAsFixed(2)}\n${DateFormat('dd MMM yyyy').format(order.orderDate)}',
            ),
            isThreeLine: true,
            trailing: pending
                ? IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: 'Mark Fulfilled',
                    onPressed: () => _fulfillOrder(order),
                  )
                : const Icon(Icons.done_all, color: Colors.green),
          ),
        );
      },
    );
  }

  void _showCreateOrderDialog() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    DateTime orderDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create Party Order'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyCtrl,
                        decoration: const InputDecoration(labelText: 'Quantity'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: unitCtrl,
                        decoration: const InputDecoration(labelText: 'Unit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: costCtrl,
                  decoration: const InputDecoration(labelText: 'Estimated Cost (Rs)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: orderDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      setDialogState(() => orderDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Order Date'),
                    child: Text(DateFormat('dd MMM yyyy').format(orderDate)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || qtyCtrl.text.isEmpty) return;
                final order = StockOrderEntity(
                  id: const Uuid().v4(),
                  orderDate: orderDate,
                  itemName: nameCtrl.text.trim(),
                  quantity: double.tryParse(qtyCtrl.text) ?? 0,
                  unit: unitCtrl.text.trim(),
                  estimatedCost: double.tryParse(costCtrl.text) ?? 0,
                  type: 'party',
                  isFulfilled: false,
                );
                await ref.read(orderChangeProvider).addOrder(order);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Create Order'),
            ),
          ],
        ),
      ),
    );
  }

  void _fulfillOrder(StockOrderEntity order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fulfill Order'),
        content: Text('Mark "${order.itemName}" order as fulfilled?\n\nThis means stock has arrived and can be added to inventory.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Fulfill'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(orderChangeProvider).fulfillOrder(order.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${order.itemName} order fulfilled! Add stock via Stock Inventory.')),
        );
      }
    }
  }
}
