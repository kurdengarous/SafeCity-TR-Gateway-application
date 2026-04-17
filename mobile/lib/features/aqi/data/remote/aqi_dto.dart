class AQIDTO {
  final String station;
  final int aqi;
  final double pm25;
  final double pm10;
  final double o3;
  final double no2;
  final double co;
  final String healthMessage;
  final String timestamp;
  final Map<String, dynamic>? level;

  AQIDTO({
    required this.station,
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.o3,
    required this.no2,
    required this.co,
    required this.healthMessage,
    required this.timestamp,
    this.level,
  });

  factory AQIDTO.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    final pm25 = parseDouble(json['pm25'] ?? json['PM25'] ?? json['pm_25']);
    final pm10 = parseDouble(json['pm10'] ?? json['PM10'] ?? json['pm_10']);
    final no2 = parseDouble(json['no2'] ?? json['NO2']);
    final aqi = parseInt(json['aqi'] ?? json['AQI']) != 0
        ? parseInt(json['aqi'] ?? json['AQI'])
        : _estimateAqi(pm25, pm10, no2);

    return AQIDTO(
      station: (json['station'] ?? json['istasyon'] ?? json['name'] ?? json['konum'] ?? 'İstanbul').toString(),
      aqi: aqi,
      pm25: pm25,
      pm10: pm10,
      o3: parseDouble(json['o3'] ?? json['O3']),
      no2: no2,
      co: parseDouble(json['co'] ?? json['CO']),
      healthMessage: (json['healthMessage'] ?? _healthMessage(aqi)).toString(),
      timestamp: (json['timestamp'] ?? json['tarih'] ?? json['date'] ?? DateTime.now().toIso8601String()).toString(),
      level: json['level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'station': station,
      'aqi': aqi,
      'pm25': pm25,
      'pm10': pm10,
      'o3': o3,
      'no2': no2,
      'co': co,
      'healthMessage': healthMessage,
      'timestamp': timestamp,
      'level': level,
    };
  }

  static int _estimateAqi(double pm25, double pm10, double no2) {
    final candidates = <double>[
      pm25 * 2,
      pm10,
      no2 * 1.2,
    ];
    return candidates.reduce((a, b) => a > b ? a : b).round();
  }

  static String _healthMessage(int aqi) {
    if (aqi <= 50) return 'Hava kalitesi iyi.';
    if (aqi <= 100) return 'Hassas gruplar dikkat etmeli.';
    if (aqi <= 150) return 'Dış ortamda uzun süre kalmamaya çalışın.';
    if (aqi <= 200) return 'Açık hava aktivitelerini azaltın.';
    if (aqi <= 300) return 'Maske kullanımı ve kapalı alanda kalma önerilir.';
    return 'Sağlık açısından risk yüksek, dışarı çıkmayın.';
  }
}

class AirQuality {
  final String station;
  final int aqi;
  final double pm25;
  final double pm10;
  final double o3;
  final double no2;
  final double co;
  final String healthMessage;
  final String levelText;
  final String levelColor;

  AirQuality({
    required this.station,
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.o3,
    required this.no2,
    required this.co,
    required this.healthMessage,
    required this.levelText,
    required this.levelColor,
  });

  factory AirQuality.fromDTO(AQIDTO dto) {
    String levelText = 'Bilinmeyen';
    String levelColor = 'grey';

    if (dto.aqi <= 50) {
      levelText = 'İyi';
      levelColor = 'green';
    } else if (dto.aqi <= 100) {
      levelText = 'Orta';
      levelColor = 'yellow';
    } else if (dto.aqi <= 150) {
      levelText = 'Hassas';
      levelColor = 'orange';
    } else if (dto.aqi <= 200) {
      levelText = 'Sağlıksız';
      levelColor = 'red';
    } else if (dto.aqi <= 300) {
      levelText = 'Çok Sağlıksız';
      levelColor = 'purple';
    } else {
      levelText = 'Tehlikeli';
      levelColor = 'maroon';
    }

    return AirQuality(
      station: dto.station,
      aqi: dto.aqi,
      pm25: dto.pm25,
      pm10: dto.pm10,
      o3: dto.o3,
      no2: dto.no2,
      co: dto.co,
      healthMessage: dto.healthMessage,
      levelText: levelText,
      levelColor: levelColor,
    );
  }
}
