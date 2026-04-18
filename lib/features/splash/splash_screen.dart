import 'package:flutter/material.dart';
import 'package:medinear_app/core/components/app_logo.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
import 'package:medinear_app/features/splash/splash_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState(){
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2)
      );

    _fade = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _scale = Tween(begin: 0.8, end: 1.0).animate(_controller);

    _controller.forward();

    Future.microtask(() => context.read<SplashProvider>().checkAppState(context));
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.backgroundLight,
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
                  size: 120,
                ),
                const SizedBox(height: 15),
                Text(
                  'Medinear',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isDark ? Colors.white : AppColors.primaryLight,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),            
              ],            
            ),
          ),          
          ),
      ),
    );
  }
}