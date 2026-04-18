import 'package:flutter/material.dart';
import '../../provider/chat_bot_provider.dart';
import 'chat_bot_styles.dart';

class ChatBotEmptyState extends StatelessWidget {
  final ChatBotProvider vm;
  const ChatBotEmptyState({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 15),

            // Bot Icon with Gradient
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [ChatBotStyles.g1, ChatBotStyles.g3],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x304DD9AC),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
            const SizedBox(height: 20),

            // Welcome Text
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: [ChatBotStyles.g2, ChatBotStyles.g1],
              ).createShader(r),
              child: const Text(
                "Hello! How can I help you?",
                textDirection: TextDirection.ltr, // تعديل LTR
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Choose a suggestion or type your question",
              textDirection: TextDirection.ltr, // تعديل LTR
              style: TextStyle(
                color: ChatBotStyles.soft,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 25),

            // Suggestions List
            Column(
              children: vm.suggestions.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => vm.sendMessage(s),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: ChatBotStyles.g1.withValues(alpha: 0.15),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        // تعديل Row ليكون الإيقونات والنص من اليسار لليمين
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 16,
                            color: ChatBotStyles.g1,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s,
                              textDirection: TextDirection.ltr, // تعديل LTR
                              textAlign: TextAlign.left, // محاذاة لليسار
                              style: const TextStyle(
                                color: Color(0xFF2D3132),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons
                                .arrow_forward_ios_rounded, // تغيير اتجاه السهم
                            size: 13,
                            color: ChatBotStyles.g1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
