const express = require('express');
const router = express.Router();
const currencyService = require('../services/currencyService');

router.get('/', async (req, res) => {
  try {
    const result = await currencyService.getCurrencies();

    res.json({
      success: true,
      data: {
        currencies: result.currencies,
        gold: result.gold,
        lastUpdated: result.lastUpdated,
        source: result.source
      }
    });
  } catch (error) {
    console.error('Currency route error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch currency data'
    });
  }
});

router.post('/refresh', async (req, res) => {
  try {
    const result = await currencyService.refresh();

    res.json({
      success: true,
      data: {
        currencies: result.currencies,
        gold: result.gold,
        lastUpdated: result.lastUpdated
      }
    });
  } catch (error) {
    console.error('Currency refresh error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to refresh currency data'
    });
  }
});

module.exports = router;
