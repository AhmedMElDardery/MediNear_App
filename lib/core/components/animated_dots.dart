import 'package:flutter/material.dart';
import 'package:medinear_app/core/theme/app_colors.dart';

class AnimatedDots extends StatelessWidget {
  final int currentIndex;
  final int count;
  const AnimatedDots({
    super.key,
    required this.currentIndex,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          count,
          (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentIndex == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                    color: currentIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
                    borderRadius: BorderRadius.circular(10)),
              )),
    );
  }
}
