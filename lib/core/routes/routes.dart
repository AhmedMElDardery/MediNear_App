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

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home';
  static const notification = '/notification';
  static const String map = '/map';
  static const String categories = '/categories';
  static const String medicineDetails = '/medicine_details';
  static const saveditems = '/saved_items';
  static const pharmacy = '/pharmacy';
  static const mycart = '/mycart';
  static const cart = '/cart';
  static const about = '/about';
  static const myorder = '/myorder';
  static const orderdetails = '/order_details';
  static const profile = '/profile';
  static const chats = '/chats';
  static const chatdetails = '/chatdetails';
  static const chatbot = '/chatbot';
  static const alarm = '/alarm';
  static const wallet = '/wallet';
  static const support = '/support';

  static final routes = {
    splash: (_) => const SplashScreen(),
    onboarding: (_) => const OnboardingScreen(),
    login: (_) => const LoginScreen(),
    home: (_) => const MainLayoutScreen(),
    notification: (_) => const NotificationsScreen(),
    map: (_) => const MapScreen(medicine: ""),
    saveditems: (_) => const SavedItemsScreen(),
    mycart: (_) => const MyCartScreen(
          pharmacyId: 0,
          pharmacyName: "Al Noor",
        ),
    cart: (_) => const CartPharmaciesScreen(),
    about: (_) => const AboutSupportScreen(),
    myorder: (_) => const MyOrdersScreen(),
    profile: (_) => const MainLayoutScreen(),
    chats: (_) => const ChatsView(),
    chatdetails: (_) => const ChatDetailsView(),
    chatbot: (_) => const ChatBotView(),
    alarm: (_) => const AlarmView(),
    wallet: (_) => const WalletView(),
    support: (_) => const SupportScreen(),
  };
}
