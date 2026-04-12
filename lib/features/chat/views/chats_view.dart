import 'package:flutter/material.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
// Core & Theme - المسارات العالمية بتبدأ بـ package


// Models - المسار الجديد داخل الميزة
import '../data/models/chat_model.dart';
// تعريف واجهات التحكم في الحالة (ViewModels) - المسار الجديد داخل الميزة
import '../view_models/chats_view_model.dart';
// Screens - لو الملف في نفس المجلد بنستخدم المسار المباشر
import 'archived_chats_view.dart';
// Widgets - نقلنا الـ chat_list_item لمجلد الـ widgets الخاص بالـ chat
import 'widgets/chat_list_item.dart';

class ChatsView extends StatefulWidget {
  const ChatsView({super.key});

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> {
  final ChatsViewModel _viewModel = ChatsViewModel();

  void _deleteWithUndo(int index, ChatModel chat) {
    setState(() {
      _viewModel.chats.remove(chat); 
      _viewModel.search(_viewModel.lastSearchQuery); 
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Deleted ${chat.doctorName}"),
        backgroundColor: AppColors.primaryLight, 
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "Undo",
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _viewModel.chats.insert(index, chat);
              _viewModel.search(_viewModel.lastSearchQuery);
            });
          },
        ),
      ),
    );
  }

  void _archiveChat(ChatModel chat) {
    setState(() {
      chat.isArchived = true; 
      _viewModel.search(_viewModel.lastSearchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ الآن الخلفية ستتغير تلقائياً حسب الثيم (أبيض في الفاتح / أسود صريح في الدارك)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // 🚀 خلينا الخلفية شفافة وشيلنا الظل زي البروفايل بظبط
        backgroundColor: Colors.transparent,
        elevation: 0,
        // 🚀 زرار الرجوع الاحترافي المتجاوب مع الدارك واللايت
        leading: BackButton(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        title: Text('Chats',
            style: TextStyle(
              // 🚀 لون النص متجاوب مع الثيم
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            )),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          final archivedCount = _viewModel.chats.where((c) => c.isArchived).length;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildSearchBar(context),
                const SizedBox(height: 16),
                if (archivedCount > 0) _buildArchiveHeader(archivedCount, context),
                Expanded(
                  child: ListView.builder(
                    itemCount: _viewModel.filteredChats.length,
                    itemBuilder: (context, index) {
                      final chat = _viewModel.filteredChats[index];
                      if (chat.isArchived) return const SizedBox.shrink();

                      return ChatListItem(
                        chat: chat,
                        onDelete: () => _deleteWithUndo(index, chat),
                        onArchive: () => _archiveChat(chat),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        // ✅ استخدام لون الكارت المخصص للدارك من ملف الألوان
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: _viewModel.search,
        style: TextStyle(color: AppColors.primaryLight),
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: AppColors.primaryLight),
          hintText: 'Search your doctor...',
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildArchiveHeader(int count, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArchivedChatsView(viewModel: _viewModel),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // ✅ ألوان متفاعلة مع الدارك مود لمنع البهتان أو البياض الزائد
          color: isDarkMode ? const Color(0xFF1A2E28) : const Color(0xFFF0F5F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.archive_outlined, color: AppColors.primaryLight),
            const SizedBox(width: 12),
            Text("Archived Chats", 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryLight // نص واضح
              )
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("$count", style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
