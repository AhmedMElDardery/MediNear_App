import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medinear_app/core/routes/routes.dart';
import 'package:medinear_app/features/alarm/views/alarm_ring_screen.dart';
import 'package:alarm/alarm.dart';

import 'package:medinear_app/features/about_us/presentation/screens/about_support_screen.dart';
import 'package:medinear_app/features/alarm/views/alarm_view.dart';
import 'package:medinear_app/features/auth/presentation/login_screen.dart';
import 'package:medinear_app/features/cart/presentation/screens/cart_pharmacies_screen.dart';
import 'package:medinear_app/features/cart/presentation/screens/my_cart_screen.dart';
import 'package:medinear_app/features/chat/views/chat_details_view.dart';
import 'package:medinear_app/features/chat/views/chats_view.dart';
import 'package:medinear_app/features/chat_bot/views/chat_bot_view.dart';

import 'package:medinear_app/features/main_layout/presentation/screens/main_layout_screen.dart';
import 'package:medinear_app/features/map/presentation/screens/map_screen.dart';
import 'package:medinear_app/features/home/presentation/screens/categories_screen.dart';
import 'package:medinear_app/features/pharmacy/presentation/screens/medicine_details_screen.dart';
import 'package:medinear_app/features/home/domain/entities/medicine_entity.dart';
import 'package:medinear_app/features/home/domain/entities/category_entity.dart';
import 'package:medinear_app/features/home/presentation/screens/category_medicines_screen.dart';
import 'package:medinear_app/features/notifications/presentation/pages/notifications_screen.dart';

import 'package:medinear_app/features/onboarding/onboarding_screen.dart';
import 'package:medinear_app/features/profile/views/profile_screen.dart';
import 'package:medinear_app/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:medinear_app/features/saved_items/presentation/screens/saved_items_screen.dart';
import 'package:medinear_app/features/splash/splash_screen.dart';
import 'package:medinear_app/features/support/presentation/screen/support_screen.dart';
import 'package:medinear_app/features/wallet/views/wallet_view.dart';
import 'package:medinear_app/features/packets/domain/entities/packet_entity.dart';
import 'package:medinear_app/features/packets/presentation/screens/packets_screen.dart';
import 'package:medinear_app/features/packets/presentation/screens/packet_details_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainLayoutScreen(),
    ),
    GoRoute(
      path: AppRoutes.notification,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.map,
      builder: (context, state) {
        final medicine = state.uri.queryParameters['medicine'] ?? "";
        return MapScreen(medicine: medicine);
      },
    ),
    GoRoute(
      path: AppRoutes.saveditems,
      builder: (context, state) => const SavedItemsScreen(),
    ),
    GoRoute(
      path: AppRoutes.categories,
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: AppRoutes.categoryMedicines,
      builder: (context, state) {
        final category = state.extra as CategoryEntity;
        return CategoryMedicinesScreen(category: category);
      },
    ),
    GoRoute(
      path: AppRoutes.medicineDetails,
      builder: (context, state) {
        final medicine = state.extra as MedicineEntity;
        return MedicineDetailsScreen(medicine: medicine);
      },
    ),
    GoRoute(
      path: '${AppRoutes.mycart}/:pharmacyId/:pharmacyName',
      builder: (context, state) {
        final pharmacyId = int.tryParse(state.pathParameters['pharmacyId'] ?? '0') ?? 0;
        final pharmacyName = state.pathParameters['pharmacyName'] ?? "Unknown";
        return MyCartScreen(pharmacyId: pharmacyId, pharmacyName: pharmacyName);
      },
    ),
    GoRoute(
      path: AppRoutes.cart,
      builder: (context, state) => const CartPharmaciesScreen(),
    ),
    GoRoute(
      path: AppRoutes.about,
      builder: (context, state) => const AboutSupportScreen(),
    ),
    GoRoute(
      path: AppRoutes.myorder,
      builder: (context, state) => const MyOrdersScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const MainLayoutScreen(),
    ),
    GoRoute(
      path: AppRoutes.chats,
      builder: (context, state) => const ChatsView(),
    ),
    GoRoute(
      path: AppRoutes.chatdetails,
      builder: (context, state) {
        final Map<String, dynamic> args = state.extra as Map<String, dynamic>? ?? {};
        final chatName = args['chatName'] as String? ?? "Pharmacy Chat";
        final sessionId = args['sessionId'] as int? ?? 0;
        final chatModel = args['chatModel'];
        return ChatDetailsView(chatName: chatName, sessionId: sessionId, chatModel: chatModel);
      },
    ),

    GoRoute(
      path: AppRoutes.chatbot,
      builder: (context, state) => const ChatBotView(),
    ),
    GoRoute(
      path: AppRoutes.alarm,
      builder: (context, state) => const AlarmView(),
    ),
    GoRoute(
      path: '/alarm-ring',
      pageBuilder: (context, state) {
        final settings = state.extra as AlarmSettings;
        return NoTransitionPage(
          child: AlarmRingScreen(alarmSettings: settings),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.wallet,
      builder: (context, state) => const PacketsScreen(), // � تم ربط المحفظة بالميزة الجديدة
    ),
    GoRoute(
      path: AppRoutes.support,
      builder: (context, state) => const SupportScreen(),
    ),
    GoRoute(
      path: AppRoutes.packets,
      builder: (context, state) => const PacketsScreen(),
    ),
    GoRoute(
      path: AppRoutes.packetDetails,
      builder: (context, state) {
        final packet = state.extra as PacketEntity;
        return PacketDetailsScreen(packet: packet);
      },
    ),
  ],
);
