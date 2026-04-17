const axios = require('axios');
const { PrayerDTO } = require('../dto/dtos');
const { cache, keys, TTL } = require('../cache/cacheManager');

class PrayerRepository {
  async fetchFromVakit(city = 'Istanbul') {
    try {
      const response = await axios.get(
        `https://vakit.vercel.app/api/times?city=${encodeURIComponent(city)}`,
        { timeout: 10000 }
      );

      if (response.data) {
        return new PrayerDTO({
          date: response.data.date || new Date().toISOString().split('T')[0],
          fajr: response.data.imsak || response.data.fajr || '',
          sunrise: response.data.gunes || response.data.sunrise || '',
          dhuhr: response.data.ogle || response.data.dhuhr || '',
          asr: response.data.ikindi || response.data.asr || '',
          maghrib: response.data.aksam || response.data.maghrib || '',
          isha: response.data.yatsi || response.data.isha || ''
        });
      }

      return this.getMockPrayer();
    } catch (error) {
      console.error('Vakit API Error:', error.message);
      return this.getMockPrayer();
    }
  }

  getMockPrayer() {
    const now = new Date();
    const dateStr = now.toISOString().split('T')[0];

    return new PrayerDTO({
      date: dateStr,
      fajr: '05:23',
      sunrise: '06:52',
      dhuhr: '13:15',
      asr: '16:45',
      maghrib: '19:32',
      isha: '20:58'
    });
  }

  getCached() {
    return cache.get(keys.PRAYER);
  }

  setCached(data) {
    cache.set(keys.PRAYER, data, TTL.PRAYER);
  }
}

module.exports = new PrayerRepository();
