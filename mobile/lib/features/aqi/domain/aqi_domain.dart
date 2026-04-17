class AirQualityDomain {
  final String station;
  final int aqi;
  final double pm25;
  final double pm10;
  final double o3;
  final double no2;
  final double co;
  final String healthMessage;
  final String levelText;
  final DateTime timestamp;

  AirQualityDomain({
    required this.station,
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.o3,
    required this.no2,
    required this.co,
    required this.healthMessage,
    required this.levelText,
    required this.timestamp,
  });
}
