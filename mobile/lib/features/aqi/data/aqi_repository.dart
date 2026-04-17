import 'package:turkiye_cevre_guvenligi/features/aqi/data/remote/aqi_dto.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/api_service.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/cache_service.dart';

class AQIRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  static const Map<String, ({double latitude, double longitude})> _cityCoordinates = {
    'Istanbul': (latitude: 41.0082, longitude: 28.9784),
    'Ankara': (latitude: 39.9334, longitude: 32.8597),
    'Izmir': (latitude: 38.4237, longitude: 27.1428),
    'Bursa': (latitude: 40.1950, longitude: 29.0600),
    'Antalya': (latitude: 36.8969, longitude: 30.7133),
    'Konya': (latitude: 37.8746, longitude: 32.4932),
    'Adana': (latitude: 37.0000, longitude: 35.3213),
    'Gaziantep': (latitude: 37.0662, longitude: 37.3833),
    'Mersin': (latitude: 36.8121, longitude: 34.6415),
    'Diyarbakir': (latitude: 37.9144, longitude: 40.2306),
  };

  AQIRepository(this._apiService, this._cacheService);

  Future<List<AirQuality>> getAirQuality({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cacheService.getAQI();
      if (cached != null) {
        return cached.map((e) => AirQuality.fromDTO(AQIDTO.fromJson(e))).toList();
      }
    }

    final dtos = <AQIDTO>[];

    for (final entry in _cityCoordinates.entries) {
      final response = await _apiService.get<Map<String, dynamic>>(
        'https://air-quality-api.open-meteo.com/v1/air-quality',
        queryParameters: {
          'latitude': entry.value.latitude,
          'longitude': entry.value.longitude,
          'current': 'european_aqi,pm10,pm2_5,nitrogen_dioxide,ozone,sulphur_dioxide,carbon_monoxide',
          'timezone': 'Europe/Istanbul',
        },
        parser: (data) => data as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final current = response.data!['current'] as Map<String, dynamic>?;
        if (current != null) {
          dtos.add(
            AQIDTO.fromJson({
              'station': entry.key,
              'aqi': current['european_aqi'],
              'pm10': current['pm10'],
              'pm25': current['pm2_5'],
              'no2': current['nitrogen_dioxide'],
              'o3': current['ozone'],
              'co': current['carbon_monoxide'],
              'timestamp': current['time'],
            }),
          );
        }
      }
    }

    if (dtos.isNotEmpty) {
      await _cacheService.cacheAQI(dtos.map((d) => d.toJson()).toList());
      return dtos.map((d) => AirQuality.fromDTO(d)).toList();
    }

    final cached = _cacheService.getAQI();
    if (cached != null) {
      return cached.map((e) => AirQuality.fromDTO(AQIDTO.fromJson(e))).toList();
    }

    throw Exception('AQI verisi alınamadı');
  }
}
