class SettingsDomain {
  final String themeMode;
  final double earthquakeThreshold;
  final int aqiThreshold;
  final int refreshIntervalMinutes;
  final List<String> favoriteCities;
  final List<String> favoriteCurrencies;

  SettingsDomain({
    required this.themeMode,
    required this.earthquakeThreshold,
    required this.aqiThreshold,
    required this.refreshIntervalMinutes,
    required this.favoriteCities,
    required this.favoriteCurrencies,
  });
}
