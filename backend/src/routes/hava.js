const express = require('express');
const router = express.Router();
const weatherService = require('../services/weatherService');

router.get('/', async (req, res) => {
  try {
    const { city } = req.query;
    const cityName = city || 'Istanbul';

    const result = await weatherService.getWeather(cityName);

    res.json({
      success: true,
      data: {
        weather: result,
        cities: weatherService.getSupportedCities()
      }
    });
  } catch (error) {
    console.error('Weather route error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch weather data'
    });
  }
});

router.get('/cities', (req, res) => {
  res.json({
    success: true,
    data: weatherService.getSupportedCities()
  });
});

router.post('/refresh', async (req, res) => {
  try {
    const { city } = req.body;
    const cityName = city || 'Istanbul';

    const result = await weatherService.refresh(cityName);

    res.json({
      success: true,
      data: {
        weather: result
      }
    });
  } catch (error) {
    console.error('Weather refresh error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to refresh weather data'
    });
  }
});

module.exports = router;
