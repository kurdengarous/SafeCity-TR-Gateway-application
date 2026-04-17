class EarthquakeDTO {
  final String id;
  final String timestamp;
  final double latitude;
  final double longitude;
  final double depth;
  final double magnitude;
  final String location;
  final String type;

  EarthquakeDTO({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.depth,
    required this.magnitude,
    required this.location,
    required this.type,
  });

  factory EarthquakeDTO.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0;
    }

    final geojson = json['geojson'] as Map<String, dynamic>?;
    final coordinates = geojson?['coordinates'] as List<dynamic>?;
    final locationProperties = json['location_properties'] as Map<String, dynamic>?;
    final epicenter = locationProperties?['epiCenter'] as Map<String, dynamic>?;

    return EarthquakeDTO(
      id: (json['id'] ?? json['eventID'] ?? json['eventId'] ?? json['earthquake_id'] ?? '').toString(),
      timestamp: (json['timestamp'] ?? json['date'] ?? json['eventDate'] ?? json['date_time'] ?? '').toString(),
      latitude: parseDouble(json['latitude'] ?? json['lat'] ?? (coordinates != null && coordinates.length > 1 ? coordinates[1] : null)),
      longitude: parseDouble(json['longitude'] ?? json['lon'] ?? (coordinates != null && coordinates.isNotEmpty ? coordinates[0] : null)),
      depth: parseDouble(json['depth']),
      magnitude: parseDouble(
        json['magnitude'] ?? json['mag'] ?? json['ml'] ?? json['mw'],
      ),
      location: (json['location'] ?? json['title'] ?? json['place'] ?? epicenter?['name'] ?? '').toString(),
      type: (json['type'] ?? json['magnitudeType'] ?? json['provider'] ?? 'ML').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'latitude': latitude,
      'longitude': longitude,
      'depth': depth,
      'magnitude': magnitude,
      'location': location,
      'type': type,
    };
  }
}
