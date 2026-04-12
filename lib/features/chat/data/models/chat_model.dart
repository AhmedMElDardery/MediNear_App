class ChatModel {
  final String id;
  final String name;
  final String doctorName;
  final String lastMessage;
  final String time;
  final String avatarImagePath;
  final bool isTyping;
  bool isArchived;

  ChatModel({
    this.id = '',
    this.name = '',
    this.doctorName = '',
    this.lastMessage = '',
    this.time = '',
    this.avatarImagePath = '',
    this.isTyping = false,
    this.isArchived = false,
  });
}