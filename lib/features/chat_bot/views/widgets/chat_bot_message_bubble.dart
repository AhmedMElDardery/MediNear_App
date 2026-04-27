import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../provider/chat_bot_provider.dart';
import '../../data/models/chat_bot_model.dart';
import 'chat_bot_styles.dart';
import 'chat_bot_components.dart';

class ChatBotMessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final ChatBotProvider vm;
  final double avatarRadius = 18.0;

  const ChatBotMessageBubble({super.key, required this.msg, required this.vm});

  // ✅ دالة اكتشاف اللغة لضبط الاتجاهات
  bool _isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final bool isBot = msg.isBot;
    // ✅ استخدام sizeOf للأداء العالي
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBot) ...[
            _buildGlowAvatar(),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  _buildMessengerBubble(context, screenWidth),
                ],
              ),
            ),
          ),
          if (!isBot) ...[
            const SizedBox(width: 4),
            AvatarDot(isBot: false, r: avatarRadius),
          ],
        ],
      ),
    );
  }

  Widget _buildGlowAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: ChatBotStyles.g1.withValues(alpha: 0.6),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: AvatarDot(isBot: true, r: avatarRadius),
    );
  }

  Widget _buildMessengerBubble(BuildContext context, double screenWidth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isBot = msg.isBot;
    final String time = DateFormat('hh:mm a').format(msg.timestamp);

    final bool isMsgArabic = _isArabic(msg.text);
    final TextDirection bubbleDirection = isMsgArabic ? TextDirection.rtl : TextDirection.ltr;

    return Container(
      // ✅ دمج أقصى عرض من الملفين لضمان التوافق
      constraints: BoxConstraints(maxWidth: screenWidth * 0.85),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: isBot
            ? (isDark ? const Color(0xFF2C2C2E) : ChatBotStyles.botBubble)
            : (isDark ? const Color(0xFF1A7A60) : Colors.white),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: isBot ? const Radius.circular(4) : const Radius.circular(20),
          bottomRight: isBot ? const Radius.circular(20) : const Radius.circular(4),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Directionality(
        textDirection: bubbleDirection,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isBot
                ? TypewriterText(
                    key: ValueKey(msg.text),
                    text: msg.text,
                    onComplete: () => vm.setTyping(false),
                  )
                : Text(
                    msg.text,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF2D3132),
                      fontSize: 15.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
            const SizedBox(height: 5),
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Text(
                time,
                style: TextStyle(
                  color: isBot
                      ? ChatBotStyles.g3.withValues(alpha: 0.7)
                      : (isDark ? Colors.white70 : Colors.black26),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
