import 'package:flutter/material.dart';
import '../../data/models/saved_item_models.dart';
import '../../data/datasources/saved_items_remote_data_source.dart';

class SavedItemsProvider extends ChangeNotifier {
  final SavedItemsRemoteDataSource _dataSource = SavedItemsRemoteDataSource();

  List<SavedPharmacyModel> _allPharmacies = [];
  List<SavedMedicationModel> _allMedications = [];

  List<SavedPharmacyModel> _filteredPharmacies = [];
  List<SavedMedicationModel> _filteredMedications = [];

  bool _isLoading = false;
  bool _isAscending = true;
  String _currentQuery = "";

  List<SavedPharmacyModel> get pharmacies => _filteredPharmacies;
  List<SavedMedicationModel> get medications => _filteredMedications;
  bool get isLoading => _isLoading;
  bool get isAscending => _isAscending;

  int get savedPharmaciesCount => _filteredPharmacies.length;
  int get savedMedicationsCount => _filteredMedications.length;

  // 🚀 جلب البيانات من السيرفر
  // 🚀 جلب البيانات من السيرفر
  Future<void> fetchSavedItems({bool silent = false}) async {
    // ❌ مسحنا السطر اللي كان بيعمل "بلوك" للـ API
    // وبكده كل ما تفتح الصفحة هيكلم السيرفر ويجيب أحدث حاجة

    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final data = await _dataSource.getSavedItems();
      _allPharmacies = data['pharmacies'] as List<SavedPharmacyModel>;
      _allMedications = data['medications'] as List<SavedMedicationModel>;

      for (var p in _allPharmacies) {
        p.isSaved = true;
      }

      _applyFilters();
    } catch (e) {
      debugPrint("Error fetching saved items: $e");
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void search(String query) {
    _currentQuery = query;
    _applyFilters();
  }

  void toggleSort() {
    _isAscending = !_isAscending;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredPharmacies = _allPharmacies.where((item) {
      return item.name.toLowerCase().contains(_currentQuery.toLowerCase()) &&
          item.isSaved;
    }).toList();

    _filteredMedications = _allMedications.where((item) {
      return item.name.toLowerCase().contains(_currentQuery.toLowerCase()) &&
          item.isSaved;
    }).toList();

    if (_isAscending) {
      _filteredPharmacies.sort((a, b) => a.name.compareTo(b.name));
      _filteredMedications.sort((a, b) => a.name.compareTo(b.name));
    } else {
      _filteredPharmacies.sort((a, b) => b.name.compareTo(a.name));
      _filteredMedications.sort((a, b) => b.name.compareTo(a.name));
    }

    notifyListeners();
  }

  // 🚀 دالة الحذف (لما اليوزر يدوس مسح أو Swipe)
  Future<void> removePharmacy(SavedPharmacyModel item) async {
    final index = _allPharmacies.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      // 1. مسح من الشاشة فوراً (Optimistic UI)
      _allPharmacies[index].isSaved = false;
      _applyFilters();

      // 2. إرسال الطلب للسيرفر في الخلفية
      bool success = await _dataSource.toggleSavePharmacy(item.id.toString());
      if (!success) {
        // لو السيرفر فشل (مفيش نت مثلاً)، نرجعها تاني للشاشة
        _allPharmacies[index].isSaved = true;
        _applyFilters();
        debugPrint("API Error: Failed to remove pharmacy from server.");
      }
    }
  }

  // 🚀 دالة التراجع (لما اليوزر يدوس Undo من رسالة الـ SnackBar)
  Future<void> undoRemovePharmacy(SavedPharmacyModel item) async {
    final index = _allPharmacies.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      // 1. إرجاع للشاشة فوراً
      _allPharmacies[index].isSaved = true;
      _applyFilters();

      // 2. إرسال الطلب للسيرفر يعيد حفظها
      bool success = await _dataSource.toggleSavePharmacy(item.id.toString());
      if (!success) {
        // لو فشل، نمسحها تاني
        _allPharmacies[index].isSaved = false;
        _applyFilters();
      }
    }
  }

  // ----------------------------------------------------
  // باقي دوال الأدوية (بدون تغيير)
  // ----------------------------------------------------
  Future<String?> removeMedication(SavedMedicationModel item) async {
    final index = _allMedications.indexWhere((element) => 
        element.id == item.id && element.pharmacyId == item.pharmacyId);
    if (index != -1) {
      _allMedications[index].isSaved = false;
      _applyFilters();

      // 🚀 إرسال الطلب للسيرفر
      var response = await _dataSource.toggleSaveMedicine(item.id.toString(), item.pharmacyId ?? '0');
      if (response != true) {
        _allMedications[index].isSaved = true;
        _applyFilters();
        debugPrint("API Error: $response");
        return response.toString(); // Return the exact error string
      }
    }
    return null; // Success
  }

  Future<String?> undoRemoveMedication(SavedMedicationModel item) async {
    final index = _allMedications.indexWhere((element) => 
        element.id == item.id && element.pharmacyId == item.pharmacyId);
    if (index != -1) {
      _allMedications[index].isSaved = true;
      _applyFilters();

      // 🚀 إرسال الطلب للسيرفر
      var response = await _dataSource.toggleSaveMedicine(item.id.toString(), item.pharmacyId ?? '0');
      if (response != true) {
        _allMedications[index].isSaved = false;
        _applyFilters();
        return response.toString();
      }
    }
    return null;
  }

  bool isPharmacySaved(String id) {
    final index = _allPharmacies.indexWhere((p) => p.id == id);
    return index != -1 && _allPharmacies[index].isSaved;
  }

  void togglePharmacySavedStatus(SavedPharmacyModel newPharmacy) {
    final index = _allPharmacies.indexWhere((p) => p.id == newPharmacy.id);
    if (index != -1) {
      _allPharmacies[index].isSaved = !_allPharmacies[index].isSaved;
    } else {
      _allPharmacies.add(newPharmacy);
    }
    _applyFilters();
  }
}
