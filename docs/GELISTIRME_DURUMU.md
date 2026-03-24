# Portföy Projesi – Geliştirme Planı ve Durum Takibi

Bu dosya, portföy projesinin genel geliştirme planını, işlerin nasıl ilerlediğini ve tamamlanan/adım adım yapılan işleri takip etmek için kullanılır.

---

## Genel Bakış

Flutter tabanlı portföy uygulaması; Supabase backend, admin paneli ve public sayfalar içerir. Bu plan, eksik özelliklerin, güvenlik iyileştirmelerinin ve kalite artırımlarının öncelik sırasına göre uygulanmasını hedefler.

---

## Özet Tablo

| Kategori | Öğe | Öncelik | Durum |
|----------|-----|---------|-------|
| Güvenlik | Supabase keys → env | Yüksek | ✅ Tamamlandı |
| Auth | Router refreshListenable → AuthService | Yüksek | ✅ Tamamlandı |
| Referanslar | Model fromMap, DataService CRUD, CVAdmin tab, ProfileScreen | Orta | ✅ Tamamlandı |
| Yayınlar | CVAdmin Publications tab | Orta | ✅ Tamamlandı |
| İletişim | personal_info entegrasyonu, form backend | Orta | ⏳ Bekliyor |
| UX | url_launcher (sertifika, yayın linkleri) | Düşük | ⏳ Bekliyor |
| DB | personal_info/stats unique/upsert | Düşük | ⏳ Bekliyor |
| Test | Smoke test | Düşük | ⏳ Bekliyor |

---

## Uygulama Sırası Önerisi

1. **Kritik:** Supabase anahtarlarını ortam değişkenine taşı ✅
2. **Kritik:** Router auth listenable'ı AuthService ile bağla
3. **Özellik:** Referanslar CRUD + CVAdmin sekmesi + ProfileScreen
4. **Özellik:** CVAdmin Yayınlar sekmesi
5. **Özellik:** İletişim sayfası – personal_info entegrasyonu + form backend
6. **İyileştirme:** url_launcher entegrasyonu
7. **İyileştirme:** personal_info/stats schema düzeltmesi
8. **İyileştirme:** Widget test güncellemesi

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

## Bekleyen İşler (Detaylı)

### 2. Router Auth Listenable – AuthService Bağlantısı

**Sorun:** `routes.dart` içinde `refreshListenable` AuthService ile bağlı değil; login/logout sonrası yönlendirme gecikmeli olabilir.

**Çözüm:** GoRouter'a AuthService'in auth state değişimlerini dinleyen bir listenable ver.

---

### 3. Referanslar (User References) – Tam Entegrasyon

- `Reference.fromMap` eklenmeli
- DataService'e `getReferences`, `createReference`, `updateReference`, `deleteReference` eklenmeli
- CVAdmin'e "Referanslar" sekmesi eklenmeli
- ProfileScreen'e `ReferencesSection` entegre edilmeli

---

### 4. CVAdmin Yayınlar Sekmesi

- CVAdmin'de 6. tab olarak "Yayınlar" sekmesi eklenmeli
- DataService metotları zaten mevcut

---

### 5. İletişim Sayfası

- İletişim bilgileri `personal_info`'dan okunmalı (hardcoded değerler kaldırılmalı)
- Mesaj formu: Supabase tablosu veya e-posta ile backend entegrasyonu

---

### 6. url_launcher

- Sertifika ve yayın kartlarında URL varsa tıklanabilir link olarak `launchUrl` kullanılmalı

---

### 7. Veritabanı Schema Düzeltmeleri

- `personal_info` ve `stats` için tek satır garanti eden bir yapı (UPSERT/unique constraint)

---

### 8. Test

- `widget_test.dart` portföy uygulamasına uygun smoke test ile güncellenmeli

---

## Mimari Özeti

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Frontend                       │
│  ShellScaffold → HomeScreen, ProfileScreen, ContactScreen │
│  AdminShell → Dashboard, Projects, CV, Skills, Settings  │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│  AuthService (Supabase Auth)  │  DataService (Supabase DB) │
└─────────────────────────┬─────────────────────────────────┘
                          │
┌─────────────────────────▼─────────────────────────────────┐
│                    Supabase (Backend)                      │
│  PostgreSQL + Row Level Security + Auth                   │
└───────────────────────────────────────────────────────────┘
```

---

## Kaynak Plan Dosyası

Detaylı plan Cursor Plans içinde saklanır. Bu doküman planın özeti ve durum takibidir.

---

*Son güncelleme: 2025-03-16*
