import 'dart:io';
import '../repositories/visual_search_repository.dart';
import '../../../../core/services/gemini_service.dart';
import 'dart:convert';

class ExtractTextUseCase {
  final VisualSearchRepository repository;
  ExtractTextUseCase(this.repository);

  Future<String> execute(File imageFile) async {
    return await repository.extractText(imageFile);
  }
}

class SearchMedicationUseCase {
  final VisualSearchRepository repository;
  SearchMedicationUseCase(this.repository);

  Future<Map<String, dynamic>?> execute(String query) async {
    return await repository.searchMedication(query);
  }
}

// ─── NEW: Get full medicine details from Gemini ────────────────────────────
class GetMedicineDetailsUseCase {
  final GeminiService geminiService;
  GetMedicineDetailsUseCase(this.geminiService);

  Future<Map<String, dynamic>> execute(String medicineName) async {
    final prompt = '''
You are a medical information assistant. Provide detailed structured information about the medicine: "$medicineName".

Return ONLY a valid JSON object (no markdown code blocks). The JSON must have these exact keys:
{
  "trade_name": "Commercial trade name",
  "generic_name": "Generic/active ingredient name",
  "category": "Drug category (e.g. Analgesic, Antibiotic...)",
  "indications": "What it is used for (2-3 sentences)",
  "dosage": "Standard dosage instructions",
  "side_effects": ["side effect 1", "side effect 2", "side effect 3"],
  "warnings": ["warning 1", "warning 2"],
  "contraindications": "Who should NOT take this medicine",
  "pregnancy_category": "Pregnancy and Lactation safety profile",
  "interactions": ["major interaction 1", "major interaction 2"],
  "overdose": "Symptoms of overdose and what to do",
  "food_interactions": "Any foods or drinks to avoid",
  "mechanism_of_action": "How the drug works in the body",
  "alternatives": ["alternative 1", "alternative 2"],
  "prescription_needed": true/false (boolean),
  "storage": "How to store it",
  "manufacturer": "Manufacturer name if known, otherwise Unknown"
}
If you cannot find reliable information, fill fields with "Not available" (or empty array/false).
''';

    try {
      final response = await geminiService.getResponse(prompt);
      String cleanJson = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      return jsonDecode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch medicine details: $e');
    }
  }
}

// ─── NEW: Translate medicine details ──────────────────────────────────────
class TranslateMedicineDetailsUseCase {
  final GeminiService geminiService;
  TranslateMedicineDetailsUseCase(this.geminiService);

  Future<Map<String, dynamic>> execute(
      Map<String, dynamic> details, String targetLanguage) async {
    final prompt = '''
Translate the following medicine information JSON into $targetLanguage.
Keep the JSON structure and keys exactly the same. Only translate the string values.
Translate arrays element by element.

Input JSON:
${jsonEncode(details)}

Return ONLY a valid JSON object (no markdown code blocks).
''';

    try {
      final response = await geminiService.getResponse(prompt);
      String cleanJson = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      return jsonDecode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Translation failed: $e');
    }
  }
}

class ParsePrescriptionUseCase {
  final GeminiService geminiService;
  ParsePrescriptionUseCase(this.geminiService);

  Future<List<Map<String, dynamic>>> execute(String extractedText) async {
    final prompt = '''
Here is the text extracted from a medical prescription using OCR:
---
$extractedText
---
Extract a list of medications mentioned in this text.
Return ONLY a valid JSON array of objects. Do NOT use markdown code blocks like ```json.
Each object must have:
- "name": Medication name (String)
- "dosage": Dosage or instructions if found, otherwise empty string (String)
If no medications are found, return an empty array [].
''';

    try {
      final response = await geminiService.getResponse(prompt);
      String cleanJson = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> parsed = jsonDecode(cleanJson);
      return parsed.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('فشل في تحليل الروشتة. $e');
    }
  }
}

class CheckDrugInteractionsUseCase {
  final GeminiService geminiService;
  CheckDrugInteractionsUseCase(this.geminiService);

  Future<String> execute(List<Map<String, dynamic>> medications) async {
    final medList = medications.map((m) => "- ${m['name']} (${m['dosage'] ?? ''})").join('\n');
    final prompt = '''
الرجاء مراجعة قائمة الأدوية التالية والبحث عن أي تعارضات دوائية خطيرة أو تحذيرات هامة بينها:
$medList

قم بالرد باختصار شديد وبشكل مباشر، وباللغة العربية.
إذا لم يكن هناك تعارض معروف، قل "آمن: لا توجد تعارضات خطيرة معروفة بين هذه الأدوية."
إذا كان هناك تعارض، اذكر الأدوية المتعارضة والسبب باختصار.
''';

    try {
      final response = await geminiService.getResponse(prompt);
      return response;
    } catch (e) {
      throw Exception('فشل في فحص التعارضات. $e');
    }
  }
}

class IdentifyPillUseCase {
  final GeminiService geminiService;
  IdentifyPillUseCase(this.geminiService);

  Future<Map<String, dynamic>> execute(File imageFile) async {
    const prompt = '''
قم بتحليل هذه الصورة التي تحتوي على حبة دواء أو قرص.
حاول التعرف على الدواء من خلال اللون، الشكل، وأي رموز أو حروف مطبوعة عليه.
أرجع النتيجة بصيغة JSON فقط كالتالي (بدون markdown code blocks):
{
  "name": "اسم الدواء المتوقع (أو غير معروف)",
  "description": "دواعي الاستعمال القصيرة",
  "confidence": "نسبة ثقتك في التعرف (عالية/متوسطة/منخفضة)"
}
''';
    try {
      final response = await geminiService.getResponseWithImage(prompt, imageFile);
      String cleanJson = response.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('فشل في التعرف على الحبة. $e');
    }
  }
}

class CheckCounterfeitUseCase {
  final GeminiService geminiService;
  CheckCounterfeitUseCase(this.geminiService);

  Future<Map<String, dynamic>> execute(File imageFile) async {
    const prompt = '''
أنت خبير في كشف الأدوية المغشوشة. قم بتحليل صورة علبة الدواء هذه.
ابحث عن علامات الغش التجاري مثل: رداءة الطباعة، أخطاء إملائية، ألوان باهتة، أو باركود غير واضح.
أرجع النتيجة بصيغة JSON فقط كالتالي (بدون markdown code blocks):
{
  "is_authentic": true or false,
  "analysis": "شرح مبسط لسبب الشك أو سبب الأمان"
}
''';
    try {
      final response = await geminiService.getResponseWithImage(prompt, imageFile);
      String cleanJson = response.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('فشل في فحص العلبة. $e');
    }
  }
}

class CheckFoodInteractionUseCase {
  final GeminiService geminiService;
  CheckFoodInteractionUseCase(this.geminiService);

  Future<String> execute(File imageFile) async {
    const prompt = '''
هذه صورة لطعام أو شراب أو مكمل غذائي.
1. تعرف على ما في الصورة.
2. اذكر أشهر الأدوية التي يُمنع تناولها مع هذا الطعام (تفاعلات دوائية مع الغذاء).
أجب باختصار شديد باللغة العربية وفي نقاط واضحة.
''';
    try {
      return await geminiService.getResponseWithImage(prompt, imageFile);
    } catch (e) {
      throw Exception('فشل في تحليل الطعام. $e');
    }
  }
}
