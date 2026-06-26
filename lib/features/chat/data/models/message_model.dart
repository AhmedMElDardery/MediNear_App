class MessageModel {
  final String id;
  final String text;
  final String time;
  final bool isMe; // لمعرفة هل الرسالة مني (لون أخضر) أم من الطبيب (لون أبيض)
  final bool isRead;
  final String? filePath;
  final String type;

  MessageModel({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
    this.isRead = false,
    this.filePath,
    this.type = 'text',
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    String formattedTime = '';
    final timeRaw = json['created_at'] ?? json['time'];
    if (timeRaw != null) {
      try {
        final date = DateTime.parse(timeRaw).toLocal();
        final hour = date.hour;
        final min = date.minute.toString().padLeft(2, '0');
        final amPm = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        formattedTime = '$hour12:$min $amPm';
      } catch (_) {
        formattedTime = timeRaw.toString();
      }
    }

    // Handle full URL for image
    String? parsedFilePath = json['file_path'];
    if (parsedFilePath != null && !parsedFilePath.startsWith('http')) {
      parsedFilePath = 'https://medinear-eg.com/storage/$parsedFilePath';
    }

    return MessageModel(
      id: json['id']?.toString() ?? '',
      text: json['body'] ?? json['message'] ?? json['text'] ?? '',
      time: formattedTime,
      isMe: json['sender_type'] == 'user',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      filePath: parsedFilePath,
      type: json['type'] ?? 'text',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'type': 'text',
      'body': text,
    };
  }
}

