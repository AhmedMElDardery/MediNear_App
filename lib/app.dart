import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alarm/alarm.dart';

// --- Core Imports ---
import 'package:medinear_app/core/theme/app_theme.dart';
import 'package:medinear_app/core/localization/app_localizations.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import 'package:medinear_app/core/router/app_router.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<AlarmSettings>? ringSubscription;

  @override
  void initState() {
    super.initState();
    ringSubscription = Alarm.ringStream.stream.listen((alarmSettings) {
      // Use the root navigator context to push the full-screen alarm ring view
      if (rootNavigatorKey.currentContext != null) {
        appRouter.push('/alarm-ring', extra: alarmSettings);
      }
    });
  }

  @override
  void dispose() {
    ringSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the theme provider from Riverpod
    final themeProviderState = ref.watch(themeProvider);
    final localeState = ref.watch(localeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProviderState.themeMode,
      locale: localeState.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
