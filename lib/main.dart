import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:army_mess_inventory/core/theme/app_theme.dart';
import 'package:army_mess_inventory/core/utils/app_router.dart';
import 'package:army_mess_inventory/core/utils/app_localizations.dart';
import 'package:army_mess_inventory/core/logging/logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  AppLogger.enable(enabled: true);
  AppLogger.i('App', 'Starting Mesh Management App v3.0.0');

  runApp(const ProviderScope(child: MeshManagementApp()));
}

class MeshManagementApp extends StatelessWidget {
  const MeshManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mesh Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      supportedLocales: const [Locale('en', ''), Locale('hi', '')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
