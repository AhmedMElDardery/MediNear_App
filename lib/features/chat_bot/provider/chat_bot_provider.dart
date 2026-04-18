import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/chat_bot_model.dart'; 

class ChatBotProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];

  bool _isTyping = false;
  bool get isTyping => _isTyping;
  List<ChatMessage> get messages => _messages;

  final List<String> suggestions = [
    'Medicine Order Guide',
    'Track Shipment',
    'Instant Consultation',
    'Find a Pharmacy',
    'Medication Schedule',
    'Account & Wallet',
  ];

  void deleteMessage(String messageId) {
    _messages.removeWhere((m) => m.id == messageId);
    notifyListeners();
  }

  void addReaction(String messageId, String emoji) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      _messages[index].reaction = (_messages[index].reaction == emoji)
          ? null
          : emoji;
      notifyListeners();
    }
  }

  void setTyping(bool value) {
    if (_isTyping != value) {
      _isTyping = value;
      notifyListeners();
    }
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // إضافة رسالة المستخدم
    _messages.add(
      ChatMessage(
        id: DateTime.now().toString(),
        text: text,
        isBot: false,
        timestamp: DateTime.now(),
      ),
    );

    _isTyping = true; // البدء في إظهار علامة الكتابة
    notifyListeners();

    // تأخير بسيط لمحاكاة تفكير البوت (1.5 ثانية)
    Future.delayed(const Duration(milliseconds: 1500), () {
      String response = _analyzeMedicalInput(text);
      
      // إضافة رد البوت
      _messages.add(
        ChatMessage(
          id: DateTime.now().toString(),
          text: response,
          isBot: true,
          timestamp: DateTime.now(),
        ),
      );
      
      // ✅ التعديل هنا: علامة الكتابة بتفضل شغالة لوقت إضافي 
      // بيتحسب بناءً على طول الرسالة (تقريباً 30-40 ملي ثانية لكل حرف)
      // ده بيضمن إن العلامة ما تختفيش غير لما الأنميشن يخلص لآخر حرف.
      int extraWait = response.length * 35; 

      Future.delayed(Duration(milliseconds: extraWait), () {
        _isTyping = false; 
        notifyListeners();
      });

      notifyListeners();
    });
  }

  // ✅ تحليل النصوص والردود (محفوظة بالكامل كما طلبت)
  String _analyzeMedicalInput(String input) {
    input = input.toLowerCase().trim();

    // 1. الترحيب
    if (input == 'hi' ||
        input == 'hey' ||
        input.startsWith('hi ') ||
        input.contains('hello') ||
        input.contains('welcome')) {
      return 'Welcome! I am your MidiNear assistant 💙\nHow can I guide you today?';
    }

    // 2. دليل طلب الأدوية
    if (input.contains('medicine') ||
        input.contains('order') ||
        input.contains('guide') ||
        input.contains('buy')) {
      return 'To complete your order easily, follow these steps:\n1. Use the Smart Search bar on the home screen.\n2. Select the required medicine and add it to your cart.\n3. Click "Checkout" to confirm the process.';
    }

    // 3. تتبع الشحنة
    if (input.contains('track') ||
        input.contains('shipment') ||
        input.contains('status')) {
      return 'To follow up on your order:\n1. Open "My Orders" history.\n2. You will find shipment details and real-time status.';
    }

    // 4. استشارة طبية
    if (input.contains('instant') ||
        input.contains('consultation') ||
        input.contains('doctor') ||
        input.contains('physician')) {
      return 'To get a medical consultation:\n1. Go to the "Messages" tab.\n2. Choose the specialized doctor and start the conversation immediately.';
    }

    // 5. البحث عن صيدلية
    if (input.contains('find') ||
        input.contains('pharmacy') ||
        input.contains('search') ||
        input.contains('map')) {
      return 'To find a pharmacy:\n1. Open the "Map" section.\n2. The nearest available pharmacies around you will appear.';
    }

    // 6. الجدول الدوائي
    if (input.contains('medication') ||
        input.contains('schedule') ||
        input.contains('reminder') ||
        input.contains('time')) {
      return 'To set your medication times:\n1. Access the "Medicine Reminder" feature.\n2. Add the doses, and I will alert you at the scheduled time.';
    }

    // 7. الحساب والمحفظة
    if (input.contains('account') ||
        input.contains('wallet') ||
        input.contains('pay')) {
      return 'To manage your account and payment:\n1. Open "Profile" to edit your data.\n2. You can pay via E-wallet or cards.';
    }

    // 8. الرد الافتراضي
    return "Sorry, I didn't quite understand your inquiry.\nI am the MidiNear guide, does your question concern:\n- Medicine Order Guide\n- Track Shipment\n- Instant Consultation\n- Find a Pharmacy\n- Medication Schedule\n- Account & Wallet? 💙";
  }

  void clearChat() {
    _messages = [];
    _isTyping = false;
    notifyListeners();
  }
}