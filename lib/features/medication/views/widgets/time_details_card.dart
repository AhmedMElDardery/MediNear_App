import 'package:flutter/material.dart';
import 'package:medinear_app/features/alarm/view_models/alarm_view_model.dart';


class TimeDetailsCard extends StatelessWidget {
  final AlarmViewModel viewModel;
  const TimeDetailsCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // التحقق من حالة الوضع الداكن (Dark Mode) لضبط التباين
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // مزامنة لون خلفية العنصر مع ثيم التطبيق
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ضبط درجة شفافية الظل لتناسب وضع الرؤية الحالي
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05), 
            blurRadius: 10
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Medication Time", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                onPressed: () => _selectTime(context),
                // ربط لون الأيقونة باللون الأساسي للمشروع
                icon: Icon(Icons.add_circle, 
                  color: Theme.of(context).primaryColor, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // استخدام asMap لاستخراج الرقم التعريفي (Index) لكل توقيت
          ...viewModel.times.asMap().entries.map((entry) => _buildTimeRow(context, entry.value, entry.key)),
          
          const Divider(height: 30),
          
          // قسم تعديل تاريخ بدء الجرعات
          InkWell(
            onTap: () => _selectDate(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, 
                      size: 18, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(viewModel.startDate, 
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                Text("Edit Date", 
                  style: TextStyle(
                    color: Theme.of(context).primaryColor, 
                    fontWeight: FontWeight.bold
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء صف التوقيت الفردي مع إمكانية التحكم في التنبيه
  Widget _buildTimeRow(BuildContext context, String time, int index) {
    // التحقق من حالة كتم الصوت لهذا العنصر تحديداً من خلال الـ ViewModel
    final isVolumeOff = viewModel.isMuted(index);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        // استخدام درجة لون خفيفة من اللون الأساسي للخلفية
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_filled, 
            size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          // التفاعل مع أيقونة الصوت وتغيير حالتها بناءً على الـ Index
          GestureDetector(
            onTap: () => viewModel.toggleVolume(index),
            child: Icon(
              isVolumeOff ? Icons.volume_off : Icons.volume_up,
              color: isVolumeOff ? Colors.grey : Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // عرض نافذة اختيار الوقت مع توريث الثيم الحالي
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context),
        child: child!,
      ),
    );
    if (picked != null) viewModel.addTime(picked.format(context));
  }

  // عرض نافذة اختيار التاريخ مع ضبط النطاق الزمني المتاح
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context),
        child: child!,
      ),
    );
    if (picked != null) viewModel.updateStartDate("${picked.year}-${picked.month}-${picked.day}");
  }
}