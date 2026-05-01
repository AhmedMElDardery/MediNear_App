import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:medinear_app/core/components/app_logo.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
import 'package:medinear_app/features/splash/splash_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove(); // Remove native splash to show our Flutter splash screen

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _fade = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _scale = Tween(begin: 0.8, end: 1.0).animate(_controller);

    _controller.forward();

    Future.microtask(() => ref.read(splashProvider).checkAppState(context));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(
                  imagePath: 'assets/images/logo.png',
                  size: 150,
                ),
                const SizedBox(height: 15),
                Text(
                  'MediNear Pharmacies',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 40),
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
