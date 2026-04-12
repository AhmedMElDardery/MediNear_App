import 'package:flutter/material.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
import '../view_models/chat_details_view_model.dart';
import 'widgets/message_bubble.dart';
import 'widgets/chat_input_field.dart';
// ✅ إضافة ملف الألوان للوصول لدالة لون النص التفاعلي


class ChatDetailsView extends StatefulWidget {
  const ChatDetailsView({super.key});

  @override
  State<ChatDetailsView> createState() => _ChatDetailsViewState();
}

class _ChatDetailsViewState extends State<ChatDetailsView> {
  final ChatDetailsViewModel _viewModel = ChatDetailsViewModel();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // معرفة حالة الثيم (دارك أم فاتح)
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ✅ خلفية متجاوبة تتبع الثيم (أسود في الدارك، وفاتح في اللايت)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      appBar: AppBar(
        // 🚀 لون الهيدر: أسود شيك في الدارك، وأبيض ناصع في اللايت عشان يبرز خط الليزر
        backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
        elevation: 0, // بنلغي الظل العادي عشان هنعمل ظل "ليزر"
        leading: BackButton(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF198B61), width: 1.5),
                // 🚀 لمسة احترافية: توهج خفيف حول صورة الدكتور
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF198B61).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                child: Icon(Icons.person, color: isDarkMode ? Colors.white70 : Colors.grey, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _viewModel.doctorName,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const Text("Online", style: TextStyle(color: Color(0xFF198B61), fontSize: 11)),
              ],
            ),
          ],
        ),
        // 🚀 السحر هنا: خط "الليزر" المضيء
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            height: 2.0,
            decoration: BoxDecoration(
              color: const Color(0xFF198B61), // اللون الأخضر
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF198B61).withOpacity(0.8), // التوهج (الليزر)
                  blurRadius: 6, // قوة التوهج
                  spreadRadius: 1, // انتشار الضوء
                  offset: const Offset(0, 2), // اتجاه الضوء لتحت
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _viewModel.messages.length,
                  itemBuilder: (context, index) => MessageBubble(message: _viewModel.messages[index]),
                );
              },
            ),
          ),
          ChatInputField(
            controller: _viewModel.messageController,
            onSend: _viewModel.sendMessage,
          ),
        ],
      ),
    );
  }
}
