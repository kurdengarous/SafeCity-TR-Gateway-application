import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turkiye_cevre_guvenligi/features/deprem/data/earthquake_repository.dart';
import 'package:turkiye_cevre_guvenligi/features/deprem/domain/earthquake.dart';
import 'package:turkiye_cevre_guvenligi/shared/providers/settings_provider.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/api_service.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/cache_service.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/notification_service.dart';

class EarthquakeProvider extends ChangeNotifier {
  List<Earthquake> _earthquakes = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdate;
  double _minMagnitude = 0;
  String? _regionFilter;

  List<Earthquake> get earthquakes => _earthquakes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdate => _lastUpdate;
  double get minMagnitude => _minMagnitude;
  String? get regionFilter => _regionFilter;

  EarthquakeProvider(BuildContext context) {
    _init(context);
  }

  void _init(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final cacheService = Provider.of<CacheService>(context, listen: false);
    final repository = EarthquakeRepository(apiService, cacheService);

    _loadEarthquakes(repository);
  }

  Future<void> _loadEarthquakes(EarthquakeRepository repository) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _earthquakes = await repository.getEarthquakes(
        minMagnitude: _minMagnitude > 0 ? _minMagnitude : null,
        region: _regionFilter,
      );
      _lastUpdate = repository.getLastUpdate();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh(BuildContext context) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final cacheService = Provider.of<CacheService>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final repository = EarthquakeRepository(apiService, cacheService);

    _isLoading = true;
    notifyListeners();

    try {
      _earthquakes = await repository.getEarthquakes(
        minMagnitude: _minMagnitude > 0 ? _minMagnitude : null,
        region: _regionFilter,
        forceRefresh: true,
      );
      _lastUpdate = repository.getLastUpdate();

      for (final eq in _earthquakes) {
        if (eq.magnitude >= settings.earthquakeThreshold) {
          await NotificationService.showEarthquakeNotification(
            location: eq.location,
            magnitude: eq.magnitude,
            time: '${eq.timestamp.hour}:${eq.timestamp.minute.toString().padLeft(2, '0')}',
          );
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setMinMagnitude(double value) {
    _minMagnitude = value;
    notifyListeners();
  }

  void setRegionFilter(String? region) {
    _regionFilter = region;
    notifyListeners();
  }
}
