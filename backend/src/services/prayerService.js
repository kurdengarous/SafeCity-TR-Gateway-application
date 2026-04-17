const prayerRepository = require('../repositories/prayerRepository');
const { prayerMapper } = require('../mappers/mappers');

class PrayerService {
  async getPrayerTimes(city = 'Istanbul') {
    let prayer = prayerRepository.getCached();

    if (!prayer) {
      const rawData = await prayerRepository.fetchFromVakit(city);
      prayer = prayerMapper.toDomain(rawData);
      prayerRepository.setCached(prayer);
    }

    const now = new Date();
    const times = {
      imsak: prayer.fajr,
      gunes: prayer.sunrise,
      ogle: prayer.dhuhr,
      ikindi: prayer.asr,
      aksam: prayer.maghrib,
      yatsi: prayer.isha
    };

    const nextPrayer = this.getNextPrayer(now, times);
    const timeRemaining = this.getTimeRemaining(now, nextPrayer, times);

    return {
      ...prayer,
      city,
      times,
      nextPrayer: {
        name: nextPrayer,
        time: times[nextPrayer.toLowerCase()],
        remaining: timeRemaining
      },
      lastUpdated: new Date().toISOString(),
      source: 'Vakit'
    };
  }

  async refresh(city = 'Istanbul') {
    const rawData = await prayerRepository.fetchFromVakit(city);
    const prayer = prayerMapper.toDomain(rawData);
    prayerRepository.setCached(prayer);
    return { ...prayer, lastUpdated: new Date().toISOString() };
  }

  getNextPrayer(now, times) {
    const currentMinutes = now.getHours() * 60 + now.getMinutes();

    const prayerList = [
      { name: 'İmsak', key: 'imsak', minutes: this.timeToMinutes(times.imsak) },
      { name: 'Güneş', key: 'gunes', minutes: this.timeToMinutes(times.gunes) },
      { name: 'Öğle', key: 'ogle', minutes: this.timeToMinutes(times.ogle) },
      { name: 'İkindi', key: 'ikindi', minutes: this.timeToMinutes(times.ikindi) },
      { name: 'Akşam', key: 'aksam', minutes: this.timeToMinutes(times.aksam) },
      { name: 'Yatsı', key: 'yatsi', minutes: this.timeToMinutes(times.yatsi) }
    ];

    for (const prayer of prayerList) {
      if (prayer.minutes > currentMinutes) {
        return prayer.name;
      }
    }

    return 'İmsak';
  }

  timeToMinutes(time) {
    if (!time) return 0;
    const [hours, minutes] = time.split(':').map(Number);
    return hours * 60 + minutes;
  }

  getTimeRemaining(now, nextPrayer, times) {
    const nextMinutes = this.timeToMinutes(times[nextPrayer.toLowerCase()]);
    const currentMinutes = now.getHours() * 60 + now.getMinutes();

    let diff = nextMinutes - currentMinutes;
    if (diff < 0) diff += 1440;

    const hours = Math.floor(diff / 60);
    const minutes = diff % 60;

    return { hours, minutes, total: diff };
  }
}

module.exports = new PrayerService();
