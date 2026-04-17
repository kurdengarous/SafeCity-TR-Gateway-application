const express = require('express');
const cors = require('cors');
const cron = require('node-cron');

const earthquakeRoutes = require('./routes/deprem');
const weatherRoutes = require('./routes/hava');
const aqiRoutes = require('./routes/aqi');
const prayerRoutes = require('./routes/namaz');
const currencyRoutes = require('./routes/doviz');
const systemRoutes = require('./routes/sistem');

const { startEarthquakeCron, startWeatherCron, startAQICron, startCurrencyCron, startPrayerCron } = require('./cron/jobs');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api/deprem', earthquakeRoutes);
app.use('/api/hava', weatherRoutes);
app.use('/api/aqi', aqiRoutes);
app.use('/api/namaz', prayerRoutes);
app.use('/api/doviz', currencyRoutes);
app.use('/api/sistem', systemRoutes);

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

startEarthquakeCron();
startWeatherCron();
startAQICron();
startCurrencyCron();
startPrayerCron();

app.listen(PORT, () => {
  console.log(`Turkish Public Safety API Gateway running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});

module.exports = app;
