const axios = require('axios');
const { EarthquakeDTO } = require('../dto/dtos');
const { earthquakeMapper } = require('../mappers/mappers');
const { cache, keys, TTL } = require('../cache/cacheManager');

class EarthquakeRepository {
  async fetchFromAFAD() {
    try {
      console.log('[AFAD] Fetching earthquake data...');

      const response = await axios.get('https://deprem.afad.gov.tr/feed', {
        timeout: 10000,
        headers: { 'Accept': 'application/json' }
      });

      if (response.data && Array.isArray(response.data)) {
        console.log('[AFAD] JSON response received');
        return response.data.map(item => new EarthquakeDTO({
          DepremId: item.DepremId || item.id,
          Tarih: item.Tarih || item.date,
          Saat: item.Saat || item.time,
          Enlem: item.Enlem || item.latitude,
          Boylam: item.Boylam || item.longitude,
          Derinlik: item.Derinlik || item.depth,
          Buyukluk: item.Buyukluk || item.magnitude,
          Yer: item.Yer || item.location,
          Tip: item.Tip || item.type || 'ML'
        }));
      }

      console.log('[AFAD] Using mock data');
      return this.getMockEarthquakes();
    } catch (error) {
      console.error('[AFAD] API Error:', error.message);
      return this.getMockEarthquakes();
    }
  }

  getMockEarthquakes() {
    return [
      new EarthquakeDTO({
        DepremId: '1',
        Tarih: '2026-04-17',
        Saat: '10:30:00',
        Enlem: 39.26,
        Boylam: 29.00,
        Derinlik: 7.0,
        Buyukluk: 2.1,
        Yer: 'Simav (Kütahya)',
        Tip: 'ML'
      }),
      new EarthquakeDTO({
        DepremId: '2',
        Tarih: '2026-04-17',
        Saat: '09:15:00',
        Enlem: 38.42,
        Boylam: 27.12,
        Derinlik: 5.0,
        Buyukluk: 1.5,
        Yer: 'Bornova (İzmir)',
        Tip: 'ML'
      }),
      new EarthquakeDTO({
        DepremId: '3',
        Tarih: '2026-04-17',
        Saat: '08:45:00',
        Enlem: 41.01,
        Boylam: 28.97,
        Derinlik: 8.5,
        Buyukluk: 3.2,
        Yer: 'Silivri (İstanbul)',
        Tip: 'ML'
      }),
      new EarthquakeDTO({
        DepremId: '4',
        Tarih: '2026-04-17',
        Saat: '07:20:00',
        Enlem: 40.18,
        Boylam: 32.68,
        Derinlik: 6.0,
        Buyukluk: 1.8,
        Yer: 'Çankaya (Ankara)',
        Tip: 'ML'
      }),
      new EarthquakeDTO({
        DepremId: '5',
        Tarih: '2026-04-16',
        Saat: '23:50:00',
        Enlem: 37.00,
        Boylam: 27.00,
        Derinlik: 10.0,
        Buyukluk: 4.5,
        Yer: 'Ege Denizi',
        Tip: 'ML'
      })
    ];
  }

  getCached() {
    return cache.get(keys.EARTHQUAKES);
  }

  setCached(data) {
    cache.set(keys.EARTHQUAKES, data, TTL.EARTHQUAKE);
  }
}

module.exports = new EarthquakeRepository();
