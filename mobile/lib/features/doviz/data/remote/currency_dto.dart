class CurrencyDTO {
  final String code;
  final String name;
  final double buy;
  final double sell;
  final double change;

  CurrencyDTO({
    required this.code,
    required this.name,
    required this.buy,
    required this.sell,
    required this.change,
  });

  factory CurrencyDTO.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0;
    }

    return CurrencyDTO(
      code: (json['code'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      buy: parseDouble(json['buy']),
      sell: parseDouble(json['sell']),
      change: parseDouble(json['change']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'buy': buy,
      'sell': sell,
      'change': change,
    };
  }
}

class CurrencyRate {
  final String code;
  final String name;
  final double buy;
  final double sell;
  final double change;
  final bool isGold;

  CurrencyRate({
    required this.code,
    required this.name,
    required this.buy,
    required this.sell,
    required this.change,
    this.isGold = false,
  });

  factory CurrencyRate.fromDTO(CurrencyDTO dto) {
    return CurrencyRate(
      code: dto.code,
      name: dto.name,
      buy: dto.buy,
      sell: dto.sell,
      change: dto.change,
    );
  }

  factory CurrencyRate.fromGold(Map<String, dynamic> json) {
    return CurrencyRate(
      code: json['code'] ?? 'XAU',
      name: json['name'] ?? 'Gram Altın',
      buy: (json['buy'] ?? 0).toDouble(),
      sell: (json['sell'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      isGold: true,
    );
  }
}
