import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:army_mess_inventory/core/theme/app_theme.dart';
import 'package:army_mess_inventory/core/utils/app_router.dart';
import 'package:army_mess_inventory/core/utils/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: ArmyMessApp(),
    ),
  );
}

class ArmyMessApp extends StatelessWidget {
  const ArmyMessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Army Mess Inventory',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
