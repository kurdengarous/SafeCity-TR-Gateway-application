const { Earthquake } = require('../domain/models');
const { EarthquakeDTO } = require('../dto/dtos');

const earthquakeMapper = {
  toDomain(dto) {
    if (dto instanceof EarthquakeDTO) {
      return new Earthquake({
        id: dto.DepremId,
        timestamp: dto.timestamp,
        latitude: dto.latitude,
        longitude: dto.longitude,
        depth: dto.depth,
        magnitude: dto.magnitude,
        location: dto.location,
        type: dto.type
      });
    }
    return new Earthquake({
      id: dto.DepremId || dto.id,
      timestamp: dto.timestamp,
      latitude: dto.latitude,
      longitude: dto.longitude,
      depth: dto.depth,
      magnitude: dto.magnitude,
      location: dto.location,
      type: dto.type
    });
  },

  toDomainList(dtoList) {
    return dtoList.map(dto => this.toDomain(dto));
  }
};

const weatherMapper = {
  toDomain(dto) {
    return {
      city: dto.city,
      temperature: dto.temperature,
      humidity: dto.humidity,
      windSpeed: dto.windSpeed,
      description: dto.description,
      forecast: dto.forecast || []
    };
  }
};

const aqiMapper = {
  toDomain(dto) {
    const aqi = dto.aqi;
    let healthMessage = '';

    if (aqi <= 50) {
      healthMessage = 'Hava kalitesi iyi. Dışarıda vakit geçirmek için ideal.';
    } else if (aqi <= 100) {
      healthMessage = 'Hava kalitesi orta. Hassas gruplar dikkatli olmalı.';
    } else if (aqi <= 150) {
      healthMessage = 'Hassas gruplar için sağlık sorunları oluşabilir.';
    } else if (aqi <= 200) {
      healthMessage = 'Herkes sağlık etkileri yaşayabilir. Dışarı çıkmayı sınırlayın.';
    } else if (aqi <= 300) {
      healthMessage = 'Sağlık uyarısı: Herkes ciddi sağlık etkileriyle karşılaşabilir.';
    } else {
      healthMessage = 'Tehlikeli hava kalitesi. Mümkünse evde kalın.';
    }

    return {
      station: dto.station,
      aqi: dto.aqi,
      pm25: dto.pm25,
      pm10: dto.pm10,
      o3: dto.o3,
      no2: dto.no2,
      co: dto.co,
      healthMessage,
      timestamp: dto.timestamp
    };
  }
};

const prayerMapper = {
  toDomain(dto) {
    return {
      date: dto.date,
      fajr: dto.fajr,
      sunrise: dto.sunrise,
      dhuhr: dto.dhuhr,
      asr: dto.asr,
      maghrib: dto.maghrib,
      isha: dto.isha
    };
  }
};

const currencyMapper = {
  toDomain(dto) {
    return {
      code: dto.code,
      name: dto.name,
      buy: dto.buy,
      sell: dto.sell,
      change: dto.change
    };
  }
};

module.exports = {
  earthquakeMapper,
  weatherMapper,
  aqiMapper,
  prayerMapper,
  currencyMapper
};
