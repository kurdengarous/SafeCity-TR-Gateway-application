import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _earthquakeThreshold = 3.0;
  int _aqiThreshold = 100;
  int _refreshInterval = 15;
  List<String> _favoriteCities = [];
  List<String> _favoriteCurrencies = ['USD', 'EUR', 'XAU'];

  ThemeMode get themeMode => _themeMode;
  double get earthquakeThreshold => _earthquakeThreshold;
  int get aqiThreshold => _aqiThreshold;
  int get refreshInterval => _refreshInterval;
  List<String> get favoriteCities => _favoriteCities;
  List<String> get favoriteCurrencies => _favoriteCurrencies;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    _earthquakeThreshold = prefs.getDouble('earthquakeThreshold') ?? 3.0;
    _aqiThreshold = prefs.getInt('aqiThreshold') ?? 100;
    _refreshInterval = prefs.getInt('refreshInterval') ?? 15;
    _favoriteCities = prefs.getStringList('favoriteCities') ?? [];
    _favoriteCurrencies = prefs.getStringList('favoriteCurrencies') ?? ['USD', 'EUR', 'XAU'];
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setEarthquakeThreshold(double value) async {
    _earthquakeThreshold = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('earthquakeThreshold', value);
    notifyListeners();
  }

  Future<void> setAQIThreshold(int value) async {
    _aqiThreshold = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('aqiThreshold', value);
    notifyListeners();
  }

  Future<void> setRefreshInterval(int value) async {
    _refreshInterval = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('refreshInterval', value);
    notifyListeners();
  }

  Future<void> addFavoriteCity(String city) async {
    if (!_favoriteCities.contains(city)) {
      _favoriteCities.add(city);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favoriteCities', _favoriteCities);
      notifyListeners();
    }
  }

  Future<void> removeFavoriteCity(String city) async {
    _favoriteCities.remove(city);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteCities', _favoriteCities);
    notifyListeners();
  }

  Future<void> setFavoriteCurrencies(List<String> currencies) async {
    _favoriteCurrencies = currencies;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteCurrencies', _favoriteCurrencies);
    notifyListeners();
  }
}
