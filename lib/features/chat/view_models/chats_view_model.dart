import 'package:flutter/material.dart';

// استخدام المسار النسبي للوصول للموديل داخل نفس الميزة
import '../data/models/chat_model.dart';

class ChatsViewModel extends ChangeNotifier {
  // 1. تم جعل القائمة عامة باسم chats لكي نتمكن من الحذف والإضافة منها في شاشة الـ View
  List<ChatModel> chats = [
    ChatModel(id: '1', doctorName: 'Dr.Hoda', lastMessage: 'is typing..', time: '6:45pm', isTyping: true),
    ChatModel(id: '2', doctorName: 'Dr.Khaled', lastMessage: 'See you tomorrow', time: '10:30am'),
    ChatModel(id: '3', doctorName: 'Dr.Ahmed', lastMessage: 'Please check the results', time: 'Yesterday'),
  ];

  List<ChatModel> filteredChats = [];
  
  // 2. هذا المتغير هو "السر" الذي يمنع ظهور أخطاء عند الحذف أثناء البحث
  String lastSearchQuery = ""; 

  ChatsViewModel() {
    filteredChats = List.from(chats); // نستخدم List.from لأخذ نسخة آمنة من البيانات
  }

  void search(String query) {
    lastSearchQuery = query; // نحفظ الكلمة التي يبحث عنها المستخدم الآن

    if (query.isEmpty) {
      filteredChats = List.from(chats);
    } else {
      // فلترة القائمة بناءً على اسم الطبيب
      filteredChats = chats
          .where((chat) => chat.doctorName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners(); // تنبيه واجهة المستخدم لتحديث الشاشة فوراً
  }
}
