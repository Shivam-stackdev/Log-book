import 'package:go_router/go_router.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/dashboard_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/stock_list_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/deduction_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/officer_list_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/ocr_scan_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/reports_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/history_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/cost_analysis_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/purchase_suggestions_screen.dart';
import 'package:army_mess_inventory/features/inventory/presentation/screens/backup_restore_screen.dart';

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
      path: '/officers',
      builder: (context, state) => const OfficerListScreen(),
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
      path: '/cost-analysis',
      builder: (context, state) => const CostAnalysisScreen(),
    ),
    GoRoute(
      path: '/purchase-suggestions',
      builder: (context, state) => const PurchaseSuggestionsScreen(),
    ),
    GoRoute(
      path: '/backup',
      builder: (context, state) => const BackupRestoreScreen(),
    ),
  ],
);
