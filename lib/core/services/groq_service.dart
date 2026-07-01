import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/api_metrics_interceptor.dart';

class GroqService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? "gsk_GUEST_MODE_KEY";
  static const String _apiUrl =
      "https://api.groq.com/openai/v1/chat/completions";

  final Dio _dio = Dio();

  GroqService() {
    _dio.interceptors.add(ApiMetricsInterceptor());
  }

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
             
              "content": _systemRules
            },
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.2,
        },
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'];
      } else {
        throw Exception("كود الخطأ: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint("❌ Groq Server Error: ${e.response?.data}");
        String errorMessage = e.response?.data['error']['message'] ?? 'خطأ غير معروف';
        throw Exception("رفض من السيرفر: $errorMessage");
      } else {
        throw Exception("تأكد من اتصال الإنترنت: ${e.message}");
      }
    } catch (e) {
      throw Exception("خطأ غير متوقع: $e");
    }
  }
}
