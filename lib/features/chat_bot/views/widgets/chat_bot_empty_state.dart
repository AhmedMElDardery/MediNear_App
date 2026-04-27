import 'package:flutter/material.dart';
import '../../provider/chat_bot_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'chat_bot_styles.dart';

class ChatBotEmptyState extends StatelessWidget {
  final ChatBotProvider vm;
  const ChatBotEmptyState({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      // ✅ بيساعدنا نعرف المساحة المتاحة بدقة
      builder: (context, constraints) {
        return SingleChildScrollView(
          // ✅ الحل السحري لمنع الـ Overflow وتسهيل حركة الكيبورد
          physics: const BouncingScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // يبدأ من فوق بانتظام
              children: [
                const SizedBox(height: 40),

                // Bot Icon with Gradient
                const _BotIcon(),

                const SizedBox(height: 24),

                // Welcome Text
                ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                    colors: [ChatBotStyles.g2, ChatBotStyles.g1],
                  ).createShader(r),
                  child: const Text(
                    "Hello! How can I help you?",
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Choose a suggestion or type your question",
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : ChatBotStyles.soft,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 32),

                // Suggestions List
                ...vm.suggestions.map((s) => _SuggestionCard(
                    text: s, isDark: isDark, onTap: () => vm.sendMessage(s))),

                // ✅ شيلنا الـ Spacer وحطينا SizedBox ثابت عشان ميعملش Overflow مع الكيبورد
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String text;
  final bool isDark;
  final VoidCallback onTap;

  const _SuggestionCard(
      {required this.text, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white24
                  : ChatBotStyles.g1.withValues(alpha: 0.1),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_outline_rounded,
                  size: 18, color: ChatBotStyles.g1),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: ChatBotStyles.g1),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotIcon extends StatelessWidget {
  const _BotIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [ChatBotStyles.g1, ChatBotStyles.g3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x404DD9AC),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.smart_toy_rounded,
        color: Colors.white,
        size: 45,
      ),
    );
  }
}
