import 'dart:ui';
import 'package:flutter/material.dart';
import '../../provider/chat_bot_provider.dart';
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
              color: Theme.of(context).cardColor.withAlpha(200),
              // ✅ إضافة const للحواف
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                    color: Theme.of(context).dividerColor.withAlpha(40), width: 0.8),
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
                          color: Theme.of(context).dividerColor.withAlpha(20),
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
                      Expanded(child: _buildTextField(context, isDark)),
                      const SizedBox(width: 10),
                      _buildSendButton(context, vm),
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

  Widget _buildTextField(BuildContext context, bool isDark) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(200),
        // ✅ تحويلها لـ const
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(50), width: 0.8),
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
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        decoration: InputDecoration(
          hintText: "Type your message...",
          hintTextDirection: TextDirection.ltr,
          border: InputBorder.none,
          isCollapsed: true,
          hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context, ChatBotProvider vm) {
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
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withAlpha(50),
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
