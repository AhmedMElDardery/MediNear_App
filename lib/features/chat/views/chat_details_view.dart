import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../view_models/chat_details_view_model.dart';
import 'widgets/message_bubble.dart';
import 'widgets/chat_input_field.dart';
import 'package:medinear_app/core/widgets/custom_app_bar.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import 'package:medinear_app/features/chat/data/models/chat_model.dart';
import 'package:medinear_app/features/pharmacy/presentation/screens/pharmacy_screen.dart';

class ChatDetailsView extends ConsumerStatefulWidget {
  final String chatName;
  final int sessionId;
  final ChatModel? chatModel;

  const ChatDetailsView({
    super.key,
    this.chatName = "Pharmacy Chat",
    required this.sessionId,
    this.chatModel,
  });

  @override
  ConsumerState<ChatDetailsView> createState() => _ChatDetailsViewState();
}

class _ChatDetailsViewState extends ConsumerState<ChatDetailsView> {
  late ChatDetailsViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = ChatDetailsViewModel(
      repository: ref.read(chatRepositoryProvider),
      pusherService: ref.read(pusherServiceProvider),
      sessionId: widget.sessionId,
    );

    _viewModel.addListener(() {
      if (_viewModel.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        _viewModel.errorMessage = null; // Reset after showing
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    // معرفة حالة الثيم (دارك أم فاتح)
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ✅ خلفية متجاوبة تتبع الثيم (أسود في الدارك، وفاتح في اللايت)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65.0),
        child: AppBar(
          backgroundColor: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
          elevation: 2,
          shadowColor: isDarkMode ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.1),
          titleSpacing: 0, // Removes default gap between back button and title
          leading: CustomBackButton(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          title: InkWell(
            onTap: () {
              _showPharmacyInfo(context, isDarkMode);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF198B61).withValues(alpha: 0.5), width: 1.5),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          child: Icon(Icons.local_pharmacy,
                              color: isDarkMode ? Colors.white70 : const Color(0xFF198B61), size: 24),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent[400],
                            shape: BoxShape.circle,
                            border: Border.all(color: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chatName,
                          style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Online • Closes at 11:30 PM",
                          style: TextStyle(color: const Color(0xFF198B61), fontSize: 12, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.videocam_outlined),
              color: const Color(0xFF198B61),
              onPressed: () => _showCallDialog(context, isVideo: true),
            ),
            IconButton(
              icon: const Icon(Icons.call_outlined),
              color: const Color(0xFF198B61),
              onPressed: () => _showCallDialog(context, isVideo: false),
            ),
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.white70 : Colors.grey[700]),
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  offset: const Offset(0, 40),
                  onSelected: (value) {
                    if (value == 'info') {
                      _showPharmacyInfo(context, isDarkMode);
                    } else if (value == 'mute') {
                      _viewModel.toggleMute();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_viewModel.isMuted ? 'تم كتم الإشعارات لهذه المحادثة 🔕' : 'تم تفعيل الإشعارات 🔔'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF198B61),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else if (value == 'clear') {
                      _showClearChatConfirm(context);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'info',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFF198B61), size: 22),
                          SizedBox(width: 12),
                          Text('بيانات الصيدلية', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'search',
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey, size: 22),
                          SizedBox(width: 12),
                          Text('بحث في المحادثة', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'mute',
                      child: Row(
                        children: [
                          Icon(
                            _viewModel.isMuted ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
                            color: isDarkMode ? Colors.white70 : Colors.grey[700],
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(_viewModel.isMuted ? 'إلغاء الكتم' : 'كتم الإشعارات', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                          SizedBox(width: 12),
                          Text('مسح المحادثة', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                );
              }
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 🚀 خلفية النقوش الطبية الفخمة (زي واتساب)
          Positioned.fill(
            child: _buildChatPatternBackground(isDarkMode),
          ),

          Column(
            children: [
              Expanded(
                child: ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, child) {
                    // عكسنا الرسائل عشان أحدث رسالة تبقى رقم 0
                    final reversedMessages = _viewModel.messages.reversed.toList();
                    
                    return ListView.builder(
                      reverse: true, // السحر هنا: بيخلي القائمة تبدأ من تحت لفوق
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: reversedMessages.length,
                      findChildIndexCallback: (Key key) {
                        if (key is ValueKey<String>) {
                          final index = reversedMessages.indexWhere((m) => m.id == key.value);
                          if (index >= 0) return index;
                        }
                        return null;
                      },
                      itemBuilder: (context, index) =>
                          MessageBubble(
                            key: ValueKey(reversedMessages[index].id),
                            message: reversedMessages[index]
                          ),
                    );
                  },
                ),
              ),
              ChatInputField(
                viewModel: _viewModel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🚀 دالة بناء نقشة الخلفية باستخدام رموز طبية دقيقة وعشوائية (Doodles)
  Widget _buildChatPatternBackground(bool isDark) {
    // 🎨 استخدام withValues(alpha) مباشرة بدلاً من Opacity لتحسين الأداء (Smooth Transition)
    final Color iconColor = (isDark ? Colors.white : Colors.black).withValues(alpha: isDark ? 0.08 : 0.06);

    // 🌟 رموز طبية دقيقة (Size أكبر شوية عشان تبقى واضحة)
    final List<Widget> iconWidgets = [
      Icon(Icons.medical_services_outlined, color: iconColor, size: 24),
      Icon(Icons.local_pharmacy_outlined, color: iconColor, size: 24),
      Icon(Icons.healing_outlined, color: iconColor, size: 24),
      Icon(Icons.biotech_outlined, color: iconColor, size: 24),
      Icon(Icons.science_outlined, color: iconColor, size: 24),
      Icon(Icons.sanitizer_outlined, color: iconColor, size: 24),
      Icon(Icons.health_and_safety_outlined, color: iconColor, size: 24),
      Icon(Icons.vaccines_outlined, color: iconColor, size: 24),
      Icon(Icons.medication_outlined, color: iconColor, size: 24),
      Icon(Icons.masks_outlined, color: iconColor, size: 24),
      Icon(Icons.monitor_heart_outlined, color: iconColor, size: 24),
      Icon(Icons.bloodtype_outlined, color: iconColor, size: 24),
      Icon(Icons.favorite_border, color: iconColor, size: 24),
      Icon(Icons.thermostat_outlined, color: iconColor, size: 24),
      Icon(Icons.medical_information_outlined, color: iconColor, size: 24),
      Icon(Icons.spa_outlined, color: iconColor, size: 24),
      Icon(Icons.psychology_outlined, color: iconColor, size: 24),
      Icon(Icons.clean_hands_outlined, color: iconColor, size: 24),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          // 🚀 قللنا الأعمدة عشان مساحة الأيقونة تكبر وتتنفس
          crossAxisCount: 7,
          mainAxisSpacing: 35,
          crossAxisSpacing: 35,
        ),
        itemCount: 150, // متناسقة مع عدد الأعمدة
        itemBuilder: (context, index) {
          final int pseudoRandomIndex = (index * 23 + 13) % iconWidgets.length;
          final widget = iconWidgets[pseudoRandomIndex];

          // 🚀 الإزاحة يمين وشمال وفوق وتحت بشكل عشوائي عشان نكسر شكل الـ Grid المترتب
          double offsetX = ((index * 13) % 40) - 20.0;
          double offsetY = ((index * 17) % 40) - 20.0;

          // دوران عشوائي
          double rotation = ((index * 11) % 7) * 0.3 - 0.9;

          return Transform.translate(
            offset: Offset(offsetX, offsetY),
            child: Transform.rotate(
              angle: rotation,
              child: widget,
            ),
          );
        },
      );
  }

  void _showPharmacyInfo(BuildContext context, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(width: double.infinity),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    child: const Icon(Icons.local_pharmacy, color: Color(0xFF198B61), size: 40),
                  ),
                  if (widget.chatModel != null && widget.chatModel!.pharmacyId != 0)
                    Positioned(
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context); // Close bottom sheet
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PharmacyScreen(
                                pharmacyId: widget.chatModel!.pharmacyId.toString(),
                                pharmacyName: widget.chatName,
                                doctorName: widget.chatModel!.doctorName,
                                pharmacyImage: widget.chatModel!.avatarImagePath,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF198B61).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF198B61).withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'تصفح',
                                style: TextStyle(
                                  color: Color(0xFF198B61),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.storefront_outlined, color: Color(0xFF198B61), size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(widget.chatName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 8),
              Text(widget.chatModel?.pharmacyData['status'] == 'closed' ? "Pharmacy • Closed" : "Pharmacy • Open now", style: const TextStyle(color: Color(0xFF198B61), fontSize: 14)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.location_on_outlined, color: Color(0xFF198B61)),
                title: const Text('العنوان'),
                subtitle: Text((widget.chatModel?.pharmacyData['address'] ?? widget.chatModel?.pharmacyData['location'] ?? 'غير متوفر').toString()),
              ),
              ListTile(
                leading: const Icon(Icons.access_time, color: Color(0xFF198B61)),
                title: const Text('مواعيد العمل'),
                subtitle: Text((widget.chatModel?.pharmacyData['working_hours'] ?? '${widget.chatModel?.pharmacyData['open_time'] ?? '09:00 ص'} - ${widget.chatModel?.pharmacyData['close_time'] ?? '11:30 م'}').toString()),
              ),
              ListTile(
                leading: const Icon(Icons.phone_outlined, color: Color(0xFF198B61)),
                title: const Text('رقم الهاتف'),
                subtitle: Text((widget.chatModel?.pharmacyData['phone'] ?? widget.chatModel?.pharmacyData['phone_number'] ?? widget.chatModel?.pharmacyData['mobile'] ?? 'غير متوفر').toString()),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showClearChatConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('مسح المحادثة', style: TextStyle(color: Colors.redAccent)),
          content: const Text('هل أنت متأكد أنك تريد مسح جميع الرسائل في هذه المحادثة؟ لا يمكن التراجع عن هذا الإجراء.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                _viewModel.clearChatLocally();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم مسح المحادثة بنجاح'), backgroundColor: Colors.redAccent));
              },
              child: const Text('مسح', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCallDialog(BuildContext context, {required bool isVideo}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Text(isVideo ? 'مكالمة فيديو' : 'مكالمة صوتية', style: const TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 16),
              Text(widget.chatName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('جاري الاتصال...', style: TextStyle(color: Color(0xFF198B61))),
              const SizedBox(height: 32),
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF198B61).withValues(alpha: 0.1),
                child: const Icon(Icons.local_pharmacy, color: Color(0xFF198B61), size: 40),
              ),
              const SizedBox(height: 40),
              FloatingActionButton(
                backgroundColor: Colors.redAccent,
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.call_end, color: Colors.white),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
