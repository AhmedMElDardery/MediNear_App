import 'package:flutter/material.dart';

class BouncingIconButton extends StatefulWidget {
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
  State<BouncingIconButton> createState() => _BouncingIconButtonState();
}

class _BouncingIconButtonState extends State<BouncingIconButton>
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
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        Future.delayed(const Duration(milliseconds: 150), () {
          widget.onTap();
        });
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}