class ChatModel {
  final String id;
  final String name;
  final String doctorName;
  final String lastMessage;
  final String time;
  final String avatarImagePath;
  final bool isTyping;
  bool isArchived;
  final int unreadCount;
  final int pharmacyId;
  final Map<String, dynamic> pharmacyData;

  ChatModel({
    this.id = '',
    this.name = '',
    this.doctorName = '',
    this.lastMessage = '',
    this.time = '',
    this.avatarImagePath = '',
    this.isTyping = false,
    this.isArchived = false,
    this.unreadCount = 0,
    this.pharmacyId = 0,
    this.pharmacyData = const {},
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final pharmacy = json['pharmacy'] ?? {};
    return ChatModel(
      id: json['id']?.toString() ?? '',
      name: pharmacy['pharmacy_name'] ?? 'صيدلية',
      doctorName: pharmacy['owner_name'] ?? '',
      lastMessage: '', // The API response doesn't include the last message text yet
      time: json['updated_at'] ?? '',
      avatarImagePath: pharmacy['image'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
      pharmacyId: json['pharmacy_id'] ?? 0,
      pharmacyData: pharmacy,
    );
  }
}
