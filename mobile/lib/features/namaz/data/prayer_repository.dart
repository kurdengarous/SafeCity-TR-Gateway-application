import 'package:turkiye_cevre_guvenligi/features/namaz/data/remote/prayer_dto.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/api_service.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/cache_service.dart';

class PrayerRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  PrayerRepository(this._apiService, this._cacheService);

  Future<PrayerTime> getPrayerTimes(String city, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cacheService.getPrayer();
      if (cached != null && cached['city'] == city) {
        return PrayerTime.fromDTO(PrayerDTO.fromJson(cached));
      }
    }

    final response = await _apiService.get<Map<String, dynamic>>(
      'https://api.aladhan.com/v1/timingsByCity',
      queryParameters: {
        'city': city,
        'country': 'Turkey',
        'method': 13,
      },
      parser: (data) => data as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as Map<String, dynamic>?;
      final timings = data?['timings'] as Map<String, dynamic>?;
      final date = data?['date'] as Map<String, dynamic>?;

      if (timings != null) {
        final dto = _createPrayerDto(city, timings, date);
        await _cacheService.cachePrayer(dto.toJson());
        return PrayerTime.fromDTO(dto);
      }
    }

    final cached = _cacheService.getPrayer();
    if (cached != null) {
      return PrayerTime.fromDTO(PrayerDTO.fromJson(cached));
    }

    throw Exception('Namaz vakti alınamadı');
  }

  List<String> getSupportedCities() {
    return [
      'Istanbul', 'Ankara', 'Izmir', 'Bursa', 'Antalya', 'Konya', 'Adana',
      'Gaziantep', 'Mersin', 'Diyarbakir'
    ];
  }

  PrayerDTO _createPrayerDto(
    String city,
    Map<String, dynamic> timings,
    Map<String, dynamic>? date,
  ) {
    final prayerOrder = <MapEntry<String, String>>[
      MapEntry('İmsak', _cleanTime(timings['Fajr'])),
      MapEntry('Güneş', _cleanTime(timings['Sunrise'])),
      MapEntry('Öğle', _cleanTime(timings['Dhuhr'])),
      MapEntry('İkindi', _cleanTime(timings['Asr'])),
      MapEntry('Akşam', _cleanTime(timings['Maghrib'])),
      MapEntry('Yatsı', _cleanTime(timings['Isha'])),
    ];

    final now = DateTime.now();
    MapEntry<String, String>? nextPrayer;
    Duration remaining = Duration.zero;

    for (final prayer in prayerOrder) {
      final prayerTime = _timeForToday(prayer.value, now);
      if (prayerTime.isAfter(now)) {
        nextPrayer = prayer;
        remaining = prayerTime.difference(now);
        break;
      }
    }

    nextPrayer ??= prayerOrder.first;
    if (remaining == Duration.zero) {
      final tomorrowPrayer = _timeForToday(nextPrayer.value, now.add(const Duration(days: 1)));
      remaining = tomorrowPrayer.difference(now);
    }

    return PrayerDTO(
      city: city,
      date: (date?['readable'] ?? DateTime.now().toIso8601String().split('T').first).toString(),
      fajr: _cleanTime(timings['Fajr']),
      sunrise: _cleanTime(timings['Sunrise']),
      dhuhr: _cleanTime(timings['Dhuhr']),
      asr: _cleanTime(timings['Asr']),
      maghrib: _cleanTime(timings['Maghrib']),
      isha: _cleanTime(timings['Isha']),
      weekly: [
        {
          'date': (date?['readable'] ?? '').toString(),
          'fajr': _cleanTime(timings['Fajr']),
          'sunrise': _cleanTime(timings['Sunrise']),
          'dhuhr': _cleanTime(timings['Dhuhr']),
          'asr': _cleanTime(timings['Asr']),
          'maghrib': _cleanTime(timings['Maghrib']),
          'isha': _cleanTime(timings['Isha']),
        },
      ],
      nextPrayer: nextPrayer.key,
      nextPrayerTime: nextPrayer.value,
      timeRemaining: {
        'hours': remaining.inHours,
        'minutes': remaining.inMinutes.remainder(60),
      },
    );
  }

  String _cleanTime(dynamic raw) {
    return raw.toString().split(' ').first;
  }

  DateTime _timeForToday(String time, DateTime base) {
    final parts = time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(base.year, base.month, base.day, hour, minute);
  }
}
