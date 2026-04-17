const axios = require('axios');
const { AQIDTO } = require('../dto/dtos');
const { cache, keys, TTL } = require('../cache/cacheManager');

class AQIRepository {
  async fetchFromIBB() {
    try {
      const response = await axios.get('https://api.ibb.gov.tr/environment/index.aspx', {
        timeout: 10000
      });

      if (response.data && Array.isArray(response.data)) {
        return response.data.map(item => new AQIDTO({
          station: item.istasyon || item.name || '',
          aqi: item.aqi || item.index || 0,
          pm25: item.pm25 || 0,
          pm10: item.pm10 || 0,
          o3: item.o3 || 0,
          no2: item.no2 || 0,
          co: item.co || 0,
          timestamp: new Date().toISOString()
        }));
      }

      return [];
    } catch (error) {
      console.error('IBB API Error:', error.message);
      return this.getMockAQI();
    }
  }

  getMockAQI() {
    const stations = [
      { station: 'Kadıköy', aqi: 78, pm25: 32, pm10: 45, o3: 55, no2: 28, co: 0.8 },
      { station: 'Beşiktaş', aqi: 85, pm25: 38, pm10: 52, o3: 62, no2: 35, co: 0.9 },
      { station: 'Fatih', aqi: 92, pm25: 45, pm10: 58, o3: 48, no2: 42, co: 1.1 },
      { station: 'Üsküdar', aqi: 65, pm25: 25, pm10: 38, o3: 52, no2: 22, co: 0.6 },
      { station: 'Bakırköy', aqi: 71, pm25: 30, pm10: 42, o3: 58, no2: 26, co: 0.7 }
    ];

    return stations.map(s => new AQIDTO({ ...s, timestamp: new Date().toISOString() }));
  }

  getCached() {
    return cache.get(keys.AQI);
  }

  setCached(data) {
    cache.set(keys.AQI, data, TTL.AQI);
  }
}

module.exports = new AQIRepository();
