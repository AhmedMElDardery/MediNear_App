import 'package:flutter/widgets.dart';

class PageTransition {
  static Route slide(Widget page) {
    return PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                .animate(animation),
            child: child,
          );
        });
  }
}
