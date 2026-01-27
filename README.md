# Mühendislik Portföy Sitesi

Elektronik, mekanik ve yazılım projelerini profesyonel bir şekilde sergileyen kişisel kariyer portföy web sitesi. İş verenler ve potansiyel ortaklar için kapsamlı bir tanıtım platformu.

## İçindekiler

- [Proje Hakkında](#proje-hakkında)
- [Mimari Genel Bakış](#mimari-genel-bakış)
- [Klasör Yapısı](#klasör-yapısı)
- [Sınıf Referansı](#sınıf-referansı)
- [Sayfa Akışı](#sayfa-akışı)
- [Kurulum](#kurulum)
- [Supabase Kurulumu](#supabase-kurulumu)
- [Admin Paneli](#admin-paneli)
- [CV Bilgilerini Düzenleme](#cv-bilgilerini-düzenleme)
- [Özelleştirme](#özelleştirme)

---

## Proje Hakkında

Bu portföy sitesi, mühendislik projelerini **problem → yaklaşım → uygulama → sonuç → öğrenilenler** formatında dokümante etmek ve kariyer bilgilerinizi (CV) profesyonelce sergilemek için tasarlanmıştır.

### Özellikler

- **Proje Odaklı**: 5 bölümlü detaylı dokümantasyon şablonu
- **Dinamik CV**: Eğitim, sertifika, deneyim, dil ve daha fazlası
- **Responsive**: Mobil, tablet ve masaüstü uyumlu
- **Minimal Tasarım**: GitHub-benzeri koyu tema
- **Admin Paneli**: Supabase entegreli tam yönetim arayüzü
- **Gerçek Zamanlı**: Tüm veriler Supabase'den dinamik olarak çekilir
- **Korumalı Erişim**: Authentication ile güvenli admin paneli
- **Akıllı Görünürlük**: Boş CV bölümleri otomatik gizlenir

---

## Mimari Genel Bakış

```
┌─────────────────────────────────────────────────────────────────┐
│                        MaterialApp.router                        │
│                              │                                   │
│                    MultiProvider (AuthService, DataService)      │
│                              │                                   │
│                         GoRouter                                 │
│                              │                                   │
│    ┌─────────────┬───────────┴───────────┬────────────────┐     │
│    │             │                       │                │     │
│    ▼             ▼                       ▼                ▼     │
│ ┌──────┐   ┌──────────┐           ┌───────────┐    ┌──────────┐│
│ │Login │   │ShellRoute│           │AdminShell │    │ Protected││
│ │Screen│   │(NavBar+  │           │(Sidebar+  │    │  Routes  ││
│ │      │   │ Footer)  │           │ Content)  │    │          ││
│ └──────┘   └──────────┘           └───────────┘    └──────────┘│
└─────────────────────────────────────────────────────────────────┘
```

### Veri Akışı

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   Supabase DB    │────▶│   DataService    │────▶│     Widgets      │
│                  │     │                  │     │                  │
│  - personal_info │     │  - getProjects() │     │  - HeroSection   │
│  - projects      │     │  - getSkills()   │     │  - ProjectCard   │
│  - skills        │     │  - getEducation()│     │  - SkillsSection │
│  - education     │     │  - CRUD methods  │     │  - CVSections    │
│  - certificates  │     │                  │     │                  │
│  - work_experience│    │                  │     │                  │
│  - languages     │     │                  │     │                  │
│  - achievements  │     │                  │     │                  │
│  - publications  │     │                  │     │                  │
│  - stats         │     │                  │     │                  │
└──────────────────┘     └──────────────────┘     └──────────────────┘
```

---

## Klasör Yapısı

```
lib/
├── main.dart                      # Uygulama giriş noktası + Provider'lar
│
├── config/                        # YAPILANDIRMA
│   ├── theme.dart                 #    Renk paleti, tipografi, widget temaları
│   └── routes.dart                #    Sayfa yönlendirmeleri (go_router)
│
├── services/                      # SERVİSLER (YENİ)
│   ├── auth_service.dart          #    Supabase authentication
│   └── data_service.dart          #    Supabase CRUD işlemleri
│
├── models/                        # VERİ MODELLERİ
│   ├── project.dart               #    Project, Skill sınıfları ve enum'lar
│   └── cv_models.dart             #    CV modelleri (Education, Certificate, vb.)
│
├── data/                          # STATIK VERİ (fallback)
│   ├── projects_data.dart         #    Proje ve beceri verileri
│   └── cv_data.dart               #    CV verileri
│
├── utils/                         # YARDIMCI ARAÇLAR
│   └── responsive.dart            #    Ekran boyutu yardımcıları
│
├── screens/                       # SAYFALAR
│   ├── home_screen.dart           #    Ana sayfa (CV bölümleri dahil)
│   ├── projects_screen.dart       #    Proje listesi
│   ├── project_detail_screen.dart #    Proje detayı
│   ├── about_screen.dart          #    Hakkımda
│   ├── contact_screen.dart        #    İletişim
│   ├── login_screen.dart          #    Admin giriş sayfası
│   │
│   └── admin/                     #    ADMIN PANELİ (YENİ)
│       ├── admin_shell.dart       #    Admin layout (sidebar + content)
│       ├── dashboard_screen.dart  #    Özet istatistikler
│       ├── projects_admin.dart    #    Proje listesi + CRUD
│       ├── project_edit_screen.dart#   Proje ekleme/düzenleme formu
│       ├── skills_admin.dart      #    Beceri yönetimi
│       ├── cv_admin.dart          #    CV bölümleri yönetimi (tab yapısı)
│       └── settings_admin.dart    #    Kişisel bilgiler
│
└── widgets/                       # YENİDEN KULLANILABİLİR BİLEŞENLER
    ├── common/                    #    Ortak bileşenler
    │   ├── shell_scaffold.dart    #    Sayfa iskeleti (NavBar + Footer)
    │   ├── nav_bar.dart           #    Üst navigasyon
    │   ├── footer.dart            #    Alt bilgi + gizli admin tetikleyici
    │   └── section_title.dart     #    Bölüm başlığı
    │
    ├── home/                      #    Ana sayfa bileşenleri
    │   ├── hero_section.dart      #    Tanıtım alanı (Supabase'den veri)
    │   ├── featured_projects.dart #    Öne çıkan projeler (Supabase'den veri)
    │   └── skills_section.dart    #    Beceri alanları (Supabase'den veri)
    │
    ├── projects/                  #    Proje bileşenleri
    │   ├── project_card.dart      #    Proje kartı
    │   └── project_filter.dart    #    Kategori filtresi
    │
    └── cv/                        #    CV bileşenleri
        ├── education_section.dart     #    Eğitim kartları
        ├── certificates_section.dart  #    Sertifika listesi
        ├── work_experience_section.dart#   İş deneyimi timeline
        ├── achievements_section.dart  #    Başarı kartları
        ├── languages_section.dart     #    Dil seviyeleri
        ├── publications_section.dart  #    Yayın listesi
        └── references_section.dart    #    Referanslar
```

---

## Sınıf Referansı

### Servisler (services/)

| Dosya | Sınıf | Amaç |
|-------|-------|------|
| `auth_service.dart` | `AuthService` | Supabase auth işlemleri (login, logout, state) |
| `data_service.dart` | `DataService` | Tüm CRUD işlemleri (projeler, beceriler, CV, vb.) |

### Admin Ekranları (screens/admin/)

| Dosya | Sınıf | Amaç |
|-------|-------|------|
| `admin_shell.dart` | `AdminShell` | Admin layout - sidebar + içerik alanı |
| `dashboard_screen.dart` | `DashboardScreen` | Özet istatistikler, hızlı erişim |
| `projects_admin.dart` | `ProjectsAdminScreen` | Proje listesi ve CRUD |
| `project_edit_screen.dart` | `ProjectEditScreen` | Proje ekleme/düzenleme formu |
| `skills_admin.dart` | `SkillsAdminScreen` | Beceri yönetimi |
| `cv_admin.dart` | `CVAdminScreen` | CV yönetimi (tab yapısında) |
| `settings_admin.dart` | `SettingsAdminScreen` | Kişisel bilgiler düzenleme |

---

## Sayfa Akışı

```
                              ┌─────────────┐
                              │  Ana Sayfa  │
                              │     (/)     │
                              └──────┬──────┘
                                     │
         ┌───────────────────────────┼───────────────────────────┐
         │                           │                           │
         ▼                           ▼                           ▼
  ┌─────────────┐            ┌─────────────┐            ┌─────────────┐
  │  Projeler   │            │  Hakkımda   │            │   İletişim  │
  │ (/projects) │            │  (/about)   │            │  (/contact) │
  └──────┬──────┘            └─────────────┘            └─────────────┘
         │
         ▼
  ┌─────────────┐
  │ Proje Detay │
  │(/projects/:id)│
  └─────────────┘
  
  
  ┌─────────────┐                    ┌─────────────────────────────────┐
  │   Giriş     │  ────────────────▶ │         Admin Paneli            │
  │  (/login)   │    (auth sonrası)  │                                 │
  └─────────────┘                    │  /admin          - Dashboard    │
        ▲                            │  /admin/projects - Projeler     │
        │                            │  /admin/skills   - Beceriler    │
  Footer'da 7x                       │  /admin/cv       - CV Bilgileri │
  hızlı tıklama                      │  /admin/settings - Ayarlar      │
                                     └─────────────────────────────────┘
```

---

## Kurulum

### Gereksinimler

- Flutter SDK 3.6.1+
- Dart SDK 3.6.1+
- Supabase hesabı

### Adımlar

```bash
# 1. Bağımlılıkları yükle
flutter pub get

# 2. Web sunucusunu başlat
flutter run -d web-server --web-port=8080

# 3. Tarayıcıda aç
# http://localhost:8080
```

### Production Build

```bash
flutter build web --release
# Çıktı: build/web/
```

---

## Supabase Kurulumu

### 1. Supabase Projesi Oluşturma

1. [supabase.com](https://supabase.com) adresine gidin
2. Yeni proje oluşturun
3. Project URL ve anon key'i kopyalayın

### 2. Veritabanı Tablolarını Oluşturma

Projede bulunan `supabase_schema.sql` dosyasını Supabase Dashboard > SQL Editor'da çalıştırın:

```sql
-- Tüm tablolar ve RLS politikaları otomatik oluşturulacak:
-- personal_info, projects, skills, education, certificates, 
-- work_experience, languages, achievements, publications, stats
```

### 3. Authentication Kullanıcısı Oluşturma

Supabase Dashboard > Authentication > Users:
1. "Add user" > "Create new user"
2. Email ve şifre belirleyin
3. Bu bilgilerle `/login` sayfasından giriş yapabilirsiniz

### 4. Flutter Projesini Yapılandırma

`lib/main.dart` dosyasında:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);
```

---

## Admin Paneli

### Giriş Yöntemi

Admin paneline iki şekilde erişebilirsiniz:

1. **URL ile**: Tarayıcıda `/login` adresine gidin
2. **Gizli Tetikleyici**: Footer'daki telif hakkı metnine 7 kez hızlıca tıklayın

### Admin Özellikleri

#### Dashboard (`/admin`)
- Toplam proje, beceri, eğitim ve deneyim sayıları
- Hızlı erişim butonları

#### Proje Yönetimi (`/admin/projects`)
- Tüm projeleri listele
- Yeni proje ekle
- Mevcut projeleri düzenle/sil
- Kategori ve öne çıkan filtresi

#### Beceri Yönetimi (`/admin/skills`)
- Kategoriye göre beceriler
- Yeterlilik yüzdesi ayarlama
- Ekleme/düzenleme/silme

#### CV Yönetimi (`/admin/cv`)
Tab yapısında:
- Eğitim bilgileri
- Sertifikalar
- İş deneyimi
- Diller
- Başarılar

#### Ayarlar (`/admin/settings`)
- Kişisel bilgiler (isim, ünvan, bio)
- İletişim bilgileri
- Sosyal medya linkleri
- İstatistikler (proje sayısı, yıl deneyim)

---

## CV Bilgilerini Düzenleme

### Admin Paneli Üzerinden (Önerilen)

1. `/login` sayfasından giriş yapın
2. `/admin/cv` sayfasına gidin
3. İlgili sekmeyi seçin (Eğitim, Sertifikalar, vb.)
4. "Ekle" butonuna tıklayın veya mevcut kaydı düzenleyin

### Supabase Dashboard Üzerinden

1. Supabase Dashboard > Table Editor
2. İlgili tabloyu seçin (education, certificates, vb.)
3. Yeni satır ekleyin veya mevcut satırı düzenleyin

---

## Özelleştirme

### Tema Değiştirme

`lib/config/theme.dart` dosyasında:

```dart
// Renkleri değiştir
static const Color accent = Color(0xFF58A6FF);      // Ana vurgu rengi
static const Color electronics = Color(0xFF58A6FF); // Elektronik kategorisi
static const Color mechanical = Color(0xFFFF7B72);  // Mekanik kategorisi
static const Color software = Color(0xFF7EE787);    // Yazılım kategorisi

// Fontları değiştir
GoogleFonts.jetBrainsMono(...)  // Başlık fontu
GoogleFonts.sourceSans3(...)    // Gövde fontu
```

### Yeni Kategori Ekleme

1. `lib/models/project.dart` dosyasında `ProjectCategory` enum'una ekle
2. `lib/config/theme.dart` dosyasında renk tanımla
3. Supabase'de ilgili tablo check constraint'ini güncelle

---

## Teknoloji Stack

| Katman | Teknoloji | Versiyon |
|--------|-----------|----------|
| Framework | Flutter Web | 3.6.1+ |
| State Management | Provider | 6.1.0 |
| Routing | go_router | 14.0.0 |
| Backend | Supabase | - |
| Database | PostgreSQL | - |
| Fonts | google_fonts | 6.2.0 |

---

## Lisans

MIT License

---

*Bu portföy, [Flutter](https://flutter.dev) ve [Supabase](https://supabase.com) ile geliştirilmiştir.*
