import 'package:flutter/material.dart';
import 'package:medinear_app/features/alarm/data/models/alarm_model.dart';

class AlarmViewModel extends ChangeNotifier {
  final AlarmModel medication = AlarmModel(
    medicationName: 'Lipitor',
    dosageInfo: '20 mg',
  );

  List<String> times = ['07:00 AM', '12:00 PM'];
  String startDate = '2024-10-26';

  // ✅ التعديل الأول: استخدام Set لحفظ حالة كل سماعة بناءً على رقمها (Index)
  Set<int> mutedIndices = {};

  // متغيرات الكروت الأخرى
  int doseCount = 1;
  String selectedFrequency = 'Weekly';
  List<String> frequencies = ['Daily', 'Weekly'];
  List<int> selectedDays = [6];

  // ✅ التعديل الثاني: الدالة بقت تستقبل الـ index عشان تقفل/تفتح سماعة محددة
  void toggleVolume(int index) {
    if (mutedIndices.contains(index)) {
      mutedIndices.remove(index); // لو مقفولة، افتحها
    } else {
      mutedIndices.add(index); // لو مفتوحة، اقفلها
    }
    notifyListeners();
  }

  // ✅ التعديل الثالث: دالة بتسأل هل السماعة دي مقفولة ولا لأ
  bool isMuted(int index) {
    return mutedIndices.contains(index);
  }

  void addTime(String newTime) {
    times.add(newTime);
    notifyListeners();
  }

  void updateStartDate(String date) {
    startDate = date;
    notifyListeners();
  }

  // دوال إضافية للتحكم في الأيام والجرعات
  void setDose(int count) {
    doseCount = count;
    notifyListeners();
  }

  void updateFrequency(String freq) {
    selectedFrequency = freq;
    notifyListeners();
  }

  void toggleDay(int day) {
    selectedDays.contains(day)
        ? selectedDays.remove(day)
        : selectedDays.add(day);
    notifyListeners();
  }
}
