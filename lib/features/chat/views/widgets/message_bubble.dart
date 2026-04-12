import 'package:flutter/material.dart';
import 'package:medinear_app/features/chat/data/models/message_model.dart';


class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    bool isMe = message.isMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // صورة الطبيب بجانب رسالته فقط
          if (!isMe) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 20, color: Colors.grey),
            ),
            const SizedBox(width: 8),
          ],

          // صندوق الرسالة
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF198B61) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      // عكس الزوايا الحادة بناءً على المُرسل
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    border:
                        isMe ? null : Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // الوقت
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message.time,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey)),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all,
                          size: 14, color: Colors.grey), // علامة الصح
                    ]
                  ],
                ),
              ],
            ),
          ),

          if (isMe)
            const SizedBox(width: 32), // مسافة فارغة يميناً لرسائل المستخدم
        ],
      ),
    );
  }
}

