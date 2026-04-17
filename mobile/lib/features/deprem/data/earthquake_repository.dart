import 'package:turkiye_cevre_guvenligi/features/deprem/data/remote/earthquake_dto.dart';
import 'package:turkiye_cevre_guvenligi/features/deprem/domain/earthquake.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/api_service.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/cache_service.dart';

class EarthquakeRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  EarthquakeRepository(this._apiService, this._cacheService);

  Future<List<Earthquake>> getEarthquakes({
    double? minMagnitude,
    double? maxMagnitude,
    String? region,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _cacheService.getEarthquakes();
      if (cached != null) {
        return cached
            .map((e) => Earthquake.fromDTO(EarthquakeDTO.fromJson(e)))
            .toList();
      }
    }

    final response = await _apiService.get<List<dynamic>>(
      'https://api.orhanaydogdu.com.tr/deprem/kandilli/live',
      parser: (data) {
        if (data is List) return data;
        if (data is Map<String, dynamic>) {
          final list = data['result'] ?? data['items'] ?? data['data'] ?? data['earthquakes'];
          if (list is List) return list;
        }
        return <dynamic>[];
      },
    );

    if (response.isSuccess && response.data != null) {
      var dtos = response.data!
          .map((e) => EarthquakeDTO.fromJson(e))
          .toList();

      if (minMagnitude != null) {
        dtos = dtos.where((e) => e.magnitude >= minMagnitude).toList();
      }

      if (maxMagnitude != null) {
        dtos = dtos.where((e) => e.magnitude <= maxMagnitude).toList();
      }

      if (region != null && region.trim().isNotEmpty) {
        final query = region.toLowerCase().trim();
        dtos = dtos.where((e) => e.location.toLowerCase().contains(query)).toList();
      }

      await _cacheService.cacheEarthquakes(
        dtos.map((d) => d.toJson()).toList(),
      );

      return dtos.map((d) => Earthquake.fromDTO(d)).toList();
    }

    final cached = _cacheService.getEarthquakes();
    if (cached != null) {
      return cached
          .map((e) => Earthquake.fromDTO(EarthquakeDTO.fromJson(e)))
          .toList();
    }

    return [];
  }

  DateTime? getLastUpdate() {
    return _cacheService.getEarthquakeTimestamp();
  }
}
