import 'dart:math';
import 'package:flutter/material.dart';

class BubbleTailPainter extends CustomPainter {
  final bool isBot;
  final Color color;
  BubbleTailPainter({required this.isBot, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    // التعديل: عكسنا المنطق عشان الذيل يتبع الاتجاه الإنجليزي
    if (isBot) {
      // البوت يسار -> الذيل يشير لليسار
      path.moveTo(0, 0); // البداية من فوق يسار
      path.lineTo(size.width, size.height * 0.4); // زاوية للداخل
      path.lineTo(0, size.height); // قفل عند تحت يسار
    } else {
      // المستخدم يمين -> الذيل يشير لليمين
      path.moveTo(size.width, 0); // البداية من فوق يمين
      path.lineTo(0, size.height * 0.4); // زاوية للداخل
      path.lineTo(size.width, size.height); // قفل عند تحت يمين
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GreenAuroraPainter extends CustomPainter {
  final double t;
  GreenAuroraPainter(this.t);
  
  @override
  void paint(Canvas canvas, Size s) {
    // الخلفية المتدرجة (Gradient Background)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s.width, s.height),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFF0FBF7), Color(0xFFF7FDFB), Color(0xFFEDF8F4)],
        ).createShader(Rect.fromLTWH(0, 0, s.width, s.height)),
    );

    // بقع الألوان المتحركة (Aurora Blobs)
    // التعديل: استبدال withAlpha بـ withValues (لأحدث نسخة فلاتر)
    final blobs = [
      [0.10, 0.06, 0.38, 0xFFB3E5FC, 0.07],
      [0.82, 0.04, 0.30, 0xFF81D4FA, 0.05],
      [0.03, 0.58, 0.28, 0xFFC8E6C9, 0.06],
      [0.80, 0.50, 0.34, 0xFFA5D6A7, 0.04],
      [0.44, 0.88, 0.32, 0xFFE1F5FE, 0.06],
      [0.56, 0.22, 0.18, 0xFFB2DFDB, 0.04],
      [0.22, 0.72, 0.16, 0xFFDCEDC8, 0.03],
    ];

    for (int i = 0; i < blobs.length; i++) {
      final b = blobs[i];
      final phase = t + i * 0.15;
      final dx = sin(phase * pi * 2) * s.width * 0.04;
      final dy = cos(phase * pi * 2 + 1.2) * s.height * 0.032;
      
      canvas.drawCircle(
        Offset(s.width * b[0] + dx, s.height * b[1] + dy),
        s.width * b[2],
        Paint()
          ..color = Color(b[3].toInt()).withValues(alpha: b[4] as double)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
      );
    }
  }

  @override
  bool shouldRepaint(GreenAuroraPainter o) => o.t != t;
}