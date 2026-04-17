class HavaDTO {
  final String city;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String description;
  final List<Map<String, dynamic>> forecast;

  HavaDTO({
    required this.city,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.forecast,
  });

  factory HavaDTO.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? parseDouble(value).toInt();
    }

    return HavaDTO(
      city: (json['city'] ?? '').toString(),
      temperature: parseDouble(json['temperature']),
      humidity: parseInt(json['humidity']),
      windSpeed: parseDouble(json['windSpeed']),
      description: (json['description'] ?? '').toString(),
      forecast: (json['forecast'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'description': description,
      'forecast': forecast,
    };
  }
}

class Weather {
  final String city;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String description;
  final List<DailyForecast> forecast;

  Weather({
    required this.city,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.forecast,
  });

  factory Weather.fromDTO(HavaDTO dto) {
    return Weather(
      city: dto.city,
      temperature: dto.temperature,
      humidity: dto.humidity,
      windSpeed: dto.windSpeed,
      description: dto.description,
      forecast: dto.forecast
          .map((f) => DailyForecast(
                date: f['date'] ?? '',
                maxTemp: (f['maxTemp'] ?? 0).toDouble(),
                minTemp: (f['minTemp'] ?? 0).toDouble(),
                description: f['description'] ?? '',
              ))
          .toList(),
    );
  }
}

class DailyForecast {
  final String date;
  final double maxTemp;
  final double minTemp;
  final String description;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.description,
  });
}
