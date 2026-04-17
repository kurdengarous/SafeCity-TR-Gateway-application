import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turkiye_cevre_guvenligi/features/doviz/presentation/providers/currency_provider.dart';
import 'package:turkiye_cevre_guvenligi/core/theme.dart';

class DovizScreen extends StatelessWidget {
  const DovizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CurrencyProvider(context),
      child: const _DovizScreenContent(),
    );
  }
}

class _DovizScreenContent extends StatelessWidget {
  const _DovizScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Döviz Kurları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CurrencyProvider>().refresh(context);
            },
          ),
        ],
      ),
      body: Consumer<CurrencyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.currencies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.currencies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hata: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(context),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              key: const Key('doviz_liste'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.gold != null) ...[
                  _buildGoldCard(context, provider.gold!, provider),
                  const SizedBox(height: 24),
                ],
                const Text(
                  'Döviz Kurları',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...provider.currencies.map((c) => _buildCurrencyCard(context, c, provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoldCard(BuildContext context, dynamic gold, CurrencyProvider provider) {
    final isPositive = gold.change >= 0;

    return Card(
      key: const Key('doviz_altin_card'),
      color: AppColors.currency.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.currency.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.monetization_on, color: AppColors.currency, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gold.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Text(
                            'Alış: ${gold.buy.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Satış: ${gold.sell.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('doviz_favori_button'),
                  icon: Icon(
                    provider.isFavorite(gold.code, context) ? Icons.star : Icons.star_border,
                    color: provider.isFavorite(gold.code, context) ? Colors.amber : null,
                  ),
                  onPressed: () => provider.toggleFavorite(gold.code, context),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  Text(
                    '${gold.change.abs().toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyCard(BuildContext context, dynamic currency, CurrencyProvider provider) {
    final isPositive = currency.change >= 0;
    final key = currency.code == 'USD' 
        ? const Key('doviz_usd_card') 
        : (currency.code == 'EUR' ? const Key('doviz_eur_card') : null);

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.currency.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      currency.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currency.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Text('Alış: ${currency.buy.toStringAsFixed(2)}'),
                          Text('Satış: ${currency.sell.toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    provider.isFavorite(currency.code, context) ? Icons.star : Icons.star_border,
                    color: provider.isFavorite(currency.code, context) ? Colors.amber : null,
                    size: 20,
                  ),
                  onPressed: () => provider.toggleFavorite(currency.code, context),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${currency.change.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
