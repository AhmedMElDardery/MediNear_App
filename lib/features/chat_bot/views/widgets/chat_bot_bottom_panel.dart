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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        // ✅ إضافة const هنا بتمنع إعادة حساب الحواف الدائرية مع حركة الكيبورد
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          // تأثير البلور الزجاجي
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E).withAlpha(200) : ChatBotStyles.panelBg.withAlpha(180),
              // ✅ إضافة const للحواف
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
                      Expanded(child: _buildTextField(isDark)),
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

  Widget _buildTextField(bool isDark) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white.withAlpha(200),
        // ✅ تحويلها لـ const
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: ChatBotStyles.g1.withAlpha(50), width: 0.8),
      ),
      // المحاذاة لليسار للغة الإنجليزية
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        // تغيير الاتجاه ليكون LTR
        textDirection: TextDirection.ltr,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : ChatBotStyles.dark,
        ),
        decoration: InputDecoration(
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
          // ✅ تحويلها لـ const
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          // ✅ الجراديانت هنا بقت const فمش هتترسم تاني
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
        // ✅ الـ Row دي محتواها ثابت، فبقت كلها const
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