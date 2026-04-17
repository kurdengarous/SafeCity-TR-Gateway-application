import 'package:turkiye_cevre_guvenligi/features/hava/data/remote/weather_dto.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/api_service.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/cache_service.dart';

class WeatherRepository {
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
    'Kayseri': (latitude: 38.7225, longitude: 35.4875),
    'Eskisehir': (latitude: 39.7667, longitude: 30.5256),
    'Gebze': (latitude: 40.8028, longitude: 29.4307),
    'Samsun': (latitude: 41.2867, longitude: 36.3300),
    'Trabzon': (latitude: 41.0015, longitude: 39.7178),
    'Denizli': (latitude: 37.7765, longitude: 29.0864),
    'Malatya': (latitude: 38.3552, longitude: 38.3095),
    'Erzurum': (latitude: 39.9043, longitude: 41.2679),
    'Van': (latitude: 38.4891, longitude: 43.4089),
    'Batman': (latitude: 37.8812, longitude: 41.1351),
  };

  WeatherRepository(this._apiService, this._cacheService);

  Future<Weather> getWeather(String city, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cacheService.getWeather();
      if (cached != null && cached['city'] == city) {
        return Weather.fromDTO(HavaDTO.fromJson(cached));
      }
    }

    final coordinates = _cityCoordinates[city];
    if (coordinates == null) {
      throw Exception('Desteklenmeyen şehir: $city');
    }

    final response = await _apiService.get<Map<String, dynamic>>(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
        'current': 'temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
        'timezone': 'Europe/Istanbul',
        'forecast_days': 7,
      },
      parser: (data) => data as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final normalized = _normalizeOpenMeteoWeather(city, response.data!);
      await _cacheService.cacheWeather(normalized);
      return Weather.fromDTO(HavaDTO.fromJson(normalized));
    }

    final cached = _cacheService.getWeather();
    if (cached != null) {
      return Weather.fromDTO(HavaDTO.fromJson(cached));
    }

    throw Exception('Hava durumu verisi alınamadı');
  }

  List<String> getSupportedCities() {
    return [
      'Istanbul', 'Ankara', 'Izmir', 'Bursa', 'Antalya', 'Konya', 'Adana',
      'Gaziantep', 'Mersin', 'Diyarbakir', 'Kayseri', 'Eskisehir', 'Gebze',
      'Samsun', 'Trabzon', 'Denizli', 'Malatya', 'Erzurum', 'Van', 'Batman'
    ];
  }

  Map<String, dynamic> _normalizeOpenMeteoWeather(
    String city,
    Map<String, dynamic> payload,
  ) {
    final current = payload['current'] as Map<String, dynamic>? ?? const {};
    final daily = payload['daily'] as Map<String, dynamic>? ?? const {};
    final times = (daily['time'] as List<dynamic>? ?? const []).cast<dynamic>();
    final maxTemps = (daily['temperature_2m_max'] as List<dynamic>? ?? const []).cast<dynamic>();
    final minTemps = (daily['temperature_2m_min'] as List<dynamic>? ?? const []).cast<dynamic>();
    final codes = (daily['weather_code'] as List<dynamic>? ?? const []).cast<dynamic>();

    final forecast = <Map<String, dynamic>>[];
    for (var i = 0; i < times.length; i++) {
      forecast.add({
        'date': times[i].toString(),
        'maxTemp': (maxTemps.length > i ? maxTemps[i] : 0) ?? 0,
        'minTemp': (minTemps.length > i ? minTemps[i] : 0) ?? 0,
        'description': _weatherCodeToDescription((codes.length > i ? codes[i] : -1) as dynamic),
      });
    }

    return {
      'city': city,
      'temperature': current['temperature_2m'] ?? 0,
      'humidity': current['relative_humidity_2m'] ?? 0,
      'windSpeed': current['wind_speed_10m'] ?? 0,
      'description': _weatherCodeToDescription(current['weather_code']),
      'forecast': forecast,
    };
  }

  String _weatherCodeToDescription(dynamic rawCode) {
    final code = rawCode is num ? rawCode.toInt() : int.tryParse(rawCode.toString()) ?? -1;
    switch (code) {
      case 0:
        return 'Açık';
      case 1:
      case 2:
      case 3:
        return 'Parçalı Bulutlu';
      case 45:
      case 48:
        return 'Sisli';
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return 'Çisenti';
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return 'Yağmurlu';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'Kar';
      case 80:
      case 81:
      case 82:
        return 'Sağanak';
      case 95:
      case 96:
      case 99:
        return 'Fırtınalı';
      default:
        return 'Bilinmiyor';
    }
  }
}
