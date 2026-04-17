const aqiRepository = require('../repositories/aqiRepository');
const { aqiMapper } = require('../mappers/mappers');

class AQIService {
  async getAirQuality(station = null) {
    let data = aqiRepository.getCached();

    if (!data || data.length === 0) {
      const rawData = await aqiRepository.fetchFromIBB();
      data = rawData.map(dto => aqiMapper.toDomain(dto));
      aqiRepository.setCached(data);
    }

    if (station) {
      const stationData = data.find(s =>
        s.station.toLowerCase().includes(station.toLowerCase())
      );
      return {
        stations: stationData ? [stationData] : data,
        selected: stationData || null,
        lastUpdated: new Date().toISOString(),
        source: 'IBB'
      };
    }

    return {
      stations: data,
      selected: data[0] || null,
      lastUpdated: new Date().toISOString(),
      source: 'IBB'
    };
  }

  async refresh() {
    const rawData = await aqiRepository.fetchFromIBB();
    const data = rawData.map(dto => aqiMapper.toDomain(dto));
    aqiRepository.setCached(data);
    return {
      stations: data,
      lastUpdated: new Date().toISOString()
    };
  }

  getAQILevel(aqi) {
    if (aqi <= 50) return { level: 'İyi', color: 'green', icon: '✓' };
    if (aqi <= 100) return { level: 'Orta', color: 'yellow', icon: '○' };
    if (aqi <= 150) return { level: 'Hassas', color: 'orange', icon: '⚠' };
    if (aqi <= 200) return { level: 'Sağlıksız', color: 'red', icon: '!' };
    if (aqi <= 300) return { level: 'Çok Sağlıksız', color: 'purple', icon: '✕' };
    return { level: 'Tehlikeli', color: 'maroon', icon: '☠' };
  }
}

module.exports = new AQIService();
