import 'package:flutter/material.dart';
import 'package:medinear_app/features/medication/data/models/medication_model.dart';


class WalletViewModel extends ChangeNotifier {
  // القائمة الافتراضية
  List<MedicationModel> medications = [
    MedicationModel(
      id: '1',
      name: 'Lisinproil 10mg',
      description: 'For blood pressure. Daily in Laezin  All (Self)',
      imagePath: 'assets/med1.png',
    ),
    MedicationModel(
      id: '2',
      name: 'Panadol 500mg',
      description: 'Take when needed for headache.',
      imagePath: 'assets/med2.png',
    ),
  ];

  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Notes', 'Image', 'Family'];

  // وظيفة تحديث الفلتر
  void updateFilter(String filter) {
    selectedFilter = filter;
    notifyListeners(); 
  }

  // وظيفة حذف الدواء
  void deleteMedication(String id) {
    medications.removeWhere((element) => element.id == id);
    notifyListeners(); 
  }

  // الوظيفة الجديدة: إضافة دواء للقائمة
  void addMedication(MedicationModel newMedication) {
    medications.add(newMedication);
    notifyListeners(); // إشعار المستمعين لتحديث واجهة المستخدم بالبيانات الجديدة
  }
}
