import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  // 🚨 متنساش تغير المفتاح ده وتعمل لده Delete من موقع Groq لحماية حسابك
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? ""; 
  static const String _apiUrl = "https://api.groq.com/openai/v1/chat/completions";
  
  final Dio _dio = Dio();

  // ✅ دي الرولز الشاملة اللي هتبرمج عقل البوت
 static const String _systemRules = '''
You are a professional medical assistant for the (MidiNear) app.

CRITICAL RULE:
Always respond in the SAME LANGUAGE the user uses. 
- If the user speaks English, you MUST respond in English.
- If the user speaks Arabic, you MUST respond in Arabic.

General Rules:
1. Personality: Professional, smart, friendly, and medical expert.
2. Formatting: Do NOT use asterisks (**). 
3. Arabic Formatting: In Arabic responses, put English medical terms in parentheses like: (Aspirin).
4. Medical Accuracy: Do not suggest painkillers for bacterial infections; advise seeing a doctor.
5. Style: Keep answers very brief, accurate, and in short paragraphs.
''';

  Future<String> getResponse(String prompt) async {
    try {
      final response = await _dio.post(
        _apiUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
        ),
        data: {
          "model": "llama-3.1-8b-instant", 
          "messages": [
            {
              "role": "system",
              // ✅ هنا حقنّا الرولز في أول رسالة للموديل
              "content": _systemRules
            },
            {
              "role": "user",
              "content": prompt
            }
          ],
          "temperature": 0.7,
        },
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'];
      } else {
        return "عذراً، لم أتمكن من معالجة طلبك الآن.";
      }
    } on DioException catch (e) {
      debugPrint("❌ Groq Server Error: ${e.response?.data}");
      return "خطأ في الاتصال. يرجى التحقق من الإنترنت الخاص بك.";
    } catch (e) {
      debugPrint("❌ Exception: $e");
      return "حدث خطأ غير متوقع.";
    }
  }
}