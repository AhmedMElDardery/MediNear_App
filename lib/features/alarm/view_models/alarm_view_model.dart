import 'package:flutter/material.dart';
import 'package:medinear_app/features/alarm/data/models/alarm_model.dart';
import 'package:medinear_app/core/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:alarm/alarm.dart';

class AlarmViewModel extends ChangeNotifier {
  final Dio dio;

  AlarmViewModel({required this.dio}) {
    _loadFromPrefs();
  }

  AlarmModel medication = AlarmModel(
    medicationName: '',
    dosageInfo: '',
  );

  List<String> times = [];
  String startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  bool isLoadingMedicines = false;
  List<dynamic> availableMedicines = [];
  List<Map<String, dynamic>> savedAlarms = [];

  String? editingAlarmId; // Tracks the ID of the alarm being edited

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
  void incrementDose() {
    doseCount++;
    notifyListeners();
  }

  void decrementDose() {
    if (doseCount > 1) {
      doseCount--;
      notifyListeners();
    }
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

  void updateMedicationName(String name) {
    medication = AlarmModel(
      id: medication.id,
      title: medication.title,
      time: medication.time,
      isEnabled: medication.isEnabled,
      dosageInfo: medication.dosageInfo,
      medicationName: name,
    );
    notifyListeners();
  }

  void updateDosageInfo(String dosage) {
    medication = AlarmModel(
      id: medication.id,
      title: medication.title,
      time: medication.time,
      isEnabled: medication.isEnabled,
      medicationName: medication.medicationName,
      dosageInfo: dosage,
    );
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('saved_alarms_list');
    if (dataString != null) {
      try {
        final List<dynamic> decodedList = json.decode(dataString);
        savedAlarms = decodedList.map((e) => e as Map<String, dynamic>).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading alarms list: $e');
      }
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    // If editing, use the same ID, otherwise generate a new one
    final alarmIdStr = editingAlarmId ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    final newAlarm = {
      'id': alarmIdStr,
      'medicationName': medication.medicationName,
      'dosageInfo': medication.dosageInfo,
      'times': times,
      'startDate': startDate,
      'doseCount': doseCount,
      'selectedFrequency': selectedFrequency,
      'selectedDays': selectedDays,
    };
    
    if (editingAlarmId != null) {
      // Remove old alarm before saving updated one
      savedAlarms.removeWhere((alarm) => alarm['id'] == editingAlarmId);
    }
    
    savedAlarms.add(newAlarm);
    await prefs.setString('saved_alarms_list', json.encode(savedAlarms));
    notifyListeners();
  }

  void clearForm() {
    medication = AlarmModel(medicationName: '', dosageInfo: '');
    times = [];
    mutedIndices = {};
    doseCount = 1;
    selectedFrequency = 'Weekly';
    selectedDays = [6];
    startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    editingAlarmId = null; // Clear edit mode
    notifyListeners();
  }

  void loadAlarmForEdit(Map<String, dynamic> alarm) {
    editingAlarmId = alarm['id'];
    medication = AlarmModel(
      medicationName: alarm['medicationName'] ?? '',
      dosageInfo: alarm['dosageInfo'] ?? '',
    );
    times = List<String>.from(alarm['times'] ?? []);
    mutedIndices = {}; // Assuming all active on edit for simplicity
    doseCount = alarm['doseCount'] ?? 1;
    selectedFrequency = alarm['selectedFrequency'] ?? 'Weekly';
    selectedDays = List<int>.from(alarm['selectedDays'] ?? []);
    startDate = alarm['startDate'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    notifyListeners();
  }

  Future<void> deleteAlarm(String id) async {
    savedAlarms.removeWhere((alarm) => alarm['id'] == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_alarms_list', json.encode(savedAlarms));
    notifyListeners();
  }

  Future<void> fetchMedicines() async {
    isLoadingMedicines = true;
    notifyListeners();
    try {
      final response = await dio.get('/pharmacy/medicines');
      var data = response.data['data'];
      if (data is List) {
        availableMedicines = data;
      }
    } catch (e) {
      debugPrint('Error fetching medicines: $e');
    }
    isLoadingMedicines = false;
    notifyListeners();
  }

  Future<void> saveReminder(BuildContext context) async {
    try {
      final notificationService = NotificationService();
      
      // First, request permissions if not already granted
      await notificationService.requestPermissions();

      // Ensure initialization
      await notificationService.init();

      // Base date (assuming startDate is yyyy-MM-dd)
      DateTime baseDate;
      try {
        baseDate = DateFormat('yyyy-MM-dd').parse(startDate);
      } catch (e) {
        baseDate = DateTime.now();
      }

      int alarmIdCounter = DateTime.now().millisecondsSinceEpoch % 100000; // Unique ID
      int scheduledCount = 0;

      if (times.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please add at least one time.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      if (medication.medicationName.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter or select a medication name.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      for (int i = 0; i < times.length; i++) {
        if (isMuted(i)) continue; // Skip if alarm is muted

        String timeStr = times[i];
        DateTime parsedTime;
        try {
          // Use 'h:mm a' to support both '06:18 PM' and '6:18 PM'
          parsedTime = DateFormat('h:mm a').parse(timeStr);
        } catch (e) {
          debugPrint('Error parsing time: $timeStr');
          continue;
        }

        // Create scheduled date
        DateTime scheduledDate = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          parsedTime.hour,
          parsedTime.minute,
        );

        // If scheduled time is in the past, schedule for next day
        if (scheduledDate.isBefore(DateTime.now())) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        final alarmSettings = AlarmSettings(
          id: alarmIdCounter++,
          dateTime: scheduledDate,
          assetAudioPath: 'assets/audio/alarm.mp3',
          loopAudio: true,
          vibrate: true,
          volumeSettings: VolumeSettings.fade(
            fadeDuration: const Duration(seconds: 3),
          ),
          notificationSettings: NotificationSettings(
            title: 'Medication Reminder: ${medication.medicationName}',
            body: 'It is time to take $doseCount of ${medication.medicationName}. ${medication.dosageInfo}',
            stopButton: 'Stop',
          ),
          warningNotificationOnKill: Platform.isIOS,
        );

        await Alarm.set(alarmSettings: alarmSettings);
        scheduledCount++;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$scheduledCount Alarms scheduled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await _saveToPrefs();
        // Go back to the previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error scheduling alarm: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule alarm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
