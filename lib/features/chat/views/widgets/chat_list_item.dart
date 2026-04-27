import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:medinear_app/features/chat/data/models/chat_model.dart';

import '../chat_details_view.dart'; // ده مكانه الجديد في نفس المجلد// ✅ إضافة استيراد ملف الألوان الجديد للوصول لدالة لون النص

class ChatListItem extends ConsumerStatefulWidget {
  final ChatModel chat;
  final VoidCallback onDelete;
  final VoidCallback onArchive;

  const ChatListItem({
    super.key,
    required this.chat,
    required this.onDelete,
    required this.onArchive,
  });

  @override
  ConsumerState<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends ConsumerState<ChatListItem> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    // معرفة حالة الثيم (دارك أم فاتح) لضبط الظل والألوان الفرعية
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ChatDetailsView())),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            // ✅ اللون المتجاوب: أبيض في الفاتح، ورمادي داكن في الدارك
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF198B61).withValues(alpha: 0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                // ✅ تقليل الظل في الدارك مود ليكون التصميم أنظف
                color: const Color(0xFF198B61)
                    .withValues(alpha: isDarkMode ? 0.0 : 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                _buildAvatar(isDarkMode),
                const SizedBox(width: 15),
                Expanded(child: _buildChatInfo(context, isDarkMode)),
                _buildTrailingAction(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF198B61).withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 26,
        // ✅ خلفية متجاوبة لصورة الطبيب
        backgroundColor:
            isDarkMode ? Colors.grey[800] : const Color(0xFFF0F5F2),
        backgroundImage: AssetImage(widget.chat.avatarImagePath),
      ),
    );
  }

  Widget _buildChatInfo(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ لون اسم الطبيب متجاوب (أسود/أبيض) لعدم البهتان
        Text(widget.chat.doctorName,
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 17)),
        const SizedBox(height: 4),
        Text(
          widget.chat.isTyping ? "typing..." : widget.chat.lastMessage,
          style: TextStyle(
            // ✅ تعديل لون الرسالة ليكون مقروءاً في الوضعين
            color: widget.chat.isTyping
                ? const Color(0xFF198B61)
                : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            fontWeight:
                widget.chat.isTyping ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingAction(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(widget.chat.time,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        PopupMenuButton<String>(
          icon:
              const Icon(Icons.more_horiz, color: Color(0xFF198B61), size: 28),
          // ✅ خلفية القائمة المنسدلة أصبحت متجاوبة
          color: Theme.of(context).cardColor,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: const Color(0xFF198B61).withValues(alpha: 0.1)),
          ),
          onSelected: (value) {
            if (value == 'delete') widget.onDelete();
            if (value == 'archive') widget.onArchive();
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'archive',
              child: Row(
                children: [
                  Icon(
                    widget.chat.isArchived
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                    color: const Color(0xFF198B61),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.chat.isArchived ? 'Unarchive Chat' : 'Archive Chat',
                    style: const TextStyle(
                      color: Color(0xFF198B61),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(height: 1),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    'Delete Chat',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
