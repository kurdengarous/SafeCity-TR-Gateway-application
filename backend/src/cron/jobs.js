const cron = require('node-cron');
const earthquakeRepository = require('../repositories/earthquakeRepository');
const weatherRepository = require('../repositories/weatherRepository');
const aqiRepository = require('../repositories/aqiRepository');
const prayerRepository = require('../repositories/prayerRepository');
const currencyRepository = require('../repositories/currencyRepository');
const { earthquakeMapper, weatherMapper, aqiMapper, prayerMapper, currencyMapper } = require('../mappers/mappers');

const CITIES = ['Istanbul', 'Ankara', 'Izmir'];

function startEarthquakeCron() {
  cron.schedule('*/2 * * * *', async () => {
    console.log('[CRON] Fetching earthquake data from AFAD...');
    try {
      const rawData = await earthquakeRepository.fetchFromAFAD();
      const earthquakes = earthquakeMapper.toDomainList(rawData);
      earthquakeRepository.setCached(earthquakes);
      console.log(`[CRON] Earthquake data updated: ${earthquakes.length} records`);
    } catch (error) {
      console.error('[CRON] Earthquake fetch error:', error.message);
    }
  });

  console.log('[CRON] Earthquake job scheduled: every 2 minutes');
}

function startWeatherCron() {
  cron.schedule('*/15 * * * *', async () => {
    console.log('[CRON] Fetching weather data from MGM...');
    try {
      for (const city of CITIES) {
        const rawData = await weatherRepository.fetchFromMGM(city);
        const weather = weatherMapper.toDomain(rawData);
        weatherRepository.setCached(weather);
        console.log(`[CRON] Weather updated for ${city}`);
      }
    } catch (error) {
      console.error('[CRON] Weather fetch error:', error.message);
    }
  });

  console.log('[CRON] Weather job scheduled: every 15 minutes');
}

function startAQICron() {
  cron.schedule('*/10 * * * *', async () => {
    console.log('[CRON] Fetching AQI data from IBB...');
    try {
      const rawData = await aqiRepository.fetchFromIBB();
      const data = rawData.map(dto => aqiMapper.toDomain(dto));
      aqiRepository.setCached(data);
      console.log(`[CRON] AQI data updated: ${data.length} stations`);
    } catch (error) {
      console.error('[CRON] AQI fetch error:', error.message);
    }
  });

  console.log('[CRON] AQI job scheduled: every 10 minutes');
}

function startPrayerCron() {
  cron.schedule('0 */12 * * *', async () => {
    console.log('[CRON] Fetching prayer times...');
    try {
      for (const city of CITIES) {
        const rawData = await prayerRepository.fetchFromVakit(city);
        const prayer = prayerMapper.toDomain(rawData);
        prayerRepository.setCached(prayer);
        console.log(`[CRON] Prayer times updated for ${city}`);
      }
    } catch (error) {
      console.error('[CRON] Prayer fetch error:', error.message);
    }
  });

  console.log('[CRON] Prayer job scheduled: every 12 hours');
}

function startCurrencyCron() {
  cron.schedule('0 * * * *', async () => {
    console.log('[CRON] Fetching currency data from TCMB...');
    try {
      const rawData = await currencyRepository.fetchFromTCMB();
      const currencies = rawData.map(dto => currencyMapper.toDomain(dto));
      currencyRepository.setCached(currencies);
      console.log(`[CRON] Currency data updated: ${currencies.length} rates`);
    } catch (error) {
      console.error('[CRON] Currency fetch error:', error.message);
    }
  });

  console.log('[CRON] Currency job scheduled: every hour');
}

module.exports = {
  startEarthquakeCron,
  startWeatherCron,
  startAQICron,
  startPrayerCron,
  startCurrencyCron
};
