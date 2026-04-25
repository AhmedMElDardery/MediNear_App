import '../models/chat_bot_model.dart';

class ChatBotRepository {
  List<ChatMessage> getInitialMessages() {
    return [
      ChatMessage(
        // ✅ الـ ID والـ Timestamp هيفضلوا زي ما هما
        id: 'repo_start_msg',
        text: 'Welcome to MidiNear Smart Assistant!',
        isBot: true,
        timestamp: DateTime.now(),
      )
    ];
  }
}
