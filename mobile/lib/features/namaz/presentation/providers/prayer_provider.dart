import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turkiye_cevre_guvenligi/features/namaz/data/prayer_repository.dart';
import 'package:turkiye_cevre_guvenligi/features/namaz/data/remote/prayer_dto.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/api_service.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/cache_service.dart';

class PrayerProvider extends ChangeNotifier {
  PrayerTime? _prayer;
  bool _isLoading = false;
  String? _error;
  String _selectedCity = 'Istanbul';
  List<String> _cities = [];

  PrayerTime? get prayer => _prayer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCity => _selectedCity;
  List<String> get cities => _cities;

  PrayerProvider(BuildContext context) {
    _init(context);
  }

  void _init(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final cacheService = Provider.of<CacheService>(context, listen: false);
    final repository = PrayerRepository(apiService, cacheService);
    _cities = repository.getSupportedCities();
    _loadPrayer(repository);
  }

  Future<void> _loadPrayer(PrayerRepository repository) async {
    _isLoading = true;
    notifyListeners();

    try {
      _prayer = await repository.getPrayerTimes(_selectedCity);
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
    final repository = PrayerRepository(apiService, cacheService);

    _isLoading = true;
    notifyListeners();

    try {
      _prayer = await repository.getPrayerTimes(_selectedCity, forceRefresh: true);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setCity(String city, BuildContext context) async {
    _selectedCity = city;
    final apiService = Provider.of<ApiService>(context, listen: false);
    final cacheService = Provider.of<CacheService>(context, listen: false);
    final repository = PrayerRepository(apiService, cacheService);
    await _loadPrayer(repository);
  }
}
