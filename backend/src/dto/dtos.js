class EarthquakeDTO {
  constructor(raw) {
    this.DepremId = raw.DepremId || raw.id || null;
    this.timestamp = raw.Tarih ? `${raw.Tarih} ${raw.Saat}` : raw.timestamp;
    this.latitude = parseFloat(raw.Enlem || raw.latitude);
    this.longitude = parseFloat(raw.Boylam || raw.longitude);
    this.depth = parseFloat(raw.Derinlik || raw.depth);
    this.magnitude = parseFloat(raw.Buyukluk || raw.magnitude || raw.ML || 0);
    this.location = raw.Yer || raw.location || '';
    this.type = raw.Tip || raw.type || 'ML';
  }
}

class WeatherDTO {
  constructor(raw) {
    this.city = raw.city || raw.il || '';
    this.temperature = parseFloat(raw.temperature || raw.temp || 0);
    this.humidity = parseFloat(raw.humidity || raw.nem || 0);
    this.windSpeed = parseFloat(raw.windSpeed || raw.ruzgar || 0);
    this.description = raw.description || raw.havaDurumu || '';
    this.forecast = raw.forecast || [];
  }
}

class AQIDTO {
  constructor(raw) {
    this.station = raw.station || raw.istasyon || '';
    this.aqi = parseInt(raw.aqi || raw.index || 0);
    this.pm25 = parseFloat(raw.pm25 || 0);
    this.pm10 = parseFloat(raw.pm10 || 0);
    this.o3 = parseFloat(raw.o3 || 0);
    this.no2 = parseFloat(raw.no2 || 0);
    this.co = parseFloat(raw.co || 0);
    this.timestamp = raw.timestamp || new Date().toISOString();
  }
}

class PrayerDTO {
  constructor(raw) {
    this.date = raw.date || raw.Tarih || '';
    this.fajr = raw.fajr || raw.Imsak || '';
    this.sunrise = raw.sunrise || raw.Gunes || '';
    this.dhuhr = raw.dhuhr || raw.Ogle || '';
    this.asr = raw.asr || raw.Ikindi || '';
    this.maghrib = raw.maghrib || raw.Aksham || '';
    this.isha = raw.isha || raw.Yatsi || '';
  }
}

class CurrencyDTO {
  constructor(raw) {
    this.code = raw.code || raw.Kod || '';
    this.name = raw.name || raw.Ad || '';
    this.buy = parseFloat(raw.buy || raw.Alis || 0);
    this.sell = parseFloat(raw.sell || raw.Satis || 0);
    this.change = parseFloat(raw.change || raw.Degisim || 0);
  }
}

module.exports = { EarthquakeDTO, WeatherDTO, AQIDTO, PrayerDTO, CurrencyDTO };
