import 'package:flutter/material.dart';
import 'package:medinear_app/features/alarm/data/models/alarm_model.dart';


class MedicationHeaderCard extends StatelessWidget {
  final AlarmModel model;

  const MedicationHeaderCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // إضافة ظل بسيط لإعطاء مظهر احترافي (اختياري)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.medication, color: Color(0xFF198B61), size: 32),
          const SizedBox(width: 16),
          Expanded( // أضفنا Expanded عشان لو النص طويل ميكسرش الـ Row
            child: Text(
              // نستخدم شرط بسيط للتأكد إن النص مش فاضي
              model.medicationName.isEmpty ? 'دواء جديد' : '${model.medicationName} ${model.dosageInfo}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis, // عشان النص ميبوظش الـ UI
            ),
          ),
        ],
      ),
    );
  }
}