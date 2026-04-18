import 'package:flutter/material.dart';

// ✅ أبقينا فقط على رسام "ذيل الفقاعة" لأنه خفيف ومهم للشكل البصري
class BubbleTailPainter extends CustomPainter {
  final bool isBot;
  final Color color;
  
  BubbleTailPainter({required this.isBot, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true; // لضمان حواف ناعمة للمثلث
    
    final path = Path();

    if (isBot) {
      // البوت يسار -> الذيل يشير لليسار
      path.moveTo(0, 0); 
      path.lineTo(size.width, size.height * 0.4); 
      path.lineTo(0, size.height); 
    } else {
      // المستخدم يمين -> الذيل يشير لليمين
      path.moveTo(size.width, 0); 
      path.lineTo(0, size.height * 0.4); 
      path.lineTo(size.width, size.height); 
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  // ✅ التعديل الأهم: false عشان المثلث يترسم مرة واحدة في العمر وميعملش Re-paint
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

