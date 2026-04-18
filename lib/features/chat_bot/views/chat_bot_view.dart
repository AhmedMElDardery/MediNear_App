import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/chat_bot_provider.dart';
import 'widgets/chat_bot_styles.dart';
import 'widgets/chat_bot_painters.dart';
import 'widgets/chat_bot_header.dart';
import 'widgets/chat_bot_empty_state.dart';
import 'widgets/chat_bot_message_bubble.dart';
import 'widgets/chat_bot_bottom_panel.dart';

// ============================================================
// Main Chat View - English Version (LTR)
// ============================================================
class ChatBotView extends StatefulWidget {
  const ChatBotView({super.key});
  @override
  State<ChatBotView> createState() => _ChatBotViewState();
}

class _ChatBotViewState extends State<ChatBotView>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _bgCtrl;

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
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ChatBotProvider>(context);
    final isEmpty = vm.messages.isEmpty;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // استخدام Directionality للتأكد من أن التطبيق بالكامل يعمل بنظام LTR
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            // Background Animation (Aurora Effect)
            AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) => CustomPaint(
                painter: GreenAuroraPainter(_bgCtrl.value),
                child: const SizedBox.expand(),
              ),
            ),

            // Layout Layer
            Column(
              children: [
                ChatBotHeader(vm: vm),
                Expanded(
                  child: isEmpty
                      ? ChatBotEmptyState(vm: vm)
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            16,
                            12,
                            16,
                            // ترك مساحة تحتية عشان الرسايل ما تختفيش ورا الـ Bottom Panel
                            MediaQuery.of(context).size.height * 0.23,
                          ),
                          itemCount: vm.messages.length,
                          itemBuilder: (_, i) =>
                              ChatBotMessageBubble(msg: vm.messages[i], vm: vm),
                        ),
                ),
              ],
            ),

            // Floating Input Panel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ChatBotBottomPanel(vm: vm, controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}
