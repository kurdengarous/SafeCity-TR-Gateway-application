const earthquakeRepository = require('../repositories/earthquakeRepository');
const { earthquakeMapper } = require('../mappers/mappers');

class EarthquakeService {
  async getEarthquakes(filters = {}) {
    let earthquakes = earthquakeRepository.getCached();

    if (!earthquakes) {
      const rawData = await earthquakeRepository.fetchFromAFAD();
      earthquakes = earthquakeMapper.toDomainList(rawData);
      earthquakeRepository.setCached(earthquakes);
    }

    if (filters.minMagnitude) {
      earthquakes = earthquakes.filter(e => e.magnitude >= filters.minMagnitude);
    }

    if (filters.maxMagnitude) {
      earthquakes = earthquakes.filter(e => e.magnitude <= filters.maxMagnitude);
    }

    if (filters.region) {
      earthquakes = earthquakes.filter(e =>
        e.location.toLowerCase().includes(filters.region.toLowerCase())
      );
    }

    return {
      earthquakes,
      lastUpdated: new Date().toISOString(),
      source: 'AFAD'
    };
  }

  async refresh() {
    const rawData = await earthquakeRepository.fetchFromAFAD();
    const earthquakes = earthquakeMapper.toDomainList(rawData);
    earthquakeRepository.setCached(earthquakes);
    return { earthquakes, lastUpdated: new Date().toISOString() };
  }
}

module.exports = new EarthquakeService();
