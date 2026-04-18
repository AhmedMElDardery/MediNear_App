import 'dart:ui';
import 'package:flutter/material.dart';
import '../../provider/chat_bot_provider.dart';
import 'chat_bot_styles.dart';
import 'chat_bot_components.dart';

class ChatBotHeader extends StatelessWidget {
  final ChatBotProvider vm;
  const ChatBotHeader({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(10, top + 10, 10, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ChatBotStyles.hTop, ChatBotStyles.hMid, ChatBotStyles.hBot],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: ChatBotStyles.g2.withAlpha(55),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // زر الرجوع - تم تغيير الأيقونة لتناسب الاتجاه الإنجليزي LTR
              GlassBtn(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
                size: 38,
                iconSize: 20,
              ),
              const Expanded(
                child: Text(
                  "Smart MidiNear",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              // زر إعادة ضبط المحادثة
              GlassBtn(
                icon: Icons.refresh_rounded,
                onTap: () => vm.clearChat(),
                size: 34,
                iconSize: 17,
              ),
            ],
          ),
          const SizedBox(height: 9),
          _buildStatusPill(vm),
        ],
      ),
    );
  }

  Widget _buildStatusPill(ChatBotProvider vm) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(26),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withAlpha(50), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            // الترتيب الآن: النقطة ثم النص (من اليسار لليمين)
            children: [
              vm.isTyping
                  ? const PulsingDot()
                  : Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6EFFD8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x886EFFD8), blurRadius: 5),
                        ],
                      ),
                    ),
              const SizedBox(width: 8),
              Text(
                vm.isTyping ? "Typing..." : "Online",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
