import 'package:flutter/material.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
import '../../../alarm/view_models/alarm_view_model.dart';// ✅ استدعاء ملف الألوان لضبط لون النص المتجاوب

class RepeatCard extends StatelessWidget {
  final AlarmViewModel viewModel;

  const RepeatCard({super.key, required this.viewModel});

  final List<String> days = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          // ✅ خلفية متجاوبة بدلاً من الأبيض الثابت
          color: Theme.of(context).cardColor, 
          borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // ❌ تم إزالة const من هنا لدعم الألوان المتغيرة
            children: [
              Text('Repeat',
                  style: Theme.of(context).textTheme.titleLarge
                  ),
              // ✅ استخدام اللون الأساسي من الثيم بدلاً من اللون الثابت
              Icon(Icons.science_outlined, color: Theme.of(context).primaryColor),
            ],
          ),
          const SizedBox(height: 16),
          // دوائر الأيام
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (index) {
              bool isSelected = viewModel.selectedDays.contains(index);
              return GestureDetector(
                onTap: () => viewModel.toggleDay(index),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: isSelected 
                      // ✅ دعم تغيير اللون الأساسي للتطبيق
                      ? Theme.of(context).primaryColor 
                      : Colors.transparent,
                  child: Text(
                    days[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // أزرار التكرار (Daily, Weekly)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: viewModel.frequencies.map((freq) {
              bool isSelected = viewModel.selectedFrequency == freq;
              return GestureDetector(
                onTap: () => viewModel.updateFrequency(freq),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        // ✅ دعم تغيير اللون الأساسي للتطبيق
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    freq,
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
