const NodeCache = require('node-cache');

const cache = new NodeCache();

const TTL = {
  EARTHQUAKE: 300,
  WEATHER: 1800,
  AQI: 900,
  PRAYER: 43200,
  CURRENCY: 3600
};

const keys = {
  EARTHQUAKES: 'earthquakes',
  WEATHER: 'weather',
  AQI: 'aqi',
  PRAYER: 'prayer',
  CURRENCY: 'currency'
};

module.exports = { cache, TTL, keys };
