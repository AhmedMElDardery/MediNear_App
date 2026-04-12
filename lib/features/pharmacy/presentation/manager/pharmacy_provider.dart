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
  String _currentPharmacyName = '';

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // 1. جلب البيانات من الـ API
  Future<void> fetchPharmacyData(String pharmacyName) async {
    // لو نفس الصيدلية متعملش لودينج تاني، لكن لو صيدلية جديدة امسح القديم وحمل
    if (_currentPharmacyName == pharmacyName && _medicines.isNotEmpty) return;
    
    _currentPharmacyName = pharmacyName;
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _dataSource.getPharmacyDetails(pharmacyName);
      _medicines = data['medicines'] as List<PharmacyMedicineModel>;
      _doctors = data['doctors'] as List<PharmacyDoctorModel>;
      _services = data['services'] as List<PharmacyServiceModel>;
    } catch (e) {
      debugPrint("Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. الفلترة
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<PharmacyMedicineModel> get filteredMedicines {
    if (_searchQuery.isEmpty) return _medicines;
    return _medicines.where((m) => m.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  List<PharmacyDoctorModel> get filteredDoctors {
    if (_searchQuery.isEmpty) return _doctors;
    return _doctors.where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()) || d.specialty.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  List<PharmacyServiceModel> get filteredServices {
    if (_searchQuery.isEmpty) return _services;
    return _services.where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  // 3. التفاعلات (حفظ، تنبيه)
  void toggleMedicineSaved(int id) {
    final item = _medicines.firstWhere((e) => e.id == id);
    item.isSaved = !item.isSaved;
    notifyListeners();
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