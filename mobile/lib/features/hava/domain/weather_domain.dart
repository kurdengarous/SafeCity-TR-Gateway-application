class WeatherDomain {
  final String city;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String description;
  final DateTime lastUpdated;

  WeatherDomain({
    required this.city,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.lastUpdated,
  });
}
