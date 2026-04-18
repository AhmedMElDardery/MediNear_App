import 'package:flutter/material.dart';
import 'package:medinear_app/features/alarm/view_models/alarm_view_model.dart';
import 'package:medinear_app/features/chat_bot/provider/chat_bot_provider.dart';
import 'package:medinear_app/features/support/presentation/provider/support_provider.dart';
import 'package:medinear_app/features/wallet/view_models/wallet_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- Core Imports ---
import 'package:medinear_app/core/network/dio_clilent.dart'; // تأكد من الاسم لو فيه typo عندك
import 'package:medinear_app/core/provider/navigation_provider.dart';
import 'package:medinear_app/core/services/token_storage.dart';
import 'package:medinear_app/core/services/user_storage.dart';
import 'package:medinear_app/core/theme/theme_provider.dart';
import 'package:medinear_app/core/theme/app_theme.dart';
import 'package:medinear_app/core/routes/routes.dart';
import 'package:medinear_app/core/localization/app_localizations.dart';

// --- Features Imports ---
import 'package:medinear_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:medinear_app/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:medinear_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:medinear_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:medinear_app/features/auth/presentation/auth_provider.dart';

import 'package:medinear_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:medinear_app/features/home/data/datasources/home_remote_data_source_impl.dart';
import 'package:medinear_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:medinear_app/features/home/domain/repositories/home_repository.dart';
import 'package:medinear_app/features/home/presentation/provider/home_provider.dart';

// 🚀 التعديل هنا: عملنا hide لـ MapProvider لأنك غالباً نسخته غلط جوه ملف الـ Datasource
import 'package:medinear_app/features/map/data/datasource/map_remote_datasource.dart' hide MapProvider;
import 'package:medinear_app/features/map/data/repositories/map_repository_impl.dart';
import 'package:medinear_app/features/map/domain/repositories/map_repository.dart';
import 'package:medinear_app/features/map/presentation/provider/map_provider.dart';

import 'package:medinear_app/features/about_us/presentation/manager/about_provider.dart';
import 'package:medinear_app/features/cart/presentation/manager/cart_provider.dart';
import 'package:medinear_app/features/chat/view_models/chats_view_model.dart';
import 'package:medinear_app/features/onboarding/onboarding_provider.dart';
import 'package:medinear_app/features/pharmacy/presentation/manager/pharmacy_provider.dart';
import 'package:medinear_app/features/profile/view_models/profile_provider.dart';
import 'package:medinear_app/features/orders/presentation/manager/order_provider.dart';
import 'package:medinear_app/features/saved_items/presentation/manager/saved_items_provider.dart';
import 'package:medinear_app/features/splash/splash_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ==========================================
        // 1. Core Services & Clients
        // ==========================================
        Provider<DioClient>(create: (context) => DioClient()),
        Provider<TokenStorage>(create: (context) => TokenStorage()),
        Provider<UserStorage>(create: (context) => UserStorage()),

        // ==========================================
        // 2. Auth Dependencies
        // ==========================================
        Provider<AuthRemoteDataSource>(
          create: (context) => AuthRemoteDataSourceImpl(
            context.read<DioClient>().dio,
          ),
        ),
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            context.read<AuthRemoteDataSource>(),
            context.read<TokenStorage>(),
            context.read<UserStorage>(),
          ),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) {
            final provider = AuthProvider(
              context.read<AuthRepository>(),
              context.read<UserStorage>(),
            );
            provider.loadCachedUser();
            return provider;
          },
        ),

        // ==========================================
        // 3. Home Dependencies
        // ==========================================
        Provider<HomeRemoteDataSource>(
          create: (context) => HomeRemoteDataSourceImpl(
            dio: context.read<DioClient>().dio,
            tokenStorage: context.read<TokenStorage>(),
          ),
        ),
        Provider<HomeRepository>(
          create: (context) => HomeRepositoryImpl(
            context.read<HomeRemoteDataSource>(),
          ),
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (context) => HomeProvider(
            context.read<HomeRepository>(),
          ),
        ),

        // ==========================================
        // 4. Map Dependencies
        // ==========================================
        Provider<MapRemoteDataSource>(
          create: (context) => MapRemoteDataSource(
            context.read<DioClient>().dio,
          ),
        ),
        Provider<MapRepository>(
          create: (context) => MapRepositoryImpl(
            context.read<MapRemoteDataSource>(),
          ),
        ),
        ChangeNotifierProvider<MapProvider>(
          create: (context) => MapProvider(
            context.read<MapRepository>(),
          ),
        ),

        // ==========================================
        // 5. Global & UI Providers
        // ==========================================
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<NavigationProvider>(create: (_) => NavigationProvider()),
        ChangeNotifierProvider<SplashProvider>(
          create: (context) => SplashProvider(context.read<TokenStorage>()),
        ),
        ChangeNotifierProvider<OnboardingProvider>(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider<SavedItemsProvider>(create: (_) => SavedItemsProvider()),
        ChangeNotifierProvider<PharmacyProvider>(create: (_) => PharmacyProvider()),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<AboutProvider>(create: (_) => AboutProvider()),
        ChangeNotifierProvider<ProfileProvider>(create: (_) => ProfileProvider()),
        ChangeNotifierProvider<OrderProvider>(create: (_) => OrderProvider()),
        ChangeNotifierProvider<ChatsViewModel>(create: (_) => ChatsViewModel()),
        ChangeNotifierProvider<ChatBotProvider>(create: (_) => ChatBotProvider()),
        ChangeNotifierProvider<WalletViewModel>(create: (_) => WalletViewModel()),
        ChangeNotifierProvider<AlarmViewModel>(create: (_) => AlarmViewModel()),
        ChangeNotifierProvider<SupportProvider>(create: (_) => SupportProvider()),
      ],

      child: Builder(
        builder: (context) {
          final themeProvider = context.watch<ThemeProvider>();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: const Locale('en'),
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}