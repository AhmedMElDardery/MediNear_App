import 'dart:ui';
import 'package:flutter/material.dart';
import '../../provider/chat_bot_provider.dart';
import '../../../../core/theme/app_colors.dart';
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
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withAlpha(200)
                  : AppColors.surfaceLight.withAlpha(180),
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
                        // 🔒 قفل الضغط على الاقتراحات أثناء الرد
                        onTap: vm.isTyping ? null : () => vm.sendMessage(vm.suggestions[i]),
                        child: SugChipSolid(text: vm.suggestions[i]),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(12, 10, 12, bottom + 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
        color: isDark ? AppColors.surfaceDarkVariant : AppColors.surfaceLight.withAlpha(200),
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: ChatBotStyles.g1.withAlpha(50), width: 0.8),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        // 🔒 قفل الحقل أثناء التحميل
        enabled: !vm.isTyping,
        textDirection: TextDirection.ltr,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: vm.isTyping ? Colors.grey : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        ),
        decoration: InputDecoration(
          hintText: vm.isTyping ? "Please wait..." : "Type your message...",
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
      // 🔒 منع الإرسال المتكرر
      onTap: vm.isTyping ? null : () {
        if (controller.text.trim().isNotEmpty) {
          vm.sendMessage(controller.text.trim());
          controller.clear();
        }
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          // 🎨 تغيير اللون لرمادي في حالة التحميل
          gradient: vm.isTyping 
            ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600])
            : const LinearGradient(
                colors: [ChatBotStyles.g1, ChatBotStyles.g3],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
          boxShadow: [
            if (!vm.isTyping)
              BoxShadow(
                color: ChatBotStyles.g2.withAlpha(50),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              vm.isTyping ? "..." : "Send",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            vm.isTyping 
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}