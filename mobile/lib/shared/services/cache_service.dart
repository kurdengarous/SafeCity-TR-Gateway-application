import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const String _earthquakeBox = 'earthquake_cache';
  static const String _weatherBox = 'weather_cache';
  static const String _aqiBox = 'aqi_cache';
  static const String _prayerBox = 'prayer_cache';
  static const String _currencyBox = 'currency_cache';

  static late Box _earthquakes;
  static late Box _weather;
  static late Box _aqi;
  static late Box _prayer;
  static late Box _currency;

  static Future<void> init() async {
    _earthquakes = await Hive.openBox(_earthquakeBox);
    _weather = await Hive.openBox(_weatherBox);
    _aqi = await Hive.openBox(_aqiBox);
    _prayer = await Hive.openBox(_prayerBox);
    _currency = await Hive.openBox(_currencyBox);
  }

  Future<void> cacheEarthquakes(List<dynamic> data) async {
    await _earthquakes.put('data', jsonEncode(data));
    await _earthquakes.put('timestamp', DateTime.now().toIso8601String());
  }

  List<dynamic>? getEarthquakes() {
    final data = _earthquakes.get('data');
    if (data != null) {
      return jsonDecode(data) as List<dynamic>;
    }
    return null;
  }

  DateTime? getEarthquakeTimestamp() {
    final ts = _earthquakes.get('timestamp');
    if (ts != null) {
      return DateTime.parse(ts);
    }
    return null;
  }

  Future<void> cacheWeather(Map<String, dynamic> data) async {
    await _weather.put('data', jsonEncode(data));
    await _weather.put('timestamp', DateTime.now().toIso8601String());
  }

  Map<String, dynamic>? getWeather() {
    final data = _weather.get('data');
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> cacheAQI(List<dynamic> data) async {
    await _aqi.put('data', jsonEncode(data));
    await _aqi.put('timestamp', DateTime.now().toIso8601String());
  }

  List<dynamic>? getAQI() {
    final data = _aqi.get('data');
    if (data != null) {
      return jsonDecode(data) as List<dynamic>;
    }
    return null;
  }

  Future<void> cachePrayer(Map<String, dynamic> data) async {
    await _prayer.put('data', jsonEncode(data));
    await _prayer.put('timestamp', DateTime.now().toIso8601String());
  }

  Map<String, dynamic>? getPrayer() {
    final data = _prayer.get('data');
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> cacheCurrency(Map<String, dynamic> data) async {
    await _currency.put('data', jsonEncode(data));
    await _currency.put('timestamp', DateTime.now().toIso8601String());
  }

  Map<String, dynamic>? getCurrency() {
    final data = _currency.get('data');
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearAll() async {
    await _earthquakes.clear();
    await _weather.clear();
    await _aqi.clear();
    await _prayer.clear();
    await _currency.clear();
  }
}
