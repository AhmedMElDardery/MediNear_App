import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
// Core & Theme - المسارات العالمية بتبدأ بـ package

// Models - المسار الجديد داخل الميزة
import '../data/models/chat_model.dart';
// تعريف واجهات التحكم في الحالة (ViewModels) - المسار الجديد داخل الميزة
import '../view_models/chats_view_model.dart';
// Screens - لو الملف في نفس المجلد بنستخدم المسار المباشر
import 'archived_chats_view.dart';
import 'widgets/chat_list_item.dart';
import 'package:medinear_app/core/widgets/custom_app_bar.dart';

import 'package:medinear_app/core/di/global_providers.dart';

class ChatsView extends ConsumerStatefulWidget {
  const ChatsView({super.key});

  @override
  ConsumerState<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends ConsumerState<ChatsView> {
  void _deleteWithUndo(int index, ChatModel chat) {
    final viewModel = ref.read(chatsViewModelProvider);
    viewModel.chats.remove(chat);
    viewModel.search(viewModel.lastSearchQuery);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Deleted ${chat.name}"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "Undo",
          textColor: Colors.white,
          onPressed: () {
            viewModel.chats.insert(index, chat);
            viewModel.search(viewModel.lastSearchQuery);
          },
        ),
      ),
    );
  }

  void _archiveChat(ChatModel chat) {
    final viewModel = ref.read(chatsViewModelProvider);
    chat.isArchived = true;
    viewModel.search(viewModel.lastSearchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(chatsViewModelProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        backgroundColor: Colors.transparent,
        title: 'Chats',
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildSearchBar(context, viewModel),
                  const SizedBox(height: 16),
                  if (viewModel.chats.where((c) => c.isArchived).isNotEmpty)
                    _buildArchiveHeader(viewModel.chats.where((c) => c.isArchived).length, context, viewModel),
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.filteredChats.length,
                      itemBuilder: (context, index) {
                        final chat = viewModel.filteredChats[index];
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
            ),
    );
  }


  Widget _buildSearchBar(BuildContext context, ChatsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border:
            Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: viewModel.search,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
          hintText: 'Search your doctor...',
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildArchiveHeader(int count, BuildContext context, ChatsViewModel viewModel) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArchivedChatsView(viewModel: viewModel),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // ألوان متفاعلة مع الدارك مود لمنع البهتان أو البياض الزائد
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.archive_outlined, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Text("Archived Chats",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    )),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("$count",
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}