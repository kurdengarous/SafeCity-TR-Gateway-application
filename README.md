# 🏭 Türkiye Vatandaşının Çevre Güvenliği Aggregator'ı

**Hazırlayan:** 
**Adı Soyadı:** Ahmet Enes Kıranşal  
**Okul Numarası:** 24080410214

5 farklı resmi Türk kamu API'sini tek bir sistemde birleştiren, **Clean Architecture** prensiplerine dayalı, tam kapsamlı (full-stack) mobil uygulama projesi.

## 🏗️ Sistem Mimarisi

Proje, **Monorepo** yapısında backend ve mobile olmak üzere iki ana bölümden oluşur.

```
root/
├── backend/                  # Node.js 20 Express API Gateway
│   ├── src/
│   │   ├── routes/          # API Gateway rotaları (/deprem, /hava, vb.)
│   │   ├── services/       # İş mantığı ve veri işleme
│   │   ├── repositories/    # Veri erişim katmanı (API + Cache)
│   │   ├── dto/             # Ham API yanıt modelleri (Raw DTO)
│   │   ├── domain/          # Temiz domain modelleri
│   │   ├── mappers/         # DTO -> Domain dönüştürücüler
│   │   ├── cache/           # node-cache (TTL tabanlı)
│   │   ├── cron/            # node-cron periyodik işler
│   │   └── app.js           # Express sunucu yapılandırması
│   └── package.json
├── mobile/                   # Flutter Mobil Uygulaması
│   ├── lib/
│   │   ├── core/            # Tema ve global sabitler
│   │   ├── features/        # Özellik tabanlı (feature-first) klasörleme
│   │   │   ├── deprem/      # Harita + Liste + İstatistik
│   │   │   ├── hava/        # Anlık + 5 Günlük + 81 İl
│   │   │   ├── aqi/          # AQI Göstergesi + Sağlık Önerisi
│   │   │   ├── namaz/       # Vakitler + Geri Sayım
│   │   │   ├── doviz/       # Kur Takibi + Altın
│   │   │   └── ayarlar/     # Tema + Bildirim Eşikleri
│   │   └── shared/          # Paylaşılan servisler (Dio, Hive, vb.)
│   └── pubspec.yaml
├── docker-compose.yml        # Backend orkestrasyonu
└── README.md
```

## 📡 Veri Kaynakları & Cache Stratejisi

Backend, kamu API'lerini doğrudan istemciye sızdırmaz; **Proxy**, **Cache** ve **Normalizer** görevlerini üstlenir.

| Hizmet | Kaynak | TTL | Güncelleme (Cron) |
| :--- | :--- | :--- | :--- |
| **Deprem** | AFAD | 5 dk | 2 dk |
| **Hava** | MGM | 30 dk | 15 dk |
| **AQI** | İBB | 15 dk | 10 dk |
| **Namaz** | Vakit/Aladhan | 12 saat | Günlük |
| **Döviz** | TCMB (XML) | 1 saat | Saatlik |

## �️ Teknoloji Stack'i

### **Backend**
- **Runtime**: Node.js 20
- **Framework**: Express
- **HTTP Client**: Axios
- **Cache**: node-cache
- **Scheduler**: node-cron
- **Parsing**: xml2js (TCMB entegrasyonu için)

### **Mobile (Flutter)**
- **State Management**: Provider
- **Local Database**: Hive (Offline Cache)
- **HTTP Client**: Dio (Interceptors & Error Handling)
- **Mapping**: DTO -> Domain flow
- **Maps**: flutter_map + OpenStreetMap
- **Graphics**: fl_chart (Trend ve İstatistikler)
- **Notifications**: flutter_local_notifications

## 🚀 Kurulum ve Çalıştırma

### **1. Backend (Docker ile Önerilir)**
Backend'i Docker üzerinden anında ayağa kaldırabilirsiniz:
```bash
docker-compose up -d
```
Veya manuel kurulum:
```bash
cd backend
npm install
npm start
```
*API Gateway `http://localhost:3000` adresinde çalışacaktır.*

### **2. Mobile (Flutter)**
```bash
cd mobile
flutter pub get
# .env dosyasını oluşturun (API_URL=http://localhost:3000)
flutter run
```

## 🧪 Otomatik Test & Widget Key Kontratı

Proje, Maestro UI testleri ve Claude davranış incelemeleri için özel widget key'ler ile donatılmıştır.

### **Navigasyon (7 Tab)**
- `nav_dashboard`, `nav_deprem`, `nav_hava`, `nav_aqi`, `nav_namaz`, `nav_doviz`, `nav_ayarlar`

### **Kritik Ekran Widget'ları**
- **Dashboard**: `dashboard_deprem_card`, `dashboard_hava_card`, `dashboard_refresh`, `dashboard_offline_banner`
- **Deprem**: `deprem_harita`, `deprem_liste`, `deprem_filtre_buyukluk`, `deprem_istatistik`
- **Hava**: `hava_sicaklik_text`, `hava_sehir_dropdown`, `hava_5gun_liste`, `hava_favori_button`
- **AQI**: `aqi_renk_gosterge`, `aqi_oneri_kart`, `aqi_trend_grafik`
- **Döviz**: `doviz_usd_card`, `doviz_altin_card`, `doviz_liste`, `doviz_favori_button`
- **Ayarlar**: `ayarlar_tema_card`, `ayarlar_esik_deprem_slider`, `ayarlar_onbellek_temizle`

## � Lisans
Bu proje eğitim ve test amaçlıdır. MIT Lisansı ile korunmaktadır.
