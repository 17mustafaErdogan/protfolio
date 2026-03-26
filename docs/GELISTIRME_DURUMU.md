# Portföy Projesi – Geliştirme Planı ve Durum Takibi

Bu dosya, portföy projesinin genel geliştirme planını, işlerin nasıl ilerlediğini ve tamamlanan/adım adım yapılan işleri takip etmek için kullanılır.

---

## Genel Bakış

Flutter tabanlı portföy uygulaması; Supabase backend, admin paneli ve public sayfalar içerir.

---

## Özet Tablo

| Kategori | Öğe | Öncelik | Durum |
|----------|-----|---------|-------|
| Güvenlik | Supabase keys → env | Yüksek | ✅ Tamamlandı |
| Auth | Router refreshListenable → AuthService | Yüksek | ✅ Tamamlandı |
| Referanslar | Model, DataService CRUD, CVAdmin tab, ProfileScreen | Orta | ✅ Tamamlandı |
| Yayınlar | CVAdmin Publications tab | Orta | ✅ Tamamlandı |
| İletişim | personal_info entegrasyonu, form backend | Orta | ✅ Tamamlandı |
| İletişim | Admin mesaj kutusu (contact_messages tablosu) | Orta | ✅ Tamamlandı |
| Müsaitlik | personal_info'dan dinamik, admin toggle | Orta | ✅ Tamamlandı |
| Email validasyonu | İletişim formu email format kontrolü | Orta | ✅ Tamamlandı |
| Sosyal linkler | Twitter/X ve website footer/contact'ta gösterim | Düşük | ✅ Tamamlandı |
| 404 Sayfası | GoRouter errorBuilder | Düşük | ✅ Tamamlandı |
| CV PDF | Admin'den link, profil sayfasında indirme butonu | Düşük | ✅ Tamamlandı |
| SEO | index.html Open Graph + Twitter Card; canlıda `YOUR_DOMAIN` tam URL | Düşük | ✅ Tamamlandı |
| Kod kalitesi | url_launch_utils.dart → open_url.dart ile birleştirildi | Düşük | ✅ Tamamlandı |
| Kod kalitesi | Ölü veri dosyaları (projects_data, cv_data) kaldırıldı | Düşük | ✅ Tamamlandı |
| DB | personal_info tek satır (unique ifade indeksi) | Düşük | ✅ Tamamlandı (`supabase_schema.sql`) |
| DB | `stats` tablosu kaldırıldı; istatistikler `getAutoStats()` ile dinamik | Düşük | ✅ Tamamlandı |
| Test | Rota sabitleri + MaterialApp smoke | Düşük | ✅ Tamamlandı |
| Güvenlik | RLS yazma + mesaj yönetimi `auth.uid()` ile tek admin | Yüksek | ✅ Tamamlandı (`supabase_schema.sql`; UUID değiştirme zorunlu) |
| UX | `DataService` okuma hatalarında `_errorMessage`; `sendContactMessage` hata metni | Orta | ✅ Tamamlandı |
| Form | Ayarlar opsiyonel e-posta; CV/Beceri/Uzmanlık admin diyalogları `Form` + validate | Orta | ✅ Tamamlandı |
| Dokümantasyon | `.env.example` — dart-define / config.json (flutter_dotenv yok) | Düşük | ✅ Tamamlandı |

---

## Veritabanı (tek kaynak)

Tüm tablolar, `contact_messages`, `personal_info` genişletmeleri ve RLS politikaları için **[`supabase_schema.sql`](../supabase_schema.sql)** dosyasını Supabase SQL Editor'da çalıştırın. Ayrı migration parçalarını bu dosyadan kopyalamayın; güncel tanım buradadır.

> **Not:** `stats` tablosu kaldırıldı. İstatistikler artık dinamik hesaplanmaktadır: proje sayısı ve uzmanlık alanı bilgileri `getAutoStats()`, dashboard sayıları ise `getDashboardStats()` ile gerçek tablo satırları üzerinden elde edilir.

> **RLS:** Admin INSERT/UPDATE/DELETE ve `contact_messages` okuma/güncelleme/silme, şemada belirtilen tek `auth.users` UUID’sine bağlıdır. Scripti çalıştırmadan önce dosyada `00000000-0000-4000-8000-000000000001` değerini kendi admin kullanıcı UID’nizle değiştirin (Supabase Authentication > Users).

**Üretim SEO:** [`web/index.html`](../web/index.html) içinde `YOUR_DOMAIN` yerine canlı site kök URL’nizi yazın.

---

## Tamamlanan İşler

### 1. Güvenlik: Supabase Anahtarlarının Ortam Değişkenine Taşınması ✅

**Tarih:** 2025-03-16

**Yapılanlar:**
- `lib/config/env.dart` oluşturuldu – `String.fromEnvironment` ile okuma
- `lib/main.dart` güncellendi – anahtarlar artık `Env` üzerinden okunuyor
- `config.json.example` oluşturuldu – örnek konfigürasyon
- `config.json` `.gitignore`'a eklendi – hassas veriler Git'e eklenmez
- `.vscode/launch.json` güncellendi – `--dart-define-from-file=config.json` ile çalıştırma
- `.env.example` güncellendi – alternatif yöntem dokümantasyonu

**Kullanım:**
1. `config.json.example` dosyasını `config.json` olarak kopyalayın
2. `config.json` içindeki `SUPABASE_URL` ve `SUPABASE_ANON_KEY` değerlerini doldurun
3. Uygulamayı VS Code veya `flutter run --dart-define-from-file=config.json` ile çalıştırın

---

### 2. Router Auth Listenable – AuthService Bağlantısı ✅

`routes.dart` içinde `GoRouter(refreshListenable: authService)` ile AuthService login/logout akışı router'a bağlı.

---

### 3–4. Referanslar ve Yayınlar ✅

Model `fromMap`, DataService CRUD, CVAdmin sekmeleri ve ProfileScreen entegrasyonları tamamlandı.

---

### 5. İletişim Sayfası Tam Entegrasyon ✅

- İletişim bilgileri (email, GitHub, LinkedIn, Twitter, website) `personal_info`'dan dinamik yükleniyor
- Müsaitlik durumu ve metni admin panelinden yönetilebilir
- Mesaj formu Supabase `contact_messages` tablosuna kaydediyor
- Admin panelinde `/admin/messages` rotasında mesajlar görüntülenebilir, okunabilir, silinebilir
- Email alanı regex ile validate ediliyor

---

### 6. CV PDF İndirme ✅

Admin → Ayarlar → "İletişim Sayfası" bölümünden CV PDF linki (Google Drive, Dropbox vb.) girilir. Profil sayfasında "CV İndir" butonu görünür.

---

### 7. SEO Meta Tagları ✅

`web/index.html` güncellendi: Open Graph (Facebook, LinkedIn, WhatsApp) ve Twitter Card meta tagları eklendi.

---

## Bekleyen İşler

### İleride (isteğe bağlı)

- Entegrasyon testi (gerçek `PortfolioApp` + Supabase mock)
- `DataService` birim testleri (fake Postgrest istemcisi)

---

## Mimari Özeti

```
┌─────────────────────────────────────────────────────────────────┐
│                       Flutter Frontend                           │
│  ShellScaffold → Home, Projects, About, Profile, Contact        │
│  AdminShell → Dashboard, Projects, CV, Skills, Mesajlar, Ayarlar│
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  AuthService (Supabase Auth)  │  DataService (Supabase DB)      │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│                    Supabase (Backend)                            │
│  PostgreSQL + Row Level Security + Auth                         │
└─────────────────────────────────────────────────────────────────┘
```

---

*Son güncelleme: 2026-03-26*
