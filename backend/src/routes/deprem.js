const express = require('express');
const router = express.Router();
const earthquakeService = require('../services/earthquakeService');

router.get('/', async (req, res) => {
  try {
    const { minMagnitude, maxMagnitude, region, limit } = req.query;
    const filters = {};

    if (minMagnitude) filters.minMagnitude = parseFloat(minMagnitude);
    if (maxMagnitude) filters.maxMagnitude = parseFloat(maxMagnitude);
    if (region) filters.region = region;

    const result = await earthquakeService.getEarthquakes(filters);

    let earthquakes = result.earthquakes;
    if (limit) {
      earthquakes = earthquakes.slice(0, parseInt(limit));
    }

    res.json({
      success: true,
      data: {
        earthquakes,
        count: earthquakes.length,
        lastUpdated: result.lastUpdated,
        source: result.source
      }
    });
  } catch (error) {
    console.error('Earthquake route error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch earthquake data'
    });
  }
});

router.post('/refresh', async (req, res) => {
  try {
    const result = await earthquakeService.refresh();
    res.json({
      success: true,
      data: {
        earthquakes: result.earthquakes,
        count: result.earthquakes.length,
        lastUpdated: result.lastUpdated
      }
    });
  } catch (error) {
    console.error('Earthquake refresh error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to refresh earthquake data'
    });
  }
});

module.exports = router;
