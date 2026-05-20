import 'dart:convert';
import 'dart:io';

void main() {
  final str1 = '''
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
      
  final str2 = '''
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

  try {
    jsonDecode(str1);
    print('str1 OK');
  } catch(e) {
    print('str1 error: $e');
  }

  try {
    jsonDecode(str2);
    print('str2 OK');
  } catch(e) {
    print('str2 error: $e');
  }
}
