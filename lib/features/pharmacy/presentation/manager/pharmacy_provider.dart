import 'package:flutter/material.dart';
import '../../data/models/pharmacy_models.dart';
import '../../data/datasources/pharmacy_remote_data_source.dart';

class PharmacyProvider extends ChangeNotifier {
  final PharmacyRemoteDataSource _dataSource = PharmacyRemoteDataSource();

  List<PharmacyMedicineModel> _medicines = [];
  List<PharmacyDoctorModel> _doctors = [];
  List<PharmacyServiceModel> _services = [];

  bool _isLoading = false;
  String _searchQuery = '';
  String _currentPharmacyId = ''; // 🚀 غيرناها لـ ID

  // 🚀 المتغير اللي هينور زرار الحفظ
  bool _isPharmacySaved = false;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get isPharmacySaved => _isPharmacySaved; // 🚀 Getter عشان الـ UI يقراه

  // 1. جلب البيانات من الـ API
  Future<void> fetchPharmacyData(String pharmacyId,
      {bool isSavedLocally = false}) async {
    bool isSilent = _currentPharmacyId == pharmacyId && _medicines.isNotEmpty;
    _currentPharmacyId = pharmacyId;
    if (!isSilent) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final data = await _dataSource.getPharmacyDetails(pharmacyId);

      // 🚀 بنقرا حالة الحفظ اللي جاية من الـ API، ولو مش موجودة بنعتمد على اللوكال
      _isPharmacySaved = (data['is_saved'] == true) || isSavedLocally;

      _medicines = data['medicines'] as List<PharmacyMedicineModel>;
      _doctors = data['doctors'] as List<PharmacyDoctorModel>;
      _services = data['services'] as List<PharmacyServiceModel>;
    } catch (e) {
      debugPrint("Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // 🚀 2. دالة الضغط على زرار الحفظ
  Future<void> togglePharmacySave() async {
    if (_currentPharmacyId.isEmpty) return;

    // بنعكس الحالة فوراً قدام اليوزر (عشان يحس بالسرعة)
    _isPharmacySaved = !_isPharmacySaved;
    notifyListeners();

    // بنكلم السيرفر في الخلفية
    bool success = await _dataSource.toggleSavePharmacy(_currentPharmacyId);

    if (!success) {
      // لو السيرفر رفض أو حصل إيرور، بنرجع الزرار زي ما كان
      _isPharmacySaved = !_isPharmacySaved;
      notifyListeners();
      debugPrint("API Error: Failed to toggle save state");
    }
  }

  // ... (باقي كود الفلترة بتاعتك search و filteredMedicines الخ زي ما هو بالظبط متقلقش عليه) ...
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<PharmacyMedicineModel> get filteredMedicines {
    if (_searchQuery.isEmpty) return _medicines;
    return _medicines
        .where((m) => m.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<PharmacyDoctorModel> get filteredDoctors {
    if (_searchQuery.isEmpty) return _doctors;
    return _doctors
        .where((d) =>
            d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            d.specialty.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<PharmacyServiceModel> get filteredServices {
    if (_searchQuery.isEmpty) return _services;
    return _services
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }
  Future<void> toggleMedicineSaved(int id) async {
    final index = _medicines.indexWhere((e) => e.id == id);
    if (index == -1) return;
    
    final item = _medicines[index];
    item.isSaved = !item.isSaved;
    notifyListeners();

    // 🚀 تحديث السيرفر
    bool success = await _dataSource.toggleSaveMedicine(id.toString(), _currentPharmacyId);
    if (!success) {
      // لو فشل نرجع الحالة زي ما كانت
      item.isSaved = !item.isSaved;
      notifyListeners();
      debugPrint("API Error: Failed to toggle save medicine");
    }
  }

  void toggleMedicineNotify(int id) {
    final item = _medicines.firstWhere((e) => e.id == id);
    item.notifyAvailable = !item.notifyAvailable;
    notifyListeners();
  }

  void toggleDoctorSaved(int id) {
    final item = _doctors.firstWhere((e) => e.id == id);
    item.isSaved = !item.isSaved;
    notifyListeners();
  }

  void toggleServiceSaved(int id) {
    final item = _services.firstWhere((e) => e.id == id);
    item.isSaved = !item.isSaved;
    notifyListeners();
  }
}
