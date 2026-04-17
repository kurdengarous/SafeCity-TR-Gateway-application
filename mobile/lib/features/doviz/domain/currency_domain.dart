class CurrencyDomain {
  final String code;
  final String name;
  final double buyRate;
  final double sellRate;
  final double changePercent;
  final bool isGold;

  CurrencyDomain({
    required this.code,
    required this.name,
    required this.buyRate,
    required this.sellRate,
    required this.changePercent,
    this.isGold = false,
  });
}
