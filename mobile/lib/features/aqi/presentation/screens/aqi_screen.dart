import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:turkiye_cevre_guvenligi/features/aqi/presentation/providers/aqi_provider.dart';
import 'package:turkiye_cevre_guvenligi/core/theme.dart';

class AQIScreen extends StatelessWidget {
  const AQIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AQIProvider(context),
      child: const _AQIScreenContent(),
    );
  }
}

class _AQIScreenContent extends StatelessWidget {
  const _AQIScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hava Kalitesi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AQIProvider>().refresh(context);
            },
          ),
        ],
      ),
      body: Consumer<AQIProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.stations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.stations.isEmpty) {
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
              children: [
                if (provider.selectedStation != null)
                  _buildMainIndicator(provider.selectedStation!),
                const SizedBox(height: 24),
                _buildStationList(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainIndicator(dynamic station) {
    final aqiColor = AppColors.getAQIColor(station.aqi);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              key: const Key('aqi_renk_gosterge'),
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: aqiColor, width: 8),
                color: aqiColor.withOpacity(0.1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    station.aqi.toString(),
                    key: const Key('aqi_deger_text'),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: aqiColor,
                    ),
                  ),
                  const Text('AQI'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              station.station,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              key: const Key('aqi_kategori_text'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: aqiColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                station.levelText,
                style: TextStyle(
                  color: aqiColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              key: const Key('aqi_oneri_kart'),
              color: aqiColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  station.healthMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('AQI Trendi (Son 24 Saat)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              key: const Key('aqi_trend_grafik'),
              height: 100,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 45),
                        const FlSpot(4, 52),
                        const FlSpot(8, 78),
                        const FlSpot(12, 65),
                        const FlSpot(16, 82),
                        const FlSpot(20, 71),
                        const FlSpot(24, 78),
                      ],
                      isCurved: true,
                      color: aqiColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: aqiColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              key: Key('aqi_istasyon_harita'),
              height: 200,
              child: Center(child: Text('İstasyon Haritası Placeholder')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationList(AQIProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İstasyonlar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...provider.stations.map((station) {
          final color = AppColors.getAQIColor(station.aqi);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    station.aqi.toString(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text(station.station),
              subtitle: Text(station.healthMessage),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  station.levelText,
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ),
              onTap: () => provider.selectStation(station),
            ),
          );
        }),
      ],
    );
  }
}
