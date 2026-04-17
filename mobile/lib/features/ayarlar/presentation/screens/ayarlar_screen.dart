import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turkiye_cevre_guvenligi/shared/providers/settings_provider.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/cache_service.dart';

class AyarlarScreen extends StatelessWidget {
  const AyarlarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('Görünüm'),
              _buildThemeSelector(context, settings),
              const SizedBox(height: 24),
              _buildSectionHeader('Bildirimler'),
              _buildEarthquakeThreshold(settings),
              _buildAQIThreshold(settings),
              const SizedBox(height: 24),
              _buildSectionHeader('Veri'),
              _buildRefreshInterval(settings),
              _buildClearCache(context),
              const SizedBox(height: 24),
              _buildSectionHeader('Hakkında'),
              _buildAbout(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsProvider settings) {
    return Card(
      key: const Key('ayarlar_tema_card'),
      child: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Aydınlık'),
            subtitle: const Text('Parlak tema'),
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (value) {
              if (value != null) settings.setThemeMode(value);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Karanlık'),
            subtitle: const Text('Koyu tema'),
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (value) {
              if (value != null) settings.setThemeMode(value);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Sistem'),
            subtitle: const Text('Cihaz ayarlarını takip et'),
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (value) {
              if (value != null) settings.setThemeMode(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEarthquakeThreshold(SettingsProvider settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deprem Bildirim Eşiği',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Switch(
                  key: const Key('ayarlar_bildirim_deprem_switch'),
                  value: true,
                  onChanged: (v) {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Deprem büyüklüğü >= ${settings.earthquakeThreshold.toStringAsFixed(1)}'),
            Slider(
              key: const Key('ayarlar_esik_deprem_slider'),
              value: settings.earthquakeThreshold,
              min: 1,
              max: 7,
              divisions: 12,
              label: settings.earthquakeThreshold.toStringAsFixed(1),
              onChanged: (value) {
                settings.setEarthquakeThreshold(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAQIThreshold(SettingsProvider settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hava Kalitesi Bildirim Eşiği',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Switch(
                  key: const Key('ayarlar_bildirim_aqi_switch'),
                  value: true,
                  onChanged: (v) {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('AQI >= ${settings.aqiThreshold}'),
            Slider(
              key: const Key('ayarlar_esik_aqi_slider'),
              value: settings.aqiThreshold.toDouble(),
              min: 50,
              max: 300,
              divisions: 10,
              label: settings.aqiThreshold.toString(),
              onChanged: (value) {
                settings.setAQIThreshold(value.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshInterval(SettingsProvider settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Otomatik Yenileme',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<int>(
              key: const Key('ayarlar_yenileme_dropdown'),
              value: settings.refreshInterval,
              isExpanded: true,
              items: [5, 10, 15, 30, 60].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value dakika'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) settings.setRefreshInterval(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearCache(BuildContext context) {
    return Card(
      child: ListTile(
        key: const Key('ayarlar_onbellek_temizle'),
        leading: const Icon(Icons.delete_outline),
        title: const Text('Önbelleği Temizle'),
        subtitle: const Text('Tüm önbellek verilerini siler'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Önbelleği Temizle'),
              content: const Text('Tüm önbellek verilerini silmek istediğinize emin misiniz?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Temizle'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            final cacheService = CacheService();
            await cacheService.clearAll();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Önbellek temizlendi')),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildAbout() {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Türkiye Çevre Güvenliği'),
            subtitle: Text('Versiyon 1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.api),
            title: const Text('API Kaynakları'),
            subtitle: const Text('AFAD, MGM, İBB, Vakit, TCMB'),
          ),
        ],
      ),
    );
  }
}
