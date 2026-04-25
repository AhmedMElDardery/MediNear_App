import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BouncingIconButton extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isHomeButton;

  const BouncingIconButton({
    super.key,
    required this.child,
    required this.onTap,
    this.isHomeButton = false,
  });

  @override
  ConsumerState<BouncingIconButton> createState() => _BouncingIconButtonState();
}

class _BouncingIconButtonState extends ConsumerState<BouncingIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.isHomeButton ? 0.85 : 0.9,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _controller.forward();
        widget.onTap();
      },
      onTapUp: (_) {
        _controller.reverse();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
