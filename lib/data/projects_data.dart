import '../models/project.dart';

/// Örnek proje verileri.
/// 
/// Bu liste, portföyde gösterilecek tüm projeleri içerir.
/// Yeni proje eklemek için bu listeye yeni [Project] nesneleri ekleyin.
/// 
/// Her proje şu bilgileri içermelidir:
/// - Temel bilgiler (id, title, subtitle, category, tags)
/// - Dokümantasyon (problem, approach, implementation, results, lessonsLearned)
/// - Ek bilgiler (technologies, imageUrls, githubUrl, demoUrl)
/// 
/// [featured] = true olan projeler ana sayfada öne çıkar.
final List<Project> sampleProjects = [
  Project(
    id: 'smart-irrigation',
    title: 'Akıllı Sulama Sistemi',
    subtitle: 'IoT tabanlı toprak nem sensörü ve otomatik sulama kontrolü',
    category: ProjectCategory.electronics,
    tags: ['ESP32', 'IoT', 'Sensör', 'PCB Tasarımı'],
    thumbnailUrl: 'assets/projects/irrigation.png',
    date: DateTime(2024, 6, 15),
    featured: true,
    problem: '''
Geleneksel sulama sistemleri, toprak nemini dikkate almadan sabit zamanlarda çalışır. 
Bu durum hem su israfına hem de bitkilerin aşırı veya yetersiz sulanmasına yol açar.

**Hedef:** Toprak nemini gerçek zamanlı ölçen ve sadece gerektiğinde sulama yapan 
düşük maliyetli, güvenilir bir sistem tasarlamak.
''',
    approach: '''
Problemi üç ana bileşene ayırdım:

1. **Sensör Modülü:** Kapasitif toprak nem sensörü seçtim (rezistif sensörler korozyona 
   daha yatkın). Kalibrasyonu için referans nem ölçümleri aldım.

2. **Kontrol Ünitesi:** ESP32 mikrodenetleyici - WiFi dahili, düşük güç modları mevcut, 
   yeterli ADC çözünürlüğü.

3. **Aktüatör:** 12V selenoid valf, MOSFET ile sürülecek. Flyback diyot koruması ekledim.

Alternatif olarak Arduino + WiFi shield düşündüm ama maliyet ve karmaşıklık açısından 
ESP32 daha mantıklıydı.
''',
    implementation: '''
**Donanım:**
- Özel PCB tasarladım (KiCad) - güç regülasyonu, sensör bağlantıları, röle çıkışı
- 3.3V LDO regülatör, reverse polarity koruması
- Optokuplör ile izole röle sürücü

**Yazılım:**
- FreeRTOS task yapısı: sensör okuma, WiFi iletişim, valf kontrolü
- MQTT protokolü ile bulut bağlantısı
- Histerezis algoritması ile gereksiz açma-kapama önlendi
- OTA güncelleme desteği

**Test:**
- 30 günlük saha testi, sıcaklık kompanzasyonu eklendi
- Güç tüketimi optimizasyonu: deep sleep modunda 15µA
''',
    results: '''
- %40 su tasarrufu sağlandı (manuel sisteme göre)
- Sistem 6 aydır kesintisiz çalışıyor
- Birim maliyet: ~45 TL (sensör hariç)
- Mobil uygulama ile uzaktan izleme
''',
    lessonsLearned: '''
**Doğru yaptıklarım:**
- Kapasitif sensör seçimi uzun ömür sağladı
- Modüler tasarım sayesinde farklı valf tipleri desteklendi

**Geliştirilecekler:**
- Güneş paneli + batarya versiyonu eklenebilir
- Çoklu sensör desteği için mesh network düşünülebilir

**Öğrendiklerim:**
- Saha koşullarında test etmeden tasarımı bitirme
- Nem sensörü kalibrasyonu toprak tipine göre değişiyor
''',
    technologies: ['ESP32', 'KiCad', 'FreeRTOS', 'MQTT', 'C/C++', 'Flutter'],
    githubUrl: 'https://github.com/example/smart-irrigation',
  ),
  
  Project(
    id: 'cnc-controller',
    title: '3 Eksenli CNC Kontrol Kartı',
    subtitle: 'GRBL uyumlu, A4988 step motor sürücülü kontrol sistemi',
    category: ProjectCategory.mechanical,
    tags: ['CNC', 'Step Motor', 'GRBL', 'PCB'],
    thumbnailUrl: 'assets/projects/cnc.png',
    date: DateTime(2024, 3, 20),
    featured: true,
    problem: '''
Hobi CNC makineleri için mevcut kontrol kartları ya çok pahalı ya da güvenilirlik 
sorunları yaşıyor. Özellikle soğutma ve EMI filtreleme konularında eksiklikler var.

**Hedef:** Endüstriyel kalitede, açık kaynaklı, düşük maliyetli CNC kontrol kartı.
''',
    approach: '''
GRBL firmware'ini temel aldım - kanıtlanmış, aktif topluluk, G-code uyumlu.

**Tasarım kararları:**
- ATmega328P yerine ATmega2560 (daha fazla eksen potansiyeli)
- A4988 sürücü (1/16 microstepping, ayarlanabilir akım)
- Her sürücü için ayrı soğutucu + aktif fan header
- Optokuplör izolasyonlu limit switch girişleri
- EMI filtreli motor çıkışları
''',
    implementation: '''
**Mekanik:**
- Alüminyum PCB backplate ile ısı dağılımı
- DIN ray montaj uyumlu kasa tasarımı (Fusion 360)

**Elektronik:**
- 4 katmanlı PCB (sinyal bütünlüğü için)
- TVS diyotlar ile ESD koruması
- Her eksen için ayrı enable/fault LED

**Yazılım:**
- GRBL 1.1h fork'u, özel homing cycle
- USB-Serial + WiFi (ESP01) dual interface
''',
    results: '''
- 0.01mm pozisyon tekrarlanabilirliği
- 8 saatlik kesintisiz çalışma testinden geçti
- Motor sürücü sıcaklığı max 45°C (25°C ortamda)
- 5 adet üretildi, 3'ü aktif kullanımda
''',
    lessonsLearned: '''
**Başarılar:**
- Termal tasarım çok önemliymiş - ilk prototipte sürücüler aşırı ısınıyordu
- Optokuplör izolasyonu EMI sorunlarını büyük ölçüde çözdü

**Hatalar:**
- İlk versiyonda USB ground loop sorunu vardı, izole DC-DC eklendi
- Silk screen yazıları çok küçüktü, okunması zordu

**Sonraki adımlar:**
- Kapalı döngü servo motor desteği
- Ethernet bağlantısı
''',
    technologies: ['ATmega2560', 'GRBL', 'KiCad', 'Fusion 360', 'C'],
    githubUrl: 'https://github.com/example/cnc-controller',
  ),
  
  Project(
    id: 'inventory-system',
    title: 'Elektronik Parça Envanter Sistemi',
    subtitle: 'QR kod tabanlı, mobil uyumlu stok takip uygulaması',
    category: ProjectCategory.software,
    tags: ['Flutter', 'Firebase', 'QR Code', 'REST API'],
    thumbnailUrl: 'assets/projects/inventory.png',
    date: DateTime(2024, 9, 1),
    featured: true,
    problem: '''
Elektronik atölyemde yüzlerce farklı komponent var. Excel tablosu ile takip etmek 
sürdürülebilir değil - parçayı bulmak, stok miktarını güncellemek zaman alıyor.

**Hedef:** Hızlı arama, QR kod ile ekleme/çıkarma, düşük stok uyarısı.
''',
    approach: '''
**Teknoloji seçimi:**
- Flutter (tek codebase, web + mobil)
- Firebase (gerçek zamanlı sync, authentication)
- Barcode/QR scanner için native plugin

**Veri modeli:**
- Hiyerarşik kategori yapısı
- Lokasyon takibi (hangi çekmece/kutu)
- Tedarikçi ve fiyat bilgisi
- Datasheet URL referansı
''',
    implementation: '''
**Backend:**
- Firestore collection yapısı: components, categories, locations
- Cloud Functions ile düşük stok email bildirimi
- Günlük backup Cloud Storage'a

**Frontend:**
- BLoC pattern ile state management
- Offline-first mimari (Hive local cache)
- Responsive tasarım (tablet optimizasyonu)
- Bulk import için CSV parser

**QR Sistem:**
- Her parça için benzersiz QR kod
- QR okuyunca direkt stok güncelleme modal'ı açılıyor
''',
    results: '''
- 500+ komponent, 50+ kategori yönetiliyor
- Parça bulma süresi: ~2dk → ~5sn
- Stok doğruluğu: %95+ (önceden ~%70)
- 3 kullanıcı aktif (eş zamanlı sync)
''',
    lessonsLearned: '''
**İyi kararlar:**
- Offline-first yaklaşım atölyede WiFi olmadığında çok işe yaradı
- QR kod boyutu optimizasyonu (küçük etiketlere sığması için)

**Zorluklar:**
- Firebase fiyatlandırması scale olunca artıyor - self-hosted alternatif düşünülebilir
- QR yazıcı entegrasyonu beklenenden karmaşıktı

**Gelecek:**
- Otomatik sipariş önerisi (ML ile tüketim tahmini)
- BOM entegrasyonu (proje bazlı parça rezervasyonu)
''',
    technologies: ['Flutter', 'Firebase', 'Dart', 'Cloud Functions', 'Hive'],
    githubUrl: 'https://github.com/example/parts-inventory',
    demoUrl: 'https://inventory.example.com',
  ),
];

/// Beceri verileri.
/// 
/// Hakkımda sayfasındaki "Teknik Beceriler" bölümünde gösterilir.
/// Beceriler kategorilere göre gruplandırılarak listelenir.
/// 
/// Her beceri için:
/// - [name]: Beceri adı
/// - [description]: Kısa açıklama (tooltip olarak gösterilir)
/// - [category]: Hangi kategoriye ait
/// - [proficiencyPercent]: Yeterlilik yüzdesi (0-100)
final List<Skill> skills = [
  // Elektronik
  const Skill(
    name: 'PCB Tasarımı',
    description: 'KiCad, Altium Designer ile şematik ve layout',
    category: ProjectCategory.electronics,
    proficiencyPercent: 85,
  ),
  const Skill(
    name: 'Mikrodenetleyiciler',
    description: 'STM32, ESP32, AVR, PIC programlama',
    category: ProjectCategory.electronics,
    proficiencyPercent: 90,
  ),
  const Skill(
    name: 'Analog Tasarım',
    description: 'Op-amp devreleri, güç elektroniği, sensör arayüzleri',
    category: ProjectCategory.electronics,
    proficiencyPercent: 75,
  ),
  
  // Mekanik
  const Skill(
    name: '3D Modelleme',
    description: 'Fusion 360, SolidWorks ile mekanik tasarım',
    category: ProjectCategory.mechanical,
    proficiencyPercent: 80,
  ),
  const Skill(
    name: 'CNC & 3D Baskı',
    description: 'G-code, CAM, FDM/SLA prototipleme',
    category: ProjectCategory.mechanical,
    proficiencyPercent: 85,
  ),
  const Skill(
    name: 'Mekanik Sistemler',
    description: 'Lineer hareket, aktüatörler, mekanizma tasarımı',
    category: ProjectCategory.mechanical,
    proficiencyPercent: 70,
  ),
  
  // Yazılım
  const Skill(
    name: 'Gömülü Yazılım',
    description: 'C/C++, FreeRTOS, bare-metal programlama',
    category: ProjectCategory.software,
    proficiencyPercent: 90,
  ),
  const Skill(
    name: 'Mobil Geliştirme',
    description: 'Flutter, Dart ile cross-platform uygulamalar',
    category: ProjectCategory.software,
    proficiencyPercent: 85,
  ),
  const Skill(
    name: 'Backend & DevOps',
    description: 'Node.js, Python, Docker, CI/CD',
    category: ProjectCategory.software,
    proficiencyPercent: 75,
  ),
];
