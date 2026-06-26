import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:convert';

class GeminiService {
  static String get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'] ?? "";
    if (key == 'your_gemini_api_key_here') return "";
    return key;
  }
  static const String _apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  final Dio _dio = Dio();

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
    if (_apiKey.isEmpty) {
      return await _getMockResponse(prompt);
    }
    try {
      final response = await _dio.post(
        _apiUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': _apiKey,
          },
        ),
        data: {
          "systemInstruction": {
            "parts": [
              {"text": _systemRules}
            ]
          },
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        },
      );

      if (response.statusCode == 200) {
        return response.data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception("كود الخطأ: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint("❌ Gemini Server Error: ${e.response?.data}");
        String errorMessage =
            e.response?.data['error']['message'] ?? 'خطأ غير معروف';
        throw Exception("رفض من السيرفر: $errorMessage");
      } else {
        throw Exception("تأكد من اتصال الإنترنت: ${e.message}");
      }
    } catch (e) {
      throw Exception("خطأ غير متوقع: $e");
    }
  }

  Future<String> getResponseWithImage(String prompt, File imageFile) async {
    if (_apiKey.isEmpty) {
      return await _getMockResponse(prompt);
    }
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      String mimeType = 'image/jpeg';
      final path = imageFile.path.toLowerCase();
      if (path.endsWith('.png')) mimeType = 'image/png';
      else if (path.endsWith('.webp')) mimeType = 'image/webp';

      final response = await _dio.post(
        _apiUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': _apiKey,
          },
        ),
        data: {
          "systemInstruction": {
            "parts": [
              {"text": _systemRules}
            ]
          },
          "contents": [
            {
              "parts": [
                {"text": prompt},
                {
                  "inlineData": {
                    "mimeType": mimeType,
                    "data": base64Image
                  }
                }
              ]
            }
          ]
        },
      );

      if (response.statusCode == 200) {
        return response.data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception("كود الخطأ: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint("❌ Gemini Vision Server Error: ${e.response?.data}");
        String errorMessage =
            e.response?.data['error']['message'] ?? 'خطأ غير معروف';
        throw Exception("رفض من السيرفر: $errorMessage");
      } else {
        throw Exception("تأكد من اتصال الإنترنت: ${e.message}");
      }
    } catch (e) {
      throw Exception("خطأ غير متوقع: $e");
    }
  }

  Future<String> _getMockResponse(String prompt) async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (prompt.contains("Translate the following medicine information JSON into")) {
      return '''
      {
        "trade_name": "بانادول إكسترا (تجريبي)",
        "generic_name": "باراسيتامول وكافيين",
        "category": "مسكن للألم وخافض للحرارة",
        "indications": "يستخدم لتخفيف الآلام الخفيفة والمتوسطة مثل الصداع، وألم الأسنان.",
        "dosage": "قرص إلى قرصين كل 4-6 ساعات. الحد الأقصى 8 أقراص يومياً.",
        "side_effects": ["غثيان خفيف", "أرق", "اضطراب في المعدة"],
        "warnings": ["لا تتجاوز الجرعة الموصى بها", "قلل من تناول الكافيين"],
        "contraindications": "المرضى الذين يعانون من حساسية تجاه الباراسيتامول.",
        "pregnancy_category": "آمن بشكل عام أثناء الحمل والرضاعة (ينصح باستشارة الطبيب بسبب الكافيين).",
        "interactions": ["أدوية السيولة مثل الوارفارين", "بعض مضادات الاكتئاب"],
        "overdose": "أعراض: غثيان، ألم بالمعدة، تلف كبدي محتمل. الإجراء: اذهب للمستشفى فوراً.",
        "food_interactions": "تجنب شرب القهوة ومشروبات الطاقة بكثرة أثناء استخدامه.",
        "mechanism_of_action": "يقلل من إنتاج البروستاجلاندين في الدماغ لتقليل الألم والحرارة، والكافيين يعزز تأثيره.",
        "alternatives": ["أدول إكسترا", "فيفادول إكسترا", "أبيمول"],
        "prescription_needed": false,
        "storage": "يحفظ في درجة حرارة أقل من 30 مئوية.",
        "manufacturer": "جلاكسو سميث كلاين"
      }
      ''';
    } else if (prompt.contains("Provide detailed structured information about the medicine")) {
      return '''
      {
        "trade_name": "Panadol Extra (Mock)",
        "generic_name": "Paracetamol & Caffeine",
        "category": "Analgesic & Antipyretic",
        "indications": "Used to relieve mild to moderate pain such as headache, toothache, and fever.",
        "dosage": "1-2 tablets every 4-6 hours as needed. Max 8 tablets/day.",
        "side_effects": ["Mild nausea", "Insomnia", "Stomach upset"],
        "warnings": ["Do not exceed recommended dose", "Limit caffeine intake"],
        "contraindications": "Patients hypersensitive to Paracetamol.",
        "pregnancy_category": "Generally safe, but caution advised due to caffeine content.",
        "interactions": ["Blood thinners like Warfarin", "Some antidepressants"],
        "overdose": "Symptoms: Nausea, stomach pain, liver damage. Action: Seek immediate medical help.",
        "food_interactions": "Avoid excessive consumption of coffee or energy drinks.",
        "mechanism_of_action": "Reduces prostaglandin production in the brain to lower pain/fever; caffeine enhances this effect.",
        "alternatives": ["Adol Extra", "Fevadol Extra", "Abimol"],
        "prescription_needed": false,
        "storage": "Store below 30°C in a dry place.",
        "manufacturer": "GSK"
      }
      ''';
    } else if (prompt.contains("extracted from a medical prescription")) {
      return '''
      [
        {"name": "Augmentin 1g", "dosage": "Every 12 hours for 7 days (Mock)"},
        {"name": "Panadol 500mg", "dosage": "When needed for pain (Mock)"}
      ]
      ''';
    } else if (prompt.contains("أي تعارضات دوائية خطيرة")) {
      return "آمن: لا توجد تعارضات خطيرة معروفة بين هذه الأدوية (نتيجة تجريبية).";
    } else if (prompt.contains("التعرف على الدواء من خلال اللون، الشكل")) {
      return '''
      {
        "name": "Ibuprofen 400mg (Mock)",
        "description": "مسكن للآلام ومضاد للالتهاب.",
        "confidence": "عالية"
      }
      ''';
    } else if (prompt.contains("كشف الأدوية المغشوشة")) {
      return '''
      {
        "is_authentic": true,
        "analysis": "تبدو العلبة أصلية والطباعة واضحة (نتيجة تجريبية)."
      }
      ''';
    } else if (prompt.contains("تفاعلات دوائية مع الغذاء")) {
      return "هذا طعام صحي. يرجى تجنب عصير الجريب فروت مع بعض أدوية الضغط (نتيجة تجريبية).";
    }

    return "رد تجريبي عام من النظام لعدم توفر مفتاح الـ API.";
  }
}
