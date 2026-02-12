import 'package:flutter/material.dart';
import 'package:radio_nueva_esperanza/data/models/app_config_model.dart';
import 'package:radio_nueva_esperanza/data/repositories/data_repository.dart';

class ConfigProvider extends ChangeNotifier {
  final DataRepository _repository;
  AppConfigModel? _config;
  bool _isLoading = true;

  ConfigProvider({DataRepository? repository})
      : _repository = repository ?? DataRepository();

  AppConfigModel? get config => _config;
  bool get isLoading => _isLoading;

  Future<void> loadConfig() async {
    try {
      _isLoading = true;
      notifyListeners();

      _config = await _repository.getAppConfig();
    } catch (e) {
      debugPrint("Error loading config: $e");
      // Fallback to default or cached config if implemented
      _config = AppConfigModel();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to check if a section is active
  bool isSectionActive(String sectionKey) {
    return _config?.activeSections[sectionKey] == true;
  }
}
