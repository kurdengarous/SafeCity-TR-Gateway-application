class PrayerDTO {
  final String city;
  final String date;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final List<Map<String, dynamic>> weekly;
  final String? nextPrayer;
  final String? nextPrayerTime;
  final Map<String, dynamic>? timeRemaining;

  PrayerDTO({
    required this.city,
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.weekly = const [],
    this.nextPrayer,
    this.nextPrayerTime,
    this.timeRemaining,
  });

  factory PrayerDTO.fromJson(Map<String, dynamic> json) {
    final nextPrayer = json['nextPrayer'];
    return PrayerDTO(
      city: json['city'] ?? '',
      date: json['date'] ?? '',
      fajr: json['fajr'] ?? '',
      sunrise: json['sunrise'] ?? '',
      dhuhr: json['dhuhr'] ?? '',
      asr: json['asr'] ?? '',
      maghrib: json['maghrib'] ?? '',
      isha: json['isha'] ?? '',
      weekly: (json['weekly'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
      nextPrayer: nextPrayer is Map<String, dynamic> ? nextPrayer['name'] : json['nextPrayerName'],
      nextPrayerTime: nextPrayer is Map<String, dynamic> ? nextPrayer['time'] : json['nextPrayerTime'],
      timeRemaining: nextPrayer is Map<String, dynamic>
          ? (nextPrayer['remaining'] as Map<String, dynamic>?)
          : (json['timeRemaining'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'date': date,
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'weekly': weekly,
      'nextPrayerName': nextPrayer,
      'nextPrayerTime': nextPrayerTime,
      'timeRemaining': timeRemaining,
    };
  }
}

class PrayerTime {
  final String date;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String nextPrayerName;
  final String nextPrayerTime;
  final int remainingHours;
  final int remainingMinutes;

  PrayerTime({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.nextPrayerName,
    required this.nextPrayerTime,
    required this.remainingHours,
    required this.remainingMinutes,
  });

  factory PrayerTime.fromDTO(PrayerDTO dto) {
    int hours = 0;
    int minutes = 0;

    if (dto.timeRemaining != null) {
      hours = (dto.timeRemaining!['hours'] ?? 0).toInt();
      minutes = (dto.timeRemaining!['minutes'] ?? 0).toInt();
    }

    return PrayerTime(
      date: dto.date,
      fajr: dto.fajr,
      sunrise: dto.sunrise,
      dhuhr: dto.dhuhr,
      asr: dto.asr,
      maghrib: dto.maghrib,
      isha: dto.isha,
      nextPrayerName: dto.nextPrayer ?? 'İmsak',
      nextPrayerTime: dto.nextPrayerTime ?? dto.fajr,
      remainingHours: hours,
      remainingMinutes: minutes,
    );
  }
}
