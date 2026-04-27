import 'package:flutter/material.dart';
import '../../provider/chat_bot_provider.dart';

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
                  shaderCallback: (r) => LinearGradient(
                    colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
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
                    color: Theme.of(context).textTheme.bodyMedium?.color,
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
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
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 13, color: Theme.of(context).colorScheme.primary),
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
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
