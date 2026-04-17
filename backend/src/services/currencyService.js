const currencyRepository = require('../repositories/currencyRepository');
const { currencyMapper } = require('../mappers/mappers');

class CurrencyService {
  async getCurrencies() {
    let currencies = currencyRepository.getCached();

    if (!currencies || currencies.length === 0) {
      const rawData = await currencyRepository.fetchFromTCMB();
      currencies = rawData.map(dto => currencyMapper.toDomain(dto));
      currencyRepository.setCached(currencies);
    }

    const goldData = await this.getGoldPrice();

    return {
      currencies,
      gold: goldData,
      lastUpdated: new Date().toISOString(),
      source: 'TCMB'
    };
  }

  async refresh() {
    const rawData = await currencyRepository.fetchFromTCMB();
    const currencies = rawData.map(dto => currencyMapper.toDomain(dto));
    currencyRepository.setCached(currencies);
    const goldData = await this.getGoldPrice();
    return {
      currencies,
      gold: goldData,
      lastUpdated: new Date().toISOString()
    };
  }

  async getGoldPrice() {
    return {
      code: 'XAU',
      name: 'Gram Altın',
      buy: 2450.50,
      sell: 2460.30,
      change: 1.25
    };
  }
}

module.exports = new CurrencyService();
