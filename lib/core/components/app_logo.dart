import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final String imagePath;
  final double size;
  const AppLogo({
    super.key,
    required this.imagePath,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(imagePath, height: size);
  }
}
