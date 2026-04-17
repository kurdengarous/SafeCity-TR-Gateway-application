const express = require('express');
const router = express.Router();
const prayerService = require('../services/prayerService');

router.get('/', async (req, res) => {
  try {
    const { city } = req.query;
    const cityName = city || 'Istanbul';

    const result = await prayerService.getPrayerTimes(cityName);

    res.json({
      success: true,
      data: {
        prayer: result,
        cities: ['Istanbul', 'Ankara', 'Izmir', 'Bursa', 'Antalya', 'Konya', 'Adana', 'Gaziantep', 'Mersin', 'Diyarbakir']
      }
    });
  } catch (error) {
    console.error('Prayer route error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch prayer time data'
    });
  }
});

router.post('/refresh', async (req, res) => {
  try {
    const { city } = req.body;
    const cityName = city || 'Istanbul';

    const result = await prayerService.refresh(cityName);

    res.json({
      success: true,
      data: {
        prayer: result
      }
    });
  } catch (error) {
    console.error('Prayer refresh error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to refresh prayer time data'
    });
  }
});

module.exports = router;
