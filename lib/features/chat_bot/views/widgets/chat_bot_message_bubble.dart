import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
// ✅ مفيش أي استدعاء لمكتبة الماركداون هنا خالص
import '../../provider/chat_bot_provider.dart';
import '../../data/models/chat_bot_model.dart';
import 'chat_bot_components.dart';

class ChatBotMessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final ChatBotProvider vm;
  final double avatarRadius = 18.0;

  const ChatBotMessageBubble({super.key, required this.msg, required this.vm});

  // ✅ دالة لاكتشاف اللغة لضبط الاتجاهات
  bool _isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final bool isBot = msg.isBot;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBot) ...[
            _buildGlowAvatar(context),
            const SizedBox(width: 4),
          ],
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
                  if (msg.reaction != null) _buildReactionBadge(isBot, context),
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

  Widget _buildGlowAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: AvatarDot(isBot: true, r: avatarRadius),
    );
  }

  Widget _buildMessengerBubble(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isBot = msg.isBot;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final String time = DateFormat('hh:mm a').format(msg.timestamp);

    final bool isMsgArabic = _isArabic(msg.text);
    final TextDirection bubbleDirection =
        isMsgArabic ? TextDirection.rtl : TextDirection.ltr;

    return Container(
      constraints: BoxConstraints(maxWidth: screenWidth * 0.85),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: isBot
            ? Theme.of(context).cardColor
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
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
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                // ✅ استخدمنا آلة الكتابة الذكية بتاعتنا اللي بتفهم الخط العريض
                ? TypewriterText(
                    key: ValueKey(msg.text),
                    text: msg.text,
                    onComplete: () => vm.setTyping(false),
                  )
                : Text(
                    msg.text,
                    style: TextStyle(
                      color: isBot ? Theme.of(context).textTheme.bodyLarge?.color : Colors.white,
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
                      ? Theme.of(context).textTheme.bodyMedium?.color
                      : Colors.white70,
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

  Widget _buildReactionBadge(bool isBot, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Transform.translate(
      offset: Offset(isBot ? 12 : -12, -8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.15), blurRadius: 8)],
          border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              width: 1.5),
        ),
        child: Text(msg.reaction!, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  void _showReactionSheet(
      BuildContext context, ChatMessage msg, ChatBotProvider vm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              color: Theme.of(context).cardColor.withValues(alpha: 0.85),
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
