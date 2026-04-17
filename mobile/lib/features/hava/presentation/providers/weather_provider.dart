import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turkiye_cevre_guvenligi/features/hava/data/weather_repository.dart';
import 'package:turkiye_cevre_guvenligi/features/hava/data/remote/weather_dto.dart';
import 'package:turkiye_cevre_guvenligi/shared/providers/settings_provider.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/api_service.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/cache_service.dart';

class WeatherProvider extends ChangeNotifier {
  Weather? _weather;
  bool _isLoading = false;
  String? _error;
  String _selectedCity = 'Istanbul';
  List<String> _cities = [];

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCity => _selectedCity;
  List<String> get cities => _cities;

  WeatherProvider(BuildContext context) {
    _init(context);
  }

  void _init(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final cacheService = Provider.of<CacheService>(context, listen: false);
    final repository = WeatherRepository(apiService, cacheService);
    _cities = repository.getSupportedCities();
    _loadWeather(repository);
  }

  Future<void> _loadWeather(WeatherRepository repository) async {
    _isLoading = true;
    notifyListeners();

    try {
      _weather = await repository.getWeather(_selectedCity);
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
    final repository = WeatherRepository(apiService, cacheService);

    _isLoading = true;
    notifyListeners();

    try {
      _weather = await repository.getWeather(_selectedCity, forceRefresh: true);
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
    final repository = WeatherRepository(apiService, cacheService);
    await _loadWeather(repository);
  }

  bool isFavorite(String city, BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    return settings.favoriteCities.contains(city);
  }

  void toggleFavorite(String city, BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (isFavorite(city, context)) {
      settings.removeFavoriteCity(city);
    } else {
      settings.addFavoriteCity(city);
    }
    notifyListeners();
  }
}
