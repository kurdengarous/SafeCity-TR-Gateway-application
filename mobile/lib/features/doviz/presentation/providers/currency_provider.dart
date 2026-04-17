import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turkiye_cevre_guvenligi/features/doviz/data/currency_repository.dart';
import 'package:turkiye_cevre_guvenligi/features/doviz/data/remote/currency_dto.dart';
import 'package:turkiye_cevre_guvenligi/shared/providers/settings_provider.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/api_service.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/cache_service.dart';

class CurrencyProvider extends ChangeNotifier {
  List<CurrencyRate> _currencies = [];
  CurrencyRate? _gold;
  bool _isLoading = false;
  String? _error;

  List<CurrencyRate> get currencies => _currencies;
  CurrencyRate? get gold => _gold;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CurrencyProvider(BuildContext context) {
    _init(context);
  }

  void _init(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final cacheService = Provider.of<CacheService>(context, listen: false);
    final repository = CurrencyRepository(apiService, cacheService);
    _loadCurrencies(repository);
  }

  Future<void> _loadCurrencies(CurrencyRepository repository) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await repository.getCurrencies();
      _currencies = data.currencies;
      _gold = data.gold;
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
    final repository = CurrencyRepository(apiService, cacheService);

    _isLoading = true;
    notifyListeners();

    try {
      final data = await repository.getCurrencies(forceRefresh: true);
      _currencies = data.currencies;
      _gold = data.gold;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  bool isFavorite(String code, BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    return settings.favoriteCurrencies.contains(code);
  }

  void toggleFavorite(String code, BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final current = List<String>.from(settings.favoriteCurrencies);
    if (current.contains(code)) {
      current.remove(code);
    } else {
      current.add(code);
    }
    settings.setFavoriteCurrencies(current);
    notifyListeners();
  }
}
