import 'package:flutter/foundation.dart';
import 'package:medinear_app/features/home/domain/entities/medicine_entity.dart';
import 'package:medinear_app/features/home/domain/repositories/home_repository.dart';

class CategoryMedicinesProvider extends ChangeNotifier {
  final HomeRepository repository;
  
  CategoryMedicinesProvider(this.repository);

  List<MedicineEntity> medicines = [];
  bool isLoading = false;
  bool isFetchingMore = false;
  String? errorMessage;
  
  int _currentPage = 1;
  final int _perPage = 10;
  bool _hasMoreData = true;

  bool get hasMoreData => _hasMoreData;

  Future<void> fetchMedicines(String categoryId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      medicines.clear();
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    } else {
      if (!_hasMoreData || isFetchingMore || isLoading) return;
      isFetchingMore = true;
      notifyListeners();
    }

    try {
      final newMedicines = await repository.getCategoryMedicines(
        categoryId,
        _currentPage,
        _perPage,
      );

      if (newMedicines.length < _perPage) {
        _hasMoreData = false;
      }

      medicines.addAll(newMedicines);
      _currentPage++;
      
      isLoading = false;
      isFetchingMore = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      isFetchingMore = false;
      errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
    }
  }
}
