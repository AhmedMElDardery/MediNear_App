import 'package:flutter/material.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
import 'package:medinear_app/features/alarm/view_models/alarm_view_model.dart';
// Core & Theme - استيراد الألوان باستخدام مسار الـ package الثابت

class DosageCard extends StatelessWidget {
  final AlarmViewModel viewModel;

  const DosageCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ خلفية متجاوبة (تأخذ لون الكارت من الثيم: أبيض أو رمادي داكن)
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // ❌ تم إزالة const من هنا لأننا سنقرأ حالة الثيم
            children: [
              Text('Dosage & Instructions',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('Dose (e.g., 1 tablet)',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              const Text('Take with water after breakfast',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          // الدائرة التي تحتوي على رقم الجرعة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // ✅ إطار متجاوب (أسود في الفاتح، وأبيض في الدارك)
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Text('${viewModel.doseCount}',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
