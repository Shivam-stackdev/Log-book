import 'package:go_router/go_router.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/dashboard_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/stock_list_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/deduction_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/officer_party_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/party_orders_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/ocr_scan_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/reports_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/history_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/monthly_history_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/purchase_suggestions_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/stock',
      builder: (context, state) => const StockListScreen(),
    ),
    GoRoute(
      path: '/deduction',
      builder: (context, state) => const DeductionScreen(),
    ),
    GoRoute(
      path: '/party',
      builder: (context, state) => const OfficerPartyScreen(),
    ),
    GoRoute(
      path: '/party-orders',
      builder: (context, state) => const PartyOrdersScreen(),
    ),
    GoRoute(
      path: '/ocr',
      builder: (context, state) => const OcrScanScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/monthly-history',
      builder: (context, state) => const MonthlyHistoryScreen(),
    ),
    GoRoute(
      path: '/purchase-suggestions',
      builder: (context, state) => const PurchaseSuggestionsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
