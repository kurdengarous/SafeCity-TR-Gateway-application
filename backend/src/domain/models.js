class Earthquake {
  constructor({ id, timestamp, latitude, longitude, depth, magnitude, location, type }) {
    this.id = id;
    this.timestamp = timestamp;
    this.latitude = latitude;
    this.longitude = longitude;
    this.depth = depth;
    this.magnitude = magnitude;
    this.location = location;
    this.type = type;
  }
}

class Weather {
  constructor({ city, temperature, humidity, windSpeed, description, forecast }) {
    this.city = city;
    this.temperature = temperature;
    this.humidity = humidity;
    this.windSpeed = windSpeed;
    this.description = description;
    this.forecast = forecast;
  }
}

class AirQuality {
  constructor({ station, aqi, pm25, pm10, o3, no2, co, healthMessage, timestamp }) {
    this.station = station;
    this.aqi = aqi;
    this.pm25 = pm25;
    this.pm10 = pm10;
    this.o3 = o3;
    this.no2 = no2;
    this.co = co;
    this.healthMessage = healthMessage;
    this.timestamp = timestamp;
  }
}

class PrayerTime {
  constructor({ date, fajr, sunrise, dhuhr, asr, maghrib, isha }) {
    this.date = date;
    this.fajr = fajr;
    this.sunrise = sunrise;
    this.dhuhr = dhuhr;
    this.asr = asr;
    this.maghrib = maghrib;
    this.isha = isha;
  }
}

class CurrencyRate {
  constructor({ code, name, buy, sell, change }) {
    this.code = code;
    this.name = name;
    this.buy = buy;
    this.sell = sell;
    this.change = change;
  }
}

module.exports = { Earthquake, Weather, AirQuality, PrayerTime, CurrencyRate };
