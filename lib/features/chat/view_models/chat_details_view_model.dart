import 'package:flutter/material.dart';
import 'package:medinear_app/features/chat/data/models/message_model.dart';

class ChatDetailsViewModel extends ChangeNotifier {
  final String doctorName = "Dr.Khaled";
  final TextEditingController messageController = TextEditingController();

  List<MessageModel> messages = [
    MessageModel(id: '1', text: 'Hi', time: '6:30 AM', isMe: false),
    MessageModel(
        id: '2',
        text: 'How can I help you today?',
        time: '6:31 AM',
        isMe: true),
  ];

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // إضافة رسالتك للقائمة
    messages.add(
      MessageModel(
        id: DateTime.now().toString(),
        text: text,
        time:
            "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}",
        isMe: true,
      ),
    );

    messageController.clear(); // مسح الحقل بعد الإرسال
    notifyListeners(); // تحديث الشاشة فوراً
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
