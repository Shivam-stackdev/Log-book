import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:army_mess_inventory/core/theme/app_theme.dart';
import 'package:army_mess_inventory/core/utils/app_router.dart';
import 'package:army_mess_inventory/core/utils/database_helper.dart';
import 'package:army_mess_inventory/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:army_mess_inventory/providers/inventory_provider.dart';
import 'package:army_mess_inventory/providers/transaction_provider.dart';
import 'package:army_mess_inventory/providers/party_provider.dart';
import 'package:army_mess_inventory/providers/order_provider.dart';
import 'package:army_mess_inventory/providers/dashboard_provider.dart';
import 'package:army_mess_inventory/providers/theme_provider.dart';
import 'package:army_mess_inventory/providers/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Global providers using Riverpod for DI
final repositoryProvider = Provider((ref) {
  return InventoryRepositoryImpl(DatabaseHelper.instance);
});

final inventoryChangeProvider = ChangeNotifierProvider((ref) {
  return InventoryProvider(ref.watch(repositoryProvider));
});

final transactionChangeProvider = ChangeNotifierProvider((ref) {
  return TransactionProvider(ref.watch(repositoryProvider));
});

final partyChangeProvider = ChangeNotifierProvider((ref) {
  return PartyProvider(ref.watch(repositoryProvider));
});

final orderChangeProvider = ChangeNotifierProvider((ref) {
  return OrderProvider(ref.watch(repositoryProvider));
});

final dashboardChangeProvider = ChangeNotifierProvider((ref) {
  return DashboardProvider(
    inventoryProvider: ref.read(inventoryChangeProvider),
    transactionProvider: ref.read(transactionChangeProvider),
  );
});

final themeChangeProvider = ChangeNotifierProvider((ref) {
  return ThemeProvider();
});

final localeChangeProvider = ChangeNotifierProvider((ref) {
  return LocaleProvider();
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: ArmyMessApp(),
    ),
  );
}

class ArmyMessApp extends ConsumerWidget {
  const ArmyMessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(themeChangeProvider);
    final localeProvider = ref.watch(localeChangeProvider);

    return MaterialApp.router(
      title: 'Army Mess Inventory',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
