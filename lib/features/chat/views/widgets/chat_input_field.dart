import 'package:flutter/material.dart';
import 'package:medinear_app/features/chat/view_models/chat_details_view_model.dart';

class ChatInputField extends StatelessWidget {
  final ChatDetailsViewModel viewModel;

  const ChatInputField({
    super.key, 
    required this.viewModel,
  });

  // قائمة خيارات الـ (+) بتصميم احترافي (مستوحى من واتساب)
  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // شفاف لعمل تأثير الـ Floating
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // الارتفاع يتناسب مع المحتوى
          children: [
            // مقبض السحب (Drag Handle)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Wrap(
              spacing: 30, // المسافة الأفقية
              runSpacing: 24, // المسافة الرأسية
              alignment: WrapAlignment.center,
              children: [
                _buildActionItem(Icons.insert_drive_file, "Document", const Color(0xFF5F66CD), context, () {
                  Navigator.pop(context);
                  viewModel.pickAndSendDocument();
                }),
                _buildActionItem(Icons.camera_alt, "Camera", const Color(0xFFD3396D), context, () {
                  Navigator.pop(context);
                  viewModel.pickAndSendCameraImage();
                }),
                _buildActionItem(Icons.photo_library, "Gallery", const Color(0xFFAC54FF), context, () {
                  Navigator.pop(context);
                  viewModel.pickAndSendImage();
                }),
                _buildActionItem(Icons.headphones, "Audio", const Color(0xFFF07128), context, () {
                  Navigator.pop(context);
                  viewModel.pickAndSendAudioFile();
                }),
                _buildActionItem(Icons.location_on, "Location", const Color(0xFF009688), context, () {
                  Navigator.pop(context);
                  viewModel.sendCurrentLocation();
                }),
                _buildActionItem(Icons.person, "Contact", const Color(0xFF00A3FF), context, () {
                  Navigator.pop(context);
                  viewModel.pickAndSendContact();
                }),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color,
      BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70, // تثبيت العرض لضمان ترتيب الشبكة
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([viewModel, viewModel.messageController]),
          builder: (context, child) {
            bool isTyping = viewModel.messageController.text.trim().isNotEmpty;
            bool isRecording = viewModel.isRecording;
            
            String _formatDuration(int seconds) {
              final minutes = (seconds / 60).floor();
              final remainingSeconds = seconds % 60;
              return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
            }

            return Row(
              children: [
                if (!isRecording)
                  IconButton(
                    icon: Icon(Icons.add,
                        color: Theme.of(context).colorScheme.primary, size: 28),
                    onPressed: () => _showAttachmentMenu(context),
                  ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(25)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              IgnorePointer(
                                ignoring: isRecording,
                                child: Opacity(
                                  opacity: isRecording ? 0.0 : 1.0,
                                  child: TextField(
                                    controller: viewModel.messageController,
                                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                                    decoration: const InputDecoration(
                                        hintText: 'Type a message...',
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none),
                                  ),
                                ),
                              ),
                              if (isRecording)
                                Row(
                                  children: [
                                    // النقطة الحمراء النابضة للتسجيل
                                    const Icon(Icons.mic, color: Colors.red, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDuration(viewModel.recordingDuration),
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const Spacer(),
                                    const Text("Slide to cancel <", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        if (!isRecording)
                          IconButton(
                            icon: const Icon(Icons.camera_alt_outlined,
                                color: Colors.grey, size: 22),
                            onPressed: viewModel.pickAndSendCameraImage,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: isTyping ? viewModel.sendMessage : null,
                  onLongPress: !isTyping ? viewModel.startRecording : null,
                  onLongPressMoveUpdate: !isTyping ? (details) {
                    if (viewModel.isRecording && details.localOffsetFromOrigin.dx < -50) {
                      viewModel.cancelRecording();
                    }
                  } : null,
                  onLongPressEnd: !isTyping ? (_) {
                    if (viewModel.isRecording) {
                      viewModel.stopRecording();
                    }
                  } : null,
                  onLongPressCancel: !isTyping ? () {
                    if (viewModel.isRecording) {
                      viewModel.cancelRecording();
                    }
                  } : null,
                  child: CircleAvatar(
                    radius: isRecording ? 25 : 20, // يكبر الزر قليلاً أثناء التسجيل
                    backgroundColor: isRecording 
                        ? Colors.red 
                        : (isTyping
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).cardColor),
                    child: Icon(
                        isRecording 
                            ? Icons.mic 
                            : (isTyping ? Icons.send : Icons.mic_none),
                        color: isRecording 
                            ? Colors.white 
                            : (isTyping ? Colors.white : Colors.grey), 
                        size: isRecording ? 24 : 20),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}