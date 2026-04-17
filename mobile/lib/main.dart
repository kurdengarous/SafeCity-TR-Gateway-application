import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:turkiye_cevre_guvenligi/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:turkiye_cevre_guvenligi/features/deprem/presentation/screens/deprem_screen.dart';
import 'package:turkiye_cevre_guvenligi/features/hava/presentation/screens/hava_screen.dart';
import 'package:turkiye_cevre_guvenligi/features/aqi/presentation/screens/aqi_screen.dart';
import 'package:turkiye_cevre_guvenligi/features/namaz/presentation/screens/namaz_screen.dart';
import 'package:turkiye_cevre_guvenligi/features/doviz/presentation/screens/doviz_screen.dart';
import 'package:turkiye_cevre_guvenligi/features/ayarlar/presentation/screens/ayarlar_screen.dart';
import 'package:turkiye_cevre_guvenligi/core/theme.dart';
import 'package:turkiye_cevre_guvenligi/shared/providers/settings_provider.dart';
import 'package:turkiye_cevre_guvenligi/shared/providers/connectivity_provider.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/api_service.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/cache_service.dart';
import 'package:turkiye_cevre_guvenligi/shared/services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await CacheService.init();
  await NotificationService.init();

  runApp(const TurkiyeCevreApp());
}

class TurkiyeCevreApp extends StatelessWidget {
  const TurkiyeCevreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        Provider(create: (_) => ApiService()),
        Provider(create: (_) => CacheService()),
        Provider(create: (_) => NotificationService()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Türkiye Çevre Güvenliği',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    DepremScreen(),
    HavaScreen(),
    AQIScreen(),
    NamazScreen(),
    DovizScreen(),
    AyarlarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, _) {
        return Scaffold(
          body: Column(
            children: [
              if (!connectivity.isOnline)
                Container(
                  width: double.infinity,
                  color: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Text(
                    '⚠️ İnternet bağlantısı yok - Çevrimdışı veriler gösteriliyor',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              Expanded(
                child: _screens[_currentIndex],
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                key: Key('nav_dashboard'),
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Ana Sayfa',
              ),
              NavigationDestination(
                key: Key('nav_deprem'),
                icon: Icon(Icons.warning_amber_outlined),
                selectedIcon: Icon(Icons.warning_amber),
                label: 'Deprem',
              ),
              NavigationDestination(
                key: Key('nav_hava'),
                icon: Icon(Icons.cloud_outlined),
                selectedIcon: Icon(Icons.cloud),
                label: 'Hava',
              ),
              NavigationDestination(
                key: Key('nav_aqi'),
                icon: Icon(Icons.air_outlined),
                selectedIcon: Icon(Icons.air),
                label: 'Hava Kal.',
              ),
              NavigationDestination(
                key: Key('nav_namaz'),
                icon: Icon(Icons.mosque_outlined),
                selectedIcon: Icon(Icons.mosque),
                label: 'Namaz',
              ),
              NavigationDestination(
                key: Key('nav_doviz'),
                icon: Icon(Icons.currency_exchange_outlined),
                selectedIcon: Icon(Icons.currency_exchange),
                label: 'Döviz',
              ),
              NavigationDestination(
                key: Key('nav_ayarlar'),
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Ayarlar',
              ),
            ],
          ),
        );
      },
    );
  }
}
