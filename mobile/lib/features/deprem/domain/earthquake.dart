import 'package:turkiye_cevre_guvenligi/features/deprem/data/remote/earthquake_dto.dart';

class Earthquake {
  final String id;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double depth;
  final double magnitude;
  final String location;
  final String type;

  Earthquake({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.depth,
    required this.magnitude,
    required this.location,
    required this.type,
  });

  factory Earthquake.fromDTO(EarthquakeDTO dto) {
    DateTime parseTimestamp(String ts) {
      try {
        return DateTime.parse(ts);
      } catch (_) {
        try {
          final parts = ts.split(' ');
          if (parts.length >= 2) {
            final dateParts = parts[0].split('-');
            final timeParts = parts[1].split(':');
            return DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
              timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
            );
          }
        } catch (_) {}
        return DateTime.now();
      }
    }

    return Earthquake(
      id: dto.id,
      timestamp: parseTimestamp(dto.timestamp),
      latitude: dto.latitude,
      longitude: dto.longitude,
      depth: dto.depth,
      magnitude: dto.magnitude,
      location: dto.location,
      type: dto.type,
    );
  }
}
