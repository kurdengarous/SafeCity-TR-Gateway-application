const axios = require('axios');
const xml2js = require('xml2js');
const { CurrencyDTO } = require('../dto/dtos');
const { cache, keys, TTL } = require('../cache/cacheManager');

class CurrencyRepository {
  async fetchFromTCMB() {
    try {
      const response = await axios.get('https://www.tcmb.gov.tr/kurlar/today.xml', {
        timeout: 15000
      });

      const parser = new xml2js.Parser({ explicitArray: false });
      const result = await parser.parseStringPromise(response.data);

      console.log('[TCMB] Response received, parsing...');

      if (result && result.Tarih_Date && result.Tarih_Date.Currency) {
        const currencies = Array.isArray(result.Tarih_Date.Currency)
          ? result.Tarih_Date.Currency
          : [result.Tarih_Date.Currency];

        const usd = currencies.find(c => (c.$ ? c.$.Kod : c.Kod) === 'USD');
        const eur = currencies.find(c => (c.$ ? c.$.Kod : c.Kod) === 'EUR');
        const gbp = currencies.find(c => (c.$ ? c.$.Kod : c.Kod) === 'GBP');
        const chf = currencies.find(c => (c.$ ? c.$.Kod : c.Kod) === 'CHF');

        const rates = [];
        if (usd) {
          const kod = usd.$ ? usd.$.Kod : usd.Kod;
          rates.push(new CurrencyDTO({
            code: kod || 'USD',
            name: 'ABD Doları',
            buy: parseFloat(usd.ForexBuying || usd.Alis || usd.Buying || 0),
            sell: parseFloat(usd.ForexSelling || usd.Satis || usd.Selling || 0),
            change: parseFloat(usd.Degisim || usd.Change || 0)
          }));
        }
        if (eur) {
          const kod = eur.$ ? eur.$.Kod : eur.Kod;
          rates.push(new CurrencyDTO({
            code: kod || 'EUR',
            name: 'Euro',
            buy: parseFloat(eur.ForexBuying || eur.Alis || eur.Buying || 0),
            sell: parseFloat(eur.ForexSelling || eur.Satis || eur.Selling || 0),
            change: parseFloat(eur.Degisim || eur.Change || 0)
          }));
        }
        if (gbp) {
          const kod = gbp.$ ? gbp.$.Kod : gbp.Kod;
          rates.push(new CurrencyDTO({
            code: kod || 'GBP',
            name: 'İngiliz Sterlini',
            buy: parseFloat(gbp.ForexBuying || gbp.Alis || gbp.Buying || 0),
            sell: parseFloat(gbp.ForexSelling || gbp.Satis || gbp.Selling || 0),
            change: parseFloat(gbp.Degisim || gbp.Change || 0)
          }));
        }
        if (chf) {
          const kod = chf.$ ? chf.$.Kod : chf.Kod;
          rates.push(new CurrencyDTO({
            code: kod || 'CHF',
            name: 'İsviçre Frangı',
            buy: parseFloat(chf.ForexBuying || chf.Alis || chf.Buying || 0),
            sell: parseFloat(chf.ForexSelling || chf.Satis || chf.Selling || 0),
            change: parseFloat(chf.Degisim || chf.Change || 0)
          }));
        }

        console.log('[TCMB] Parsed currencies:', rates.length);
        if (rates.length > 0 && rates[0].buy > 0) {
          return rates;
        }
      }

      console.log('[TCMB] Falling back to mock data');
      return this.getMockCurrencies();
    } catch (error) {
      console.error('[TCMB] API Error:', error.message);
      return this.getMockCurrencies();
    }
  }

  getCurrencyName(code) {
    const names = {
      USD: 'ABD Doları',
      EUR: 'Euro',
      GBP: 'İngiliz Sterlini',
      CHF: 'İsviçre Frangı'
    };
    return names[code] || code;
  }

  getMockCurrencies() {
    return [
      new CurrencyDTO({ code: 'USD', name: 'ABD Doları', buy: 32.15, sell: 32.25, change: 0.12 }),
      new CurrencyDTO({ code: 'EUR', name: 'Euro', buy: 34.85, sell: 34.95, change: -0.08 }),
      new CurrencyDTO({ code: 'GBP', name: 'İngiliz Sterlini', buy: 40.50, sell: 40.70, change: 0.05 }),
      new CurrencyDTO({ code: 'CHF', name: 'İsviçre Frangı', buy: 35.90, sell: 36.10, change: 0.02 })
    ];
  }

  getCached() {
    return cache.get(keys.CURRENCY);
  }

  setCached(data) {
    cache.set(keys.CURRENCY, data, TTL.CURRENCY);
  }
}

module.exports = new CurrencyRepository();
