import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:turkiye_cevre_guvenligi/shared/providers/settings_provider.dart';
import 'package:turkiye_cevre_guvenligi/core/theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Türkiye Çevre Güvenliği'),
      ),
      body: RefreshIndicator(
        key: const Key('dashboard_refresh'),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOfflineBanner(context),
              _buildWelcomeCard(context),
              const SizedBox(height: 16),
              _buildSummaryCards(context),
              const SizedBox(height: 16),
              _buildLastUpdated(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    // In a real app, you'd use a connectivity provider here
    return const SizedBox.shrink(key: Key('dashboard_offline_banner'));
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.location_city,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoş Geldiniz',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'İstanbul, Türkiye',
                    key: const Key('dashboard_konum_text'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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

  Widget _buildSummaryCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Özet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.3,
          children: [
            _buildSummaryCard(
              context,
              'Deprem',
              'Son: 2.1 ML',
              'Simav',
              Icons.warning_amber,
              AppColors.earthquake,
              const Key('dashboard_deprem_card'),
            ),
            _buildSummaryCard(
              context,
              'Hava',
              '24°C',
              'Parçalı Bulutlu',
              Icons.cloud,
              AppColors.weather,
              const Key('dashboard_hava_card'),
            ),
            _buildSummaryCard(
              context,
              'Hava Kal.',
              '78 AQI',
              'Orta',
              Icons.air,
              AppColors.aqiModerate,
              const Key('dashboard_aqi_card'),
            ),
            _buildSummaryCard(
              context,
              'Namaz',
              '13:15',
              'Öğle',
              Icons.mosque,
              AppColors.prayer,
              const Key('dashboard_namaz_card'),
            ),
            _buildSummaryCard(
              context,
              'Döviz',
              '32.15 TL',
              'USD/TRY',
              Icons.currency_exchange,
              AppColors.currency,
              const Key('dashboard_doviz_card'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    Key key,
  ) {
    return Card(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Icon(icon, size: 20, color: color),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Son güncelleme: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
