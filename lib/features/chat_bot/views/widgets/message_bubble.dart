import 'package:flutter/material.dart';
import 'chat_bot_components.dart'; // عشان الـ TypewriterText

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isBot;
  final DateTime? timestamp;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isBot,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد الوقت الافتراضي لو مبعوتش قيمة
    final time = timestamp ?? DateTime.now();
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    // ✅ التريك الأهم: استخدام sizeOf بدل of(context) عشان الرسايل متعيدش رسم نفسها مع طلوع الكيبورد!
    final maxWidth = MediaQuery.sizeOf(context).width * 0.75;

    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          crossAxisAlignment:
              isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            // فقاعة النص الأساسية
            Container(
              padding: const EdgeInsets.all(15),
              constraints: BoxConstraints(
                maxWidth: maxWidth,
              ),
              decoration: BoxDecoration(
                color: isBot ? const Color(0xFF00897B) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isBot ? Radius.zero : const Radius.circular(18),
                  bottomRight: isBot ? const Radius.circular(18) : Radius.zero,
                ),
                // ✅ تحويل الشادو لـ const عشان ميستهلكش رامات في السكرول
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000), // نفس لونك بالضبط بس بصيغة ثابتة
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: isBot
                    ? TypewriterText(key: ValueKey(text), text: text)
                    : Text(
                        text,
                        // ✅ تحويل الستايل لـ const
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
              ),
            ),

            // الوقت بره الفقاعة ومنظم مع محاذاة الرسالة
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 6, right: 6),
              child: Text(
                "$hour:$minute $period",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
