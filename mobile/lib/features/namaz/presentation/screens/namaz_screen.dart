import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turkiye_cevre_guvenligi/features/namaz/presentation/providers/prayer_provider.dart';
import 'package:turkiye_cevre_guvenligi/core/theme.dart';

class NamazScreen extends StatelessWidget {
  const NamazScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PrayerProvider(context),
      child: const _NamazScreenContent(),
    );
  }
}

class _NamazScreenContent extends StatelessWidget {
  const _NamazScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Namaz Vakitleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PrayerProvider>().refresh(context);
            },
          ),
        ],
      ),
      body: Consumer<PrayerProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.prayer == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.prayer == null) {
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

          final prayer = provider.prayer!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCitySelector(context, provider),
                const SizedBox(height: 16),
                _buildNextPrayer(context, prayer),
                const SizedBox(height: 24),
                _buildPrayerTimes(prayer),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCitySelector(BuildContext context, PrayerProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButton<String>(
          key: const Key('namaz_sehir_dropdown'),
          value: provider.selectedCity,
          isExpanded: true,
          underline: const SizedBox(),
          items: provider.cities.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Text(city),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              provider.setCity(value, context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildNextPrayer(BuildContext context, dynamic prayer) {
    return Card(
      color: AppColors.prayer.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.mosque,
              size: 48,
              color: AppColors.prayer,
            ),
            const SizedBox(height: 8),
            const Text(
              'Sonraki Namaz',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              prayer.nextPrayerName,
              key: const Key('namaz_yaklasan_vakit'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.prayer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              prayer.nextPrayerTime,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${prayer.remainingHours} saat ${prayer.remainingMinutes} dakika kaldı',
              key: const Key('namaz_kalan_sure'),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimes(dynamic prayer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Günlük Vakitler',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildPrayerRow('İmsak', prayer.fajr, Icons.nightlight_round, const Key('namaz_imsak_text')),
        _buildPrayerRow('Güneş', prayer.sunrise, Icons.wb_sunny, const Key('namaz_gunes_text')),
        _buildPrayerRow('Öğle', prayer.dhuhr, Icons.wb_cloudy, const Key('namaz_ogle_text')),
        _buildPrayerRow('İkindi', prayer.asr, Icons.cloud, const Key('namaz_ikindi_text')),
        _buildPrayerRow('Akşam', prayer.maghrib, Icons.nights_stay, const Key('namaz_aksam_text')),
        _buildPrayerRow('Yatsı', prayer.isha, Icons.bedtime, const Key('namaz_yatsi_text')),
        const SizedBox(height: 16),
        const Card(
          key: Key('namaz_haftalik_liste'),
          child: ListTile(
            title: Text('Haftalık Liste'),
            subtitle: Text('Placeholder'),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerRow(String name, String time, IconData icon, Key key) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.prayer),
        title: Text(name),
        trailing: Text(
          time,
          key: key,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
