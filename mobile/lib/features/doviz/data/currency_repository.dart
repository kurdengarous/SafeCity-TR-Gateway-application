import 'package:dio/dio.dart';
import 'package:xml/xml.dart';
import 'package:turkiye_cevre_guvenligi/features/doviz/data/remote/currency_dto.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/api_service.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/cache_service.dart';

class CurrencyRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  CurrencyRepository(this._apiService, this._cacheService);

  Future<CurrencyData> getCurrencies({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cacheService.getCurrency();
      if (cached != null) {
        return _parseCurrencyData(cached);
      }
    }

    final response = await _apiService.get<Map<String, dynamic>>(
      'https://www.tcmb.gov.tr/kurlar/today.xml',
      responseType: ResponseType.plain,
      parser: (data) => _parseTcmbXml(data.toString()),
    );

    if (response.isSuccess && response.data != null) {
      await _cacheService.cacheCurrency(response.data!);
      return _parseCurrencyData(response.data!);
    }

    final cached = _cacheService.getCurrency();
    if (cached != null) {
      return _parseCurrencyData(cached);
    }

    throw Exception('Döviz verisi alınamadı');
  }

  CurrencyData _parseCurrencyData(Map<String, dynamic> data) {
    final currencies = (data['currencies'] as List<dynamic>?)
            ?.map((e) => CurrencyRate.fromDTO(CurrencyDTO.fromJson(e)))
            .toList() ??
        [];

    CurrencyRate? gold;
    if (data['gold'] != null) {
      gold = CurrencyRate.fromGold(data['gold']);
    }

    return CurrencyData(currencies: currencies, gold: gold);
  }

  Map<String, dynamic> _parseTcmbXml(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final currencyElements = document.findAllElements('Currency');

    final currencies = <Map<String, dynamic>>[];

    for (final currency in currencyElements) {
      final code = currency.getAttribute('CurrencyCode') ?? currency.getAttribute('Kod') ?? '';
      if (code.isEmpty) continue;

      final name = _readElement(currency, 'Isim').isNotEmpty
          ? _readElement(currency, 'Isim')
          : _readElement(currency, 'CurrencyName');
      final buy = _parseDouble(_readElement(currency, 'ForexBuying'));
      final sell = _parseDouble(_readElement(currency, 'ForexSelling'));

      if (buy == 0 && sell == 0) {
        continue;
      }

      currencies.add({
        'code': code,
        'name': name,
        'buy': buy,
        'sell': sell,
        'change': 0,
      });
    }

    currencies.sort((a, b) {
      const priority = ['USD', 'EUR', 'GBP'];
      final left = priority.indexOf(a['code']);
      final right = priority.indexOf(b['code']);
      if (left == -1 && right == -1) return 0;
      if (left == -1) return 1;
      if (right == -1) return -1;
      return left.compareTo(right);
    });

    return {
      'currencies': currencies,
      'gold': {
        'code': 'XAU',
        'name': 'Gram Altın',
        'buy': 0,
        'sell': 0,
        'change': 0,
      },
    };
  }

  String _readElement(XmlElement element, String name) {
    final child = element.getElement(name);
    return child?.innerText.trim() ?? '';
  }

  double _parseDouble(String value) {
    if (value.isEmpty) return 0;
    return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  }
}

class CurrencyData {
  final List<CurrencyRate> currencies;
  final CurrencyRate? gold;

  CurrencyData({required this.currencies, this.gold});
}
