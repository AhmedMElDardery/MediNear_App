import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/chat_bot_model.dart'; 
import 'package:medinear_app/core/services/gemini_service.dart';
import 'package:medinear_app/core/services/groq_service.dart'; // ✅ ضفنا جرّوك هنا

class ChatBotProvider extends ChangeNotifier {
  // ✅ عرفنا السيرفرين مع بعض عشان يشتغلوا كبدلاء لبعض
  final GeminiService _geminiService = GeminiService(); 
  final GroqService _groqService = GroqService(); 

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

  // ✅ التعديل هنا فقط: دمجنا الذكاء الاصطناعي مع خطة بديلة (Fallback)
  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. إضافة رسالة المستخدم
    _messages.add(
      ChatMessage(
        id: DateTime.now().toString(),
        text: text,
        isBot: false,
        timestamp: DateTime.now(),
      ),
    );

    _isTyping = true;
    notifyListeners();

    // 2. محاولة الرد من الأسئلة الثابتة أولاً
    String response = _analyzeMedicalInput(text);
    
    // 3. لو الرد هو "الرد الافتراضي" (يعني مش فاهم)، يروح لـ الذكاء الاصطناعي
    if (response.startsWith("Sorry, I didn't quite understand")) {
      try {
        // نجرب جيميناي الأول
        response = await _geminiService.getResponse(text);
        
        // لو جيميناي عليه ضغط أو رجع إيرور، نحول الطلب لـ جروك فوراً
        if (response.contains("خطأ") || 
            response.contains("رفض") || 
            response.contains("Unavailable") ||
            response.contains("Error")) {
          debugPrint("⚠️ جيميناي مشغول.. جاري التحويل لـ جروك...");
          response = await _groqService.getResponse(text);
        }
      } catch (e) {
        // لو حصل أي كراش في جيميناي، جروك يشيل الليلة
        debugPrint("⚠️ كراش في جيميناي.. جاري التحويل لـ جروك...");
        try {
          response = await _groqService.getResponse(text);
        } catch (e2) {
          // لو النت فصل خالص والسيرفرين وقعوا، يرجع للرد الافتراضي
          response = _analyzeMedicalInput(text); 
        }
      }
    } else {
      // لو السؤال موجود في القائمة الثابتة، بنعمل تأخير بسيط عشان نحاكي التفكير
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    // 4. إضافة رد البوت (سواء ثابت أو من AI)
    _messages.add(
      ChatMessage(
        id: DateTime.now().toString(),
        text: response,
        isBot: true,
        timestamp: DateTime.now(),
      ),
    );
    
    // ✅ حساب وقت الانتظار لعلامة الكتابة حسب طول الرد (سرعناه عشان يواكب سرعة الكتابة الجديدة)
    int extraWait = response.length * 12; 

    Future.delayed(Duration(milliseconds: extraWait), () {
      _isTyping = false; 
      notifyListeners();
    });

    notifyListeners();
  }

  // ✅ الأسئلة والردود الثابتة (زي ما هي بالظبط)
  String _analyzeMedicalInput(String input) {
    input = input.toLowerCase().trim();

    if (input == 'hi' ||
        input == 'hey' ||
        input.startsWith('hi ') ||
        input.contains('hello') ||
        input.contains('welcome')) {
      return 'Welcome! I am your MidiNear assistant 💙\nHow can I guide you today?';
    }

    if (input.contains('medicine') ||
        input.contains('order') ||
        input.contains('guide') ||
        input.contains('buy')) {
      return 'To complete your order easily, follow these steps:\n1. Use the Smart Search bar on the home screen.\n2. Select the required medicine and add it to your cart.\n3. Click "Checkout" to confirm the process.';
    }

    if (input.contains('track') ||
        input.contains('shipment') ||
        input.contains('status')) {
      return 'To follow up on your order:\n1. Open "My Orders" history.\n2. You will find shipment details and real-time status.';
    }

    if (input.contains('instant') ||
        input.contains('consultation') ||
        input.contains('doctor') ||
        input.contains('physician')) {
      return 'To get a medical consultation:\n1. Go to the "Messages" tab.\n2. Choose the specialized doctor and start the conversation immediately.';
    }

    if (input.contains('find') ||
        input.contains('pharmacy') ||
        input.contains('search') ||
        input.contains('map')) {
      return 'To find a pharmacy:\n1. Open the "Map" section.\n2. The nearest available pharmacies around you will appear.';
    }

    if (input.contains('medication') ||
        input.contains('schedule') ||
        input.contains('reminder') ||
        input.contains('time')) {
      return 'To set your medication times:\n1. Access the "Medicine Reminder" feature.\n2. Add the doses, and I will alert you at the scheduled time.';
    }

    if (input.contains('account') ||
        input.contains('wallet') ||
        input.contains('pay')) {
      return 'To manage your account and payment:\n1. Open "Profile" to edit your data.\n2. You can pay via E-wallet or cards.';
    }

    return "Sorry, I didn't quite understand your inquiry.\nI am the MidiNear guide, does your question concern:\n- Medicine Order Guide\n- Track Shipment\n- Instant Consultation\n- Find a Pharmacy\n- Medication Schedule\n- Account & Wallet? 💙";
  }

  void clearChat() {
    _messages = [];
    _isTyping = false;
    notifyListeners();
  }
}