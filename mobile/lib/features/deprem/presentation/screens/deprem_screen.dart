import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:turkiye_cevre_guvenligi/features/deprem/presentation/providers/earthquake_provider.dart';
import 'package:turkiye_cevre_guvenligi/core/theme.dart';

class DepremScreen extends StatelessWidget {
  const DepremScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EarthquakeProvider(context),
      child: const _DepremScreenContent(),
    );
  }
}

class _DepremScreenContent extends StatefulWidget {
  const _DepremScreenContent();

  @override
  State<_DepremScreenContent> createState() => _DepremScreenContentState();
}

class _DepremScreenContentState extends State<_DepremScreenContent> {
  bool _showMap = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depremler'),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EarthquakeProvider>().refresh(context);
            },
          ),
        ],
      ),
      body: Consumer<EarthquakeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.earthquakes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.earthquakes.isEmpty) {
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

          return Column(
            children: [
              _buildFilters(context, provider),
              if (provider.lastUpdate != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Son güncelleme: ${DateFormat('HH:mm:ss').format(provider.lastUpdate!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _showMap
                    ? _buildMap(provider.earthquakes)
                    : _buildList(provider.earthquakes),
              ),
              _buildStatistics(provider.earthquakes),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatistics(List earthquakes) {
    if (earthquakes.isEmpty) return const SizedBox.shrink();

    final counts = <int, int>{};
    for (var eq in earthquakes) {
      final mag = eq.magnitude.floor();
      counts[mag] = (counts[mag] ?? 0) + 1;
    }

    final spots = counts.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return Container(
      key: const Key('deprem_istatistik'),
      height: 150,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Büyüklük Dağılımı', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.earthquake,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, EarthquakeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Slider(
                  key: const Key('deprem_filtre_buyukluk'),
                  value: provider.minMagnitude,
                  min: 0,
                  max: 7,
                  divisions: 14,
                  label: provider.minMagnitude.toString(),
                  onChanged: (value) {
                    provider.setMinMagnitude(value);
                  },
                ),
              ),
              Text('${provider.minMagnitude.toStringAsFixed(1)}+'),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.access_time, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  key: const Key('deprem_filtre_zaman'),
                  value: 'Son 24 Saat',
                  isExpanded: true,
                  items: ['Son 24 Saat', 'Son 7 Gün', 'Son 30 Gün'].map((e) {
                    return DropdownMenuItem(value: e, child: Text(e));
                  }).toList(),
                  onChanged: (v) {},
                ),
              ),
            ],
          ),
          TextField(
            key: const Key('deprem_filtre_bolge'),
            decoration: const InputDecoration(
              hintText: 'Bölge ara...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              provider.setRegionFilter(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMap(List earthquakes) {
    if (earthquakes.isEmpty) {
      return const Center(child: Text('Deprem verisi yok'));
    }

    return FlutterMap(
      key: const Key('deprem_harita'),
      options: const MapOptions(
        initialCenter: LatLng(39.0, 35.0),
        initialZoom: 6,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.turkiye_cevre_guvenligi',
        ),
        MarkerLayer(
          markers: earthquakes.map<Marker>((eq) {
            return Marker(
              point: LatLng(eq.latitude, eq.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showEarthquakeDetail(context, eq),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.getMagnitudeColor(eq.magnitude),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      eq.magnitude.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildList(List earthquakes) {
    return ListView.builder(
      key: const Key('deprem_liste'),
      itemCount: earthquakes.length,
      itemBuilder: (context, index) {
        final eq = earthquakes[index];
        return Card(
          key: Key('deprem_item_${eq.id}'),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.getMagnitudeColor(eq.magnitude),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  eq.magnitude.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Text(eq.location),
            subtitle: Text(
              '${DateFormat('dd/MM/yyyy HH:mm').format(eq.timestamp)} - ${eq.depth.toStringAsFixed(1)} km derinlik',
            ),
            trailing: Text(
              eq.type,
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () {
              _showEarthquakeDetail(context, eq);
            },
          ),
        );
      },
    );
  }

  void _showEarthquakeDetail(BuildContext context, dynamic eq) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.getMagnitudeColor(eq.magnitude),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        eq.magnitude.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
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
                          eq.location,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(eq.timestamp),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Derinlik', '${eq.depth.toStringAsFixed(1)} km'),
              _buildDetailRow('Enlem', eq.latitude.toStringAsFixed(4)),
              _buildDetailRow('Boylam', eq.longitude.toStringAsFixed(4)),
              _buildDetailRow('Tip', eq.type),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
