import 'package:flutter/material.dart';
import 'package:medinear_app/core/provider/navigation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';

import 'bouncing_icon_button.dart';

class HomeFloatingButton extends ConsumerWidget {
  const HomeFloatingButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationProvider);
    final selectedIndex = ref.watch(navigationProvider).currentIndex;

    const Color mainGreen = Color(0xFF00965E);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isSelected = selectedIndex == 0;

    return Transform.translate(
      offset: const Offset(0, 16),
      child: BouncingIconButton(
        isHomeButton: true,
        onTap: () => nav.changeIndex(0),
        child: Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            color: isSelected
                ? null
                : (isDark ? Colors.grey[800] : Colors.grey[400]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isSelected ? mainGreen : Colors.black),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [mainGreen, mainGreen],
                  )
                : null,
          ),
          child: const Icon(
            Icons.home_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}
