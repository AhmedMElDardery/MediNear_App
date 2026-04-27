import 'package:flutter/material.dart';
// تأكد من مسار ملف الألوان

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInputField(
      {super.key, required this.controller, required this.onSend});

  // قائمة خيارات الـ (+)
  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      // ✅ دعم الدارك مود لخلفية القائمة المنبثقة
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 250,
        child: Column(
          children: [
            Text("Attach Files",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    // ✅ لون النص يتغير حسب الثيم
                    color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(
                    Icons.image, "Photo", Colors.blue, context, () {}),
                _buildActionItem(
                    Icons.videocam, "Video", Colors.orange, context, () {}),
                _buildActionItem(Icons.insert_drive_file, "File", Colors.red,
                    context, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ تمرير context هنا عشان نقدر نغير لون النص
  Widget _buildActionItem(IconData icon, String label, Color color,
      BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
              // ✅ استخدام withValues بدلاً من withOpacity لتجنب التحذير
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color)),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).colorScheme.primary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // جلب حالة الثيم
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        // ✅ لون الخلفية الشريط السفلي يتغير حسب الثيم
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              // ✅ استخدام لون المشروع الأساسي بدلاً من اللون الثابت
              icon: Icon(Icons.add,
                  color: Theme.of(context).colorScheme.primary, size: 28),
              onPressed: () => _showAttachmentMenu(context),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    // ✅ لون فقاعة حقل الكتابة يتغير في الدارك مود
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(25)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        // ✅ لون النص المكتوب عشان ميبقاش أسود في الدارك
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined,
                          color: Colors.grey, size: 22),
                      // ✅ استخدام debugPrint بدلاً من print لتجنب التحذيرات
                      onPressed: () => debugPrint("Camera Active"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            ListenableBuilder(
              listenable: controller,
              builder: (context, child) {
                bool isTyping = controller.text.isNotEmpty;
                return GestureDetector(
                  onTap: isTyping ? onSend : () => debugPrint("Mic Active"),
                  child: CircleAvatar(
                    // ✅ ألوان المايك تتجاوب مع الدارك مود لو مفيش كتابة
                    backgroundColor: isTyping
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).cardColor,
                    child: Icon(isTyping ? Icons.send : Icons.mic,
                        color: isTyping ? Colors.white : Colors.grey, size: 20),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}