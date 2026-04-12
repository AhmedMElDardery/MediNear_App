class MessageModel {
  final String id;
  final String text;
  final String time;
  final bool isMe; // لمعرفة هل الرسالة مني (لون أخضر) أم من الطبيب (لون أبيض)

  MessageModel({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
  });
}
