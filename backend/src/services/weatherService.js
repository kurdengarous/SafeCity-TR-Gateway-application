const weatherRepository = require('../repositories/weatherRepository');
const { weatherMapper } = require('../mappers/mappers');

class WeatherService {
  async getWeather(city = 'Istanbul') {
    console.log(`[WeatherService] Fetching weather for: ${city}`);

    let weather = weatherRepository.getCached();

    if (!weather || weather.city.toLowerCase() !== city.toLowerCase()) {
      try {
        const rawData = await weatherRepository.fetchFromMGM(city);
        weather = weatherMapper.toDomain(rawData);
        weatherRepository.setCached(weather);
        console.log(`[WeatherService] Data fetched and cached for ${city}: ${weather.temperature}°C`);
      } catch (error) {
        console.error(`[WeatherService] Error fetching weather: ${error.message}`);
        throw error;
      }
    } else {
      console.log(`[WeatherService] Returning cached data for ${city}`);
    }

    return {
      ...weather,
      lastUpdated: new Date().toISOString(),
      source: 'MGM'
    };
  }

  async refresh(city = 'Istanbul') {
    console.log(`[WeatherService] Refreshing weather for: ${city}`);
    try {
      const rawData = await weatherRepository.fetchFromMGM(city);
      const weather = weatherMapper.toDomain(rawData);
      weatherRepository.setCached(weather);
      console.log(`[WeatherService] Data refreshed for ${city}`);
      return { ...weather, lastUpdated: new Date().toISOString() };
    } catch (error) {
      console.error(`[WeatherService] Refresh error: ${error.message}`);
      throw error;
    }
  }

  getSupportedCities() {
    return [
      'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya', 'Ankara', 'Antalya', 'Artvin',
      'Aydın', 'Balıkesir', 'Bilecik', 'Bingöl', 'Bitlis', 'Bolu', 'Burdur', 'Bursa', 'Çanakkale',
      'Çankırı', 'Çorum', 'Denizli', 'Diyarbakır', 'Edirne', 'Elazığ', 'Erzincan', 'Erzurum',
      'Eskişehir', 'Gaziantep', 'Giresun', 'Gümüşhane', 'Hakkari', 'Hatay', 'Isparta', 'Mersin',
      'İstanbul', 'İzmir', 'Kars', 'Kastamonu', 'Kayseri', 'Kırklareli', 'Kırşehir', 'Kocaeli',
      'Konya', 'Kütahya', 'Malatya', 'Manisa', 'Kahramanmaraş', 'Mardin', 'Muğla', 'Muş',
      'Nevşehir', 'Niğde', 'Ordu', 'Rize', 'Sakarya', 'Samsun', 'Siirt', 'Sinop', 'Sivas',
      'Tekirdağ', 'Tokat', 'Trabzon', 'Tunceli', 'Şanlıurfa', 'Uşak', 'Van', 'Yozgat', 'Zonguldak',
      'Aksaray', 'Bayburt', 'Karaman', 'Kırıkkale', 'Batman', 'Şırnak', 'Bartın', 'Ardahan',
      'Iğdır', 'Yalova', 'Karabük', 'Kilis', 'Osmaniye', 'Düzce'
    ];
  }
}

module.exports = new WeatherService();
