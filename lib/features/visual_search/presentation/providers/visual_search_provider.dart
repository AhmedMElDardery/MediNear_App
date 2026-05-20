import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/visual_search_repository.dart';
import '../../domain/usecases/visual_search_usecases.dart';
import '../../data/models/search_history_model.dart';

enum VisualSearchState { initial, loading, success, error }

class VisualSearchProvider extends ChangeNotifier {
  final VisualSearchRepository repository;
  final ExtractTextUseCase extractTextUseCase;
  final SearchMedicationUseCase searchMedicationUseCase;
  final ParsePrescriptionUseCase parsePrescriptionUseCase;
  final CheckDrugInteractionsUseCase checkDrugInteractionsUseCase;
  final IdentifyPillUseCase identifyPillUseCase;
  final CheckCounterfeitUseCase checkCounterfeitUseCase;
  final CheckFoodInteractionUseCase checkFoodInteractionUseCase;
  final GetMedicineDetailsUseCase getMedicineDetailsUseCase;
  final TranslateMedicineDetailsUseCase translateMedicineDetailsUseCase;

  VisualSearchProvider({
    required this.repository,
    required this.extractTextUseCase,
    required this.searchMedicationUseCase,
    required this.parsePrescriptionUseCase,
    required this.checkDrugInteractionsUseCase,
    required this.identifyPillUseCase,
    required this.checkCounterfeitUseCase,
    required this.checkFoodInteractionUseCase,
    required this.getMedicineDetailsUseCase,
    required this.translateMedicineDetailsUseCase,
  }) {
    loadHistory();
  }

  VisualSearchState _state = VisualSearchState.initial;
  VisualSearchState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<SearchHistoryModel> _history = [];
  List<SearchHistoryModel> get history => _history;

  Map<String, dynamic>? _searchResult;
  Map<String, dynamic>? get searchResult => _searchResult;

  List<Map<String, dynamic>>? _prescriptionResult;
  List<Map<String, dynamic>>? get prescriptionResult => _prescriptionResult;

  Map<String, dynamic>? _pillResult;
  Map<String, dynamic>? get pillResult => _pillResult;

  Map<String, dynamic>? _counterfeitResult;
  Map<String, dynamic>? get counterfeitResult => _counterfeitResult;

  String? _foodInteractionResult;
  String? get foodInteractionResult => _foodInteractionResult;

  File? _currentImage;
  File? get currentImage => _currentImage;

  bool _isCheckingInteractions = false;
  bool get isCheckingInteractions => _isCheckingInteractions;

  String? _interactionsResult;
  String? get interactionsResult => _interactionsResult;

  // ─── Medicine Details ──────────────────────────────────────────────────────
  Map<String, dynamic>? _medicineDetails;
  Map<String, dynamic>? get medicineDetails => _medicineDetails;

  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  String? _detailsError;
  String? get detailsError => _detailsError;

  // ─── Translation ───────────────────────────────────────────────────────────
  Map<String, dynamic>? _translatedDetails;
  Map<String, dynamic>? get translatedDetails => _translatedDetails;

  bool _isTranslating = false;
  bool get isTranslating => _isTranslating;

  bool _showTranslation = false;
  bool get showTranslation => _showTranslation;

  void _setState(VisualSearchState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    try {
      final data = await repository.getSearchHistory();
      data.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _history = data;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading history: $e");
    }
  }

  Future<void> deleteHistoryItem(SearchHistoryModel item) async {
    try {
      await repository.deleteSearchHistory(item.key);
      _history.remove(item);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting history item: $e");
    }
  }

  Future<void> startVisualSearch(ImageSource source) async {
    try {
      _setState(VisualSearchState.loading);
      _errorMessage = '';
      _searchResult = null;
      _prescriptionResult = null;
      _medicineDetails = null;
      _translatedDetails = null;
      _showTranslation = false;

      final image = await repository.pickImage(source);
      if (image == null) { _setState(VisualSearchState.initial); return; }

      final cropped = await repository.cropImage(image);
      if (cropped == null) { _setState(VisualSearchState.initial); return; }
      _currentImage = cropped;

      final text = await extractTextUseCase.execute(cropped);
      if (text.trim().isEmpty) {
        _errorMessage = 'لم نتمكن من التعرف على أي نص. يرجى التقاط صورة أوضح.';
        _setState(VisualSearchState.error);
        return;
      }

      final result = await searchMedicationUseCase.execute(text);
      if (result != null) {
        _searchResult = result;

        await repository.saveSearchHistory(SearchHistoryModel(
          text: text,
          imagePath: cropped.path,
          timestamp: DateTime.now(),
        ));
        await loadHistory();

        _setState(VisualSearchState.success);

        // Auto-load details
        _loadMedicineDetails(result['name'] ?? text);
      } else {
        _errorMessage = 'لم يتم العثور على نتائج للنص: $text';
        _setState(VisualSearchState.error);
      }
    } catch (e) {
      _errorMessage = e.toString().contains("No medication")
          ? 'لم يتم العثور على الدواء'
          : 'حدث خطأ غير متوقع: $e';
      _setState(VisualSearchState.error);
    }
  }

  Future<void> _loadMedicineDetails(String medicineName) async {
    _isLoadingDetails = true;
    _detailsError = null;
    notifyListeners();

    try {
      _medicineDetails = await getMedicineDetailsUseCase.execute(medicineName);
    } catch (e) {
      _detailsError = e.toString();
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  Future<void> retryLoadDetails() async {
    if (_searchResult == null) return;
    await _loadMedicineDetails(_searchResult!['name'] ?? '');
  }

  Future<void> toggleTranslation() async {
    if (_medicineDetails == null) return;

    if (_showTranslation) {
      _showTranslation = false;
      notifyListeners();
      return;
    }

    if (_translatedDetails != null) {
      _showTranslation = true;
      notifyListeners();
      return;
    }

    _isTranslating = true;
    notifyListeners();

    try {
      _translatedDetails = await translateMedicineDetailsUseCase.execute(
        _medicineDetails!,
        'Arabic',
      );
      _showTranslation = true;
    } catch (e) {
      debugPrint('Translation error: $e');
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  Future<void> startPrescriptionScan(ImageSource source) async {
    try {
      _setState(VisualSearchState.loading);
      _errorMessage = '';
      _searchResult = null;
      _prescriptionResult = null;

      final image = await repository.pickImage(source);
      if (image == null) { _setState(VisualSearchState.initial); return; }

      final cropped = await repository.cropImage(image);
      if (cropped == null) { _setState(VisualSearchState.initial); return; }
      _currentImage = cropped;

      final text = await extractTextUseCase.execute(cropped);
      if (text.trim().isEmpty) {
        _errorMessage = 'لم نتمكن من التعرف على أي نص في الروشتة.';
        _setState(VisualSearchState.error);
        return;
      }

      final medications = await parsePrescriptionUseCase.execute(text);

      if (medications.isNotEmpty) {
        _prescriptionResult = medications;

        await repository.saveSearchHistory(SearchHistoryModel(
          text: 'روشتة: ${medications.length} أدوية',
          imagePath: cropped.path,
          timestamp: DateTime.now(),
        ));
        await loadHistory();

        _setState(VisualSearchState.success);
      } else {
        _errorMessage = 'لم يتعرف الذكاء الاصطناعي على أدوية واضحة في هذه الروشتة.';
        _setState(VisualSearchState.error);
      }
    } catch (e) {
      _errorMessage = e.toString().contains("No medication")
          ? 'لم يتم العثور على أدوية'
          : 'حدث خطأ غير متوقع أثناء تحليل الروشتة: $e';
      _setState(VisualSearchState.error);
    }
  }

  void _resetResults() {
    _searchResult = null;
    _prescriptionResult = null;
    _pillResult = null;
    _counterfeitResult = null;
    _foodInteractionResult = null;
    _interactionsResult = null;
    _isCheckingInteractions = false;
    _medicineDetails = null;
    _translatedDetails = null;
    _showTranslation = false;
    _isLoadingDetails = false;
    _detailsError = null;
  }

  Future<void> startPillIdentification(ImageSource source) async {
    try {
      _setState(VisualSearchState.loading);
      _errorMessage = '';
      _resetResults();

      final image = await repository.pickImage(source);
      if (image == null) { _setState(VisualSearchState.initial); return; }
      final cropped = await repository.cropImage(image);
      if (cropped == null) { _setState(VisualSearchState.initial); return; }
      _currentImage = cropped;

      final result = await identifyPillUseCase.execute(cropped);
      _pillResult = result;
      _setState(VisualSearchState.success);

      await repository.saveSearchHistory(SearchHistoryModel(
        text: 'فحص حبة دواء: ${result['name']}',
        imagePath: cropped.path,
        timestamp: DateTime.now(),
      ));
      await loadHistory();
    } catch (e) {
      _errorMessage = e.toString();
      _setState(VisualSearchState.error);
    }
  }

  Future<void> startCounterfeitCheck(ImageSource source) async {
    try {
      _setState(VisualSearchState.loading);
      _errorMessage = '';
      _resetResults();

      final image = await repository.pickImage(source);
      if (image == null) { _setState(VisualSearchState.initial); return; }
      final cropped = await repository.cropImage(image);
      if (cropped == null) { _setState(VisualSearchState.initial); return; }
      _currentImage = cropped;

      final result = await checkCounterfeitUseCase.execute(cropped);
      _counterfeitResult = result;
      _setState(VisualSearchState.success);

      await repository.saveSearchHistory(SearchHistoryModel(
        text: 'كشف غش: ${result['is_authentic'] ? 'أصلي' : 'مشتبه به'}',
        imagePath: cropped.path,
        timestamp: DateTime.now(),
      ));
      await loadHistory();
    } catch (e) {
      _errorMessage = e.toString();
      _setState(VisualSearchState.error);
    }
  }

  Future<void> startFoodInteractionCheck(ImageSource source) async {
    try {
      _setState(VisualSearchState.loading);
      _errorMessage = '';
      _resetResults();

      final image = await repository.pickImage(source);
      if (image == null) { _setState(VisualSearchState.initial); return; }
      final cropped = await repository.cropImage(image);
      if (cropped == null) { _setState(VisualSearchState.initial); return; }
      _currentImage = cropped;

      final result = await checkFoodInteractionUseCase.execute(cropped);
      _foodInteractionResult = result;
      _setState(VisualSearchState.success);

      await repository.saveSearchHistory(SearchHistoryModel(
        text: 'تحليل طعام / مكمل',
        imagePath: cropped.path,
        timestamp: DateTime.now(),
      ));
      await loadHistory();
    } catch (e) {
      _errorMessage = e.toString();
      _setState(VisualSearchState.error);
    }
  }

  Future<void> checkInteractions() async {
    if (_prescriptionResult == null || _prescriptionResult!.isEmpty) return;

    try {
      _isCheckingInteractions = true;
      _interactionsResult = null;
      notifyListeners();

      final result = await checkDrugInteractionsUseCase.execute(_prescriptionResult!);
      _interactionsResult = result;
    } catch (e) {
      _interactionsResult = 'حدث خطأ أثناء فحص التعارضات. يرجى المحاولة لاحقاً.';
    } finally {
      _isCheckingInteractions = false;
      notifyListeners();
    }
  }

  void reset() {
    _state = VisualSearchState.initial;
    _errorMessage = '';
    _currentImage = null;
    _resetResults();
    notifyListeners();
  }
}
