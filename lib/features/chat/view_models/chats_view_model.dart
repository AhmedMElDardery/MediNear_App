import 'package:flutter/material.dart';

import '../data/models/chat_model.dart';
import '../data/repositories/chat_repository.dart';

class ChatsViewModel extends ChangeNotifier {
  final ChatRepository repository;

  List<ChatModel> chats = [];
  List<ChatModel> filteredChats = [];
  bool isLoading = false;
  String? errorMessage;

  String lastSearchQuery = "";

  ChatsViewModel(this.repository) {
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      chats = await repository.getSessions();
      if (lastSearchQuery.isNotEmpty) {
        search(lastSearchQuery);
      } else {
        filteredChats = List.from(chats);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    lastSearchQuery = query;

    if (query.isEmpty) {
      filteredChats = List.from(chats);
    } else {
      filteredChats = chats
          .where((chat) =>
              chat.name.toLowerCase().contains(query.toLowerCase()) || 
              chat.doctorName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}

