const axios = require('axios');
const { WeatherDTO } = require('../dto/dtos');
const { cache, keys, TTL } = require('../cache/cacheManager');

class WeatherRepository {
  async fetchFromMGM(city = 'Istanbul') {
    try {
      console.log(`[MGM] Fetching weather for ${city}`);
      const response = await axios.get(
        `https://servis.mgm.gov.tr/web/tahmin/gunluk5?il=${encodeURIComponent(city)}`,
        { timeout: 10000 }
      );

      if (response.data && response.data.days && response.data.days.length > 0) {
        const days = response.data.days;
        const current = days[0] || {};

        console.log(`[MGM] Data received for ${city}`);
        return new WeatherDTO({
          city,
          temperature: current.maxTemp || current.minTemp || 0,
          humidity: current.humidity || current.nem || 50,
          windSpeed: current.windSpeed || current.ruzgar || 0,
          description: current.description || current.havaDurumu || '',
          forecast: days.slice(0, 5).map(day => ({
            date: day.date || day.tarih,
            maxTemp: day.maxTemp || day.enYuksek || 0,
            minTemp: day.minTemp || day.enDusuk || 0,
            description: day.description || day.havaDurumu || ''
          }))
        });
      }

      console.log(`[MGM] No data for ${city}, using mock`);
      return this.getMockWeather(city);
    } catch (error) {
      console.error('[MGM] API Error:', error.message);
      return this.getMockWeather(city);
    }
  }

  getMockWeather(city) {
    const mockData = {
      'Istanbul': { temp: 18, humidity: 65, wind: 12, desc: 'Parçalı Bulutlu' },
      'Ankara': { temp: 15, humidity: 50, wind: 8, desc: 'Güneşli' },
      'Izmir': { temp: 22, humidity: 60, wind: 15, desc: 'Açık' },
      'Antalya': { temp: 25, humidity: 55, wind: 10, desc: 'Sıcak' },
      'Bursa': { temp: 17, humidity: 68, wind: 11, desc: 'Bulutlu' }
    };

    const data = mockData[city] || { temp: 20, humidity: 60, wind: 10, desc: 'Bilgi yok' };

    return new WeatherDTO({
      city,
      temperature: data.temp,
      humidity: data.humidity,
      windSpeed: data.wind,
      description: data.desc,
      forecast: [
        { date: new Date().toISOString(), maxTemp: data.temp + 3, minTemp: data.temp - 3, description: data.desc },
        { date: new Date(Date.now() + 86400000).toISOString(), maxTemp: data.temp + 4, minTemp: data.temp - 2, description: data.desc },
        { date: new Date(Date.now() + 172800000).toISOString(), maxTemp: data.temp + 5, minTemp: data.temp - 4, description: 'Güneşli' },
        { date: new Date(Date.now() + 259200000).toISOString(), maxTemp: data.temp + 2, minTemp: data.temp - 5, description: 'Yağmurlu' },
        { date: new Date(Date.now() + 345600000).toISOString(), maxTemp: data.temp + 6, minTemp: data.temp - 3, description: 'Parçalı' },
      ]
    });
  }

  getCached() {
    return cache.get(keys.WEATHER);
  }

  setCached(data) {
    cache.set(keys.WEATHER, data, TTL.WEATHER);
  }
}

module.exports = new WeatherRepository();
