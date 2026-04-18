import 'dart:ui';
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

  @override
  Widget build(BuildContext context) {
    final bool isBot = msg.isBot;

    return Padding(
      // ✅ تباعد رأسي (8) لمنع التصاق الفقاعات، وتقليل جانبي (4) للالتصاق بالحافة
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        // البوت يسار والمستخدم يمين
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 1. صورة البوت (أقصى اليسار)
          if (isBot) ...[
            _buildGlowAvatar(),
            const SizedBox(width: 4),
          ],

          // 2. فقاعة الرسالة - الحل السحري IntrinsicWidth
          Flexible(
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onLongPress: () => _showReactionSheet(context, msg, vm),
                    child: _buildMessengerBubble(context),
                  ),
                  if (msg.reaction != null) _buildReactionBadge(isBot),
                ],
              ),
            ),
          ),

          // 3. صورة المستخدم (أقصى اليمين)
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

  Widget _buildMessengerBubble(BuildContext context) {
    final bool isBot = msg.isBot;
    final double screenWidth = MediaQuery.of(context).size.width;
    final String time = DateFormat('hh:mm a').format(msg.timestamp);

    return Container(
      // ✅ أقصى عرض 85% من الشاشة، لكنها ستنكمش بفضل IntrinsicWidth
      constraints: BoxConstraints(maxWidth: screenWidth * 0.85),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: isBot ? ChatBotStyles.botBubble : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft:
              isBot ? const Radius.circular(4) : const Radius.circular(20),
          bottomRight:
              isBot ? const Radius.circular(20) : const Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
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
                    style: const TextStyle(
                      color: Color(0xFF2D3132),
                      fontSize: 15.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
            const SizedBox(height: 5),
            // ✅ محاذاة الوقت لليمين داخل الفقاعة
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: TextStyle(
                  color: isBot
                      ? ChatBotStyles.g3.withValues(alpha: 0.7)
                      : Colors.black26,
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

  Widget _buildReactionBadge(bool isBot) {
    return Transform.translate(
      offset: Offset(isBot ? 12 : -12, -8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.15), blurRadius: 8)
          ],
          border: Border.all(color: const Color(0xFFF0F4F4), width: 1.5),
        ),
        child: Text(msg.reaction!, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  void _showReactionSheet(
      BuildContext context, ChatMessage msg, ChatBotProvider vm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['❤️', '👍', '😂', '😮', '😢']
                  .map((emoji) => IconButton(
                        onPressed: () {
                          vm.addReaction(msg.id, emoji);
                          Navigator.pop(context);
                        },
                        icon: Text(emoji, style: const TextStyle(fontSize: 32)),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
