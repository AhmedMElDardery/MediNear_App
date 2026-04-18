import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/chat_bot_provider.dart';
import 'widgets/chat_bot_styles.dart';
import 'widgets/chat_bot_header.dart';
import 'widgets/chat_bot_empty_state.dart';
import 'widgets/chat_bot_message_bubble.dart';
import 'widgets/chat_bot_bottom_panel.dart';

// ============================================================
// Main Chat View - Clean Version (No Background Animation)
// ============================================================
class ChatBotView extends StatefulWidget {
  const ChatBotView({super.key});
  @override
  State<ChatBotView> createState() => _ChatBotViewState();
}

class _ChatBotViewState extends State<ChatBotView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : ChatBotStyles.bgBase,
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            // Layout Layer
            Consumer<ChatBotProvider>(
              builder: (context, vm, child) {
                final isEmpty = vm.messages.isEmpty;
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return Column(
                  children: [
                    ChatBotHeader(vm: vm),
                    Expanded(
                      child: isEmpty
                          ? ChatBotEmptyState(vm: vm)
                          // ✅ عزل قائمة الرسائل بـ RepaintBoundary يضمن سكرول فائق السلاسة
                          : RepaintBoundary(
                              child: ListView.builder(
                                controller: _scrollController,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  MediaQuery.of(context).size.height * 0.23,
                                ),
                                itemCount: vm.messages.length,
                                itemBuilder: (_, i) =>
                                    ChatBotMessageBubble(msg: vm.messages[i], vm: vm),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),

            // Floating Input Panel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Consumer<ChatBotProvider>(
                builder: (context, vm, child) {
                  return ChatBotBottomPanel(vm: vm, controller: _controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}