const express = require('express');
const router = express.Router();
const aqiService = require('../services/aqiService');

router.get('/', async (req, res) => {
  try {
    const { station } = req.query;

    const result = await aqiService.getAirQuality(station);

    const stationsWithLevel = result.stations.map(s => ({
      ...s,
      level: aqiService.getAQILevel(s.aqi)
    }));

    res.json({
      success: true,
      data: {
        stations: stationsWithLevel,
        selected: result.selected ? {
          ...result.selected,
          level: aqiService.getAQILevel(result.selected.aqi)
        } : null,
        lastUpdated: result.lastUpdated,
        source: result.source
      }
    });
  } catch (error) {
    console.error('AQI route error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch AQI data'
    });
  }
});

router.post('/refresh', async (req, res) => {
  try {
    const result = await aqiService.refresh();

    const stationsWithLevel = result.stations.map(s => ({
      ...s,
      level: aqiService.getAQILevel(s.aqi)
    }));

    res.json({
      success: true,
      data: {
        stations: stationsWithLevel,
        lastUpdated: result.lastUpdated
      }
    });
  } catch (error) {
    console.error('AQI refresh error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to refresh AQI data'
    });
  }
});

module.exports = router;
