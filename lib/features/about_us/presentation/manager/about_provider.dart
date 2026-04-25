import 'package:flutter/material.dart';
import '../../data/models/support_model.dart';
import '../../data/datasources/about_remote_data_source.dart';

class AboutProvider extends ChangeNotifier {
  final AboutRemoteDataSource _dataSource = AboutRemoteDataSource();

  List<SupportModel> _supportOptions = [];
  String _version = "";
  bool _isLoading = false;

  List<SupportModel> get supportOptions => _supportOptions;
  String get version => _version;
  bool get isLoading => _isLoading;

  Future<void> loadAboutData() async {
    // 🚀 منع التحميل المتكرر لو الداتا موجودة فعلاً
    if (_supportOptions.isNotEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      _supportOptions = await _dataSource.getSupportOptions();
      _version = await _dataSource.getAppVersion();
    } catch (e) {
      debugPrint("About Provider Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
