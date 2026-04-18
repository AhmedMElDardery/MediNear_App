import 'dart:ui';
import 'package:flutter/material.dart';
import '../../provider/chat_bot_provider.dart';
import 'chat_bot_styles.dart';
import 'chat_bot_components.dart';

class ChatBotBottomPanel extends StatelessWidget {
  final ChatBotProvider vm;
  final TextEditingController controller;

  const ChatBotBottomPanel({
    super.key,
    required this.vm,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final isEmpty = vm.messages.isEmpty;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          // تأثير البلور الزجاجي
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: ChatBotStyles.panelBg.withAlpha(180),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                    color: ChatBotStyles.g1.withAlpha(40), width: 0.8),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // الاقتراحات (Suggestions)
                if (!isEmpty && vm.suggestions.isNotEmpty)
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: ChatBotStyles.g1.withAlpha(20),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
                      itemCount: vm.suggestions.length,
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => vm.sendMessage(vm.suggestions[i]),
                        child: SugChipSolid(text: vm.suggestions[i]),
                      ),
                    ),
                  ),
                // حقل الإدخال وزر الإرسال
                Padding(
                  padding: EdgeInsets.fromLTRB(12, 10, 12, bottom + 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // تم إزالة زر الميكروفون بناءً على طلبك السابق
                      Expanded(child: _buildTextField()),
                      const SizedBox(width: 10),
                      _buildSendButton(vm),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(200),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ChatBotStyles.g1.withAlpha(50), width: 0.8),
      ),
      // المحاذاة لليسار للغة الإنجليزية
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        // تغيير الاتجاه ليكون LTR
        textDirection: TextDirection.ltr,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: ChatBotStyles.dark,
        ),
        decoration: const InputDecoration(
          hintText: "Type your message...",
          hintTextDirection: TextDirection.ltr,
          border: InputBorder.none,
          isCollapsed: true,
          hintStyle: TextStyle(color: ChatBotStyles.soft, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildSendButton(ChatBotProvider vm) {
    return GestureDetector(
      onTap: () {
        if (controller.text.trim().isNotEmpty) {
          vm.sendMessage(controller.text.trim());
          controller.clear();
        }
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [ChatBotStyles.g1, ChatBotStyles.g3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: ChatBotStyles.g2.withAlpha(50),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Send",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
