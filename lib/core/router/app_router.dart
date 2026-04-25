import 'package:go_router/go_router.dart';
import 'package:medinear_app/core/routes/routes.dart';

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
import 'package:medinear_app/features/notifications/presentation/pages/notifications_screen.dart';

import 'package:medinear_app/features/onboarding/onboarding_screen.dart';
import 'package:medinear_app/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:medinear_app/features/saved_items/presentation/screens/saved_items_screen.dart';
import 'package:medinear_app/features/splash/splash_screen.dart';
import 'package:medinear_app/features/support/presentation/screen/support_screen.dart';
import 'package:medinear_app/features/wallet/views/wallet_view.dart';

final GoRouter appRouter = GoRouter(
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
      path: '${AppRoutes.mycart}/:pharmacyName',
      builder: (context, state) {
        final pharmacyName = state.pathParameters['pharmacyName'] ?? "Unknown";
        return MyCartScreen(pharmacyName: pharmacyName);
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
      builder: (context, state) => const ChatDetailsView(),
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
      path: AppRoutes.wallet,
      builder: (context, state) => const WalletView(),
    ),
    GoRoute(
      path: AppRoutes.support,
      builder: (context, state) => const SupportScreen(),
    ),
  ],
);
