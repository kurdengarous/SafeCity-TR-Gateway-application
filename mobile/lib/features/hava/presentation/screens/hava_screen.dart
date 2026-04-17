import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:turkiye_cevre_guvenligi/features/hava/presentation/providers/weather_provider.dart';
import 'package:turkiye_cevre_guvenligi/core/theme.dart';

class HavaScreen extends StatelessWidget {
  const HavaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeatherProvider(context),
      child: const _HavaScreenContent(),
    );
  }
}

class _HavaScreenContent extends StatelessWidget {
  const _HavaScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hava Durumu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WeatherProvider>().refresh(context);
            },
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.weather == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.weather == null) {
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

          final weather = provider.weather!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCitySelector(context, provider),
                const SizedBox(height: 16),
                _buildCurrentWeather(context, weather),
                const SizedBox(height: 24),
                _buildHourlyForecast(weather),
                const SizedBox(height: 24),
                _buildDailyForecast(weather),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCitySelector(BuildContext context, WeatherProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                key: const Key('hava_sehir_dropdown'),
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
            IconButton(
              key: const Key('hava_gps_button'),
              icon: const Icon(Icons.my_location),
              onPressed: () {
                // GPS logic
              },
            ),
            IconButton(
              key: const Key('hava_favori_button'),
              icon: Icon(
                provider.isFavorite(provider.selectedCity, context)
                    ? Icons.star
                    : Icons.star_border,
                color: provider.isFavorite(provider.selectedCity, context)
                    ? Colors.amber
                    : null,
              ),
              onPressed: () {
                provider.toggleFavorite(provider.selectedCity, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(BuildContext context, dynamic weather) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.weather.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.wb_sunny, size: 48, color: Colors.orange),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${weather.temperature.toStringAsFixed(1)}°C',
                        key: const Key('hava_sicaklik_text'),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weather.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  'Nem',
                  '${weather.humidity}%',
                  Icons.water_drop,
                  const Key('hava_nem_text'),
                ),
                _buildInfoItem(
                  'Rüzgar',
                  '${weather.windSpeed} km/s',
                  Icons.air,
                  const Key('hava_ruzgar_text'),
                ),
                _buildInfoItem(
                  'Hissedilen',
                  '${(weather.temperature - 2).toStringAsFixed(1)}°',
                  Icons.thermostat,
                  const Key('hava_hissedilen_text'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Key key) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          key: key,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast(dynamic weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          ' Saatlik Tahmin',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            key: const Key('hava_saatlik_liste'),
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (context, index) {
              final hour = DateTime.now().hour + index;
              return Card(
                margin: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 70,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${hour % 24}:00'),
                      const Icon(Icons.cloud, size: 28),
                      Text(
                        '${20 + index}°',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecast(dynamic weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          ' 5 Günlük Tahmin',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: ListView.builder(
            key: const Key('hava_5gun_liste'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(DateFormat('EEEE, dd MMMM').format(date)),
                  subtitle: weather.forecast.isNotEmpty
                      ? Text(weather.forecast[index % weather.forecast.length].description)
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${25 + index}°',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${18 + index}°',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
