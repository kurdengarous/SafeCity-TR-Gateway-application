const express = require('express');
const router = express.Router();
const { cache } = require('../cache/cacheManager');

router.get('/status', (req, res) => {
  const keys = cache.keys();
  const stats = {};

  keys.forEach(key => {
    const value = cache.get(key);
    const ttl = cache.getTtl(key);
    stats[key] = {
      exists: value !== undefined,
      ttl: ttl ? Math.max(0, ttl - Math.floor(Date.now() / 1000)) : null
    };
  });

  res.json({
    success: true,
    data: {
      cacheKeys: keys,
      cacheStats: stats,
      memoryUsage: process.memoryUsage(),
      uptime: process.uptime()
    }
  });
});

router.get('/info', (req, res) => {
  res.json({
    success: true,
    data: {
      name: 'Türkiye Çevre Güvenliği Aggregator',
      version: '1.0.0',
      description: 'Turkish Public Safety Data Aggregator API',
      endpoints: {
        earthquakes: '/api/deprem',
        weather: '/api/hava',
        airQuality: '/api/aqi',
        prayerTimes: '/api/namaz',
        currency: '/api/doviz',
        system: '/api/sistem'
      },
      sources: {
        earthquakes: 'AFAD (Afet ve Acil Durum Yönetimi Başkanlığı)',
        weather: 'MGM (Meteoroloji Genel Müdürlüğü)',
        airQuality: 'İBB (İstanbul Büyükşehir Belediyesi)',
        prayerTimes: 'Vakit API / Aladhan',
        currency: 'TCMB (Türkiye Cumhuriyet Merkez Bankası)'
      }
    }
  });
});

router.delete('/cache', (req, res) => {
  cache.flushAll();
  res.json({
    success: true,
    message: 'Cache cleared successfully'
  });
});

module.exports = router;
