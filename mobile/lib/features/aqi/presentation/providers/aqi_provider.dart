import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turkiye_cevre_guvenligi/features/aqi/data/aqi_repository.dart';
import 'package:turkiye_cevre_guvenligi/features/aqi/data/remote/aqi_dto.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/api_service.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/cache_service.dart';

class AQIProvider extends ChangeNotifier {
  List<AirQuality> _stations = [];
  bool _isLoading = false;
  String? _error;
  AirQuality? _selectedStation;

  List<AirQuality> get stations => _stations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AirQuality? get selectedStation => _selectedStation;

  AQIProvider(BuildContext context) {
    _init(context);
  }

  void _init(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final cacheService = Provider.of<CacheService>(context, listen: false);
    final repository = AQIRepository(apiService, cacheService);
    _loadAQI(repository);
  }

  Future<void> _loadAQI(AQIRepository repository) async {
    _isLoading = true;
    notifyListeners();

    try {
      _stations = await repository.getAirQuality();
      _selectedStation = _stations.isNotEmpty ? _stations.first : null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh(BuildContext context) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final cacheService = Provider.of<CacheService>(context, listen: false);
    final repository = AQIRepository(apiService, cacheService);

    _isLoading = true;
    notifyListeners();

    try {
      _stations = await repository.getAirQuality(forceRefresh: true);
      _selectedStation = _stations.isNotEmpty ? _stations.first : null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectStation(AirQuality station) {
    _selectedStation = station;
    notifyListeners();
  }
}
