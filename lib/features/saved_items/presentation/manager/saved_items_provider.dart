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

  Future<void> fetchSavedItems() async {
    if (_allPharmacies.isNotEmpty || _allMedications.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _dataSource.getSavedItems();
      _allPharmacies = data['pharmacies'] as List<SavedPharmacyModel>;
      _allMedications = data['medications'] as List<SavedMedicationModel>;
      _applyFilters();
    } catch (e) {
      debugPrint("Error fetching saved items: $e");
    }

    _isLoading = false;
    notifyListeners();
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
      return item.name.toLowerCase().contains(_currentQuery.toLowerCase()) && item.isSaved;
    }).toList();

    _filteredMedications = _allMedications.where((item) {
      return item.name.toLowerCase().contains(_currentQuery.toLowerCase()) && item.isSaved;
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

  void removePharmacy(SavedPharmacyModel item) {
    final index = _allPharmacies.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _allPharmacies[index].isSaved = false;
      _applyFilters();
    }
  }

  void undoRemovePharmacy(SavedPharmacyModel item) {
    final index = _allPharmacies.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _allPharmacies[index].isSaved = true;
      _applyFilters();
    }
  }

  void removeMedication(SavedMedicationModel item) {
    final index = _allMedications.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _allMedications[index].isSaved = false;
      _applyFilters();
    }
  }

  void undoRemoveMedication(SavedMedicationModel item) {
    final index = _allMedications.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _allMedications[index].isSaved = true;
      _applyFilters();
    }
  }

  // ==========================================
  // 🚀 الإضافات الجديدة للربط مع شاشة الصيدلية
  // ==========================================

  // 1. التأكد هل الصيدلية محفوظة بناءً على اسمها/الـ ID
  bool isPharmacySaved(String id) {
    final index = _allPharmacies.indexWhere((p) => p.id == id);
    return index != -1 && _allPharmacies[index].isSaved;
  }

  // 2. إضافة أو مسح الصيدلية لما ندوس على علامة الـ Bookmark
  void togglePharmacySavedStatus(SavedPharmacyModel newPharmacy) {
    final index = _allPharmacies.indexWhere((p) => p.id == newPharmacy.id);
    if (index != -1) {
      // لو موجودة، اعكس حالتها
      _allPharmacies[index].isSaved = !_allPharmacies[index].isSaved;
    } else {
      // لو مش موجودة خالص، ضيفها
      _allPharmacies.add(newPharmacy);
    }
    _applyFilters(); 
  }
}