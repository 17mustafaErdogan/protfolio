# Widget Envanteri

Tüm yeniden kullanılabilir bileşenler `lib/widgets/` altındadır.
Dört alt klasöre ayrılır: `common`, `home`, `projects`, `cv`.

---

## `widgets/common/` — Paylaşılan Bileşenler

| Dosya | Widget | Açıklama |
|-------|--------|----------|
| `shell_scaffold.dart` | `ShellScaffold` | Public sayfaların layout sarmalayıcısı. `NavBar` + `child` + `Footer`'ı dikey olarak sıralar |
| `nav_bar.dart` | `NavBar` | Üst navigasyon çubuğu. Logo, rota linkleri, aktif rota vurgulama |
| `footer.dart` | `Footer` | Alt bilgi. Telif hakkı metni + sosyal medya linkleri. Metne 7 kez hızlı tıklama `/login`'e yönlendirir |
| `section_title.dart` | `SectionTitle` | Bölüm başlığı — üst metin (etiket) + alt büyük başlık kombinasyonu |

### `ShellScaffold` Kullanımı

`GoRouter` içindeki `ShellRoute` tarafından otomatik çağrılır. Ekranlarda manuel kullanım gerekmez:

```dart
// routes.dart
ShellRoute(
  builder: (context, state, child) => ShellScaffold(child: child),
  routes: [ ... ],
)
```

---

## `widgets/home/` — Ana Sayfa Bileşenleri

`HomeScreen` bu widget'ları sırayla içerir: `HeroSection` → `FeaturedProjects` → `SkillsSection`.

| Dosya | Widget | Açıklama |
|-------|--------|----------|
| `hero_section.dart` | `HeroSection` | Tanıtım bölümünün ana koordinatörü. Alt bileşenleri bir araya getirir, `DataService.getAutoStats()` çağırır |
| `hero_greeting.dart` | `HeroGreeting` | Selamlama metni ("Merhaba, ben...") |
| `hero_bio_text.dart` | `HeroBioText` | Kısa biyografi / ünvan metni |
| `hero_cta_buttons.dart` | `HeroCtaButtons` | "Projelerimi Gör" ve "İletişime Geç" butonları |
| `hero_specialties_row.dart` | `HeroSpecialtiesRow` | Uzmanlık alanları chip/etiket satırı |
| `hero_stats_row.dart` | `HeroStatsRow` | Proje sayısı ve deneyim yılı istatistik kartları |
| `hero_window_chrome.dart` | `HeroWindowChrome` | Kod editörü görünümündeki dekoratif pencere çerçevesi |
| `featured_projects.dart` | `FeaturedProjects` | `DataService.getProjects(featured: true)` ile en fazla 3 proje gösterir |
| `skills_section.dart` | `SkillsSection` | `DataService.getSkills()` ile beceri kategorileri ve yeterlilik çubukları |

---

## `widgets/projects/` — Proje Bileşenleri

`ProjectsScreen` tarafından kullanılır.

| Dosya | Widget | Açıklama |
|-------|--------|----------|
| `project_card.dart` | `ProjectCard` | Tek proje kartı — başlık, kategori rozeti, kısa açıklama, detay linki |
| `project_filter.dart` | `ProjectFilter` | Kategori filtre butonları (`ProjectCategory` enum'una göre) |

---

## `widgets/cv/` — CV Bileşenleri

`ProfileScreen` tarafından kullanılır. Her widget ilgili `DataService` metodunu çağırır
ve boş liste durumunda otomatik gizlenir.

| Dosya | Widget | Veri Kaynağı |
|-------|--------|--------------|
| `education_section.dart` | `EducationSection` | `DataService.getEducationItems()` |
| `certificates_section.dart` | `CertificatesSection` | `DataService.getCertificateItems()` |
| `work_experience_section.dart` | `WorkExperienceSection` | `DataService.getWorkExperienceItems()` |
| `languages_section.dart` | `LanguagesSection` | `DataService.getLanguageItems()` |
| `achievements_section.dart` | `AchievementsSection` | `DataService.getAchievementItems()` |
| `publications_section.dart` | `PublicationsSection` | `DataService.getPublicationItems()` |
| `references_section.dart` | `ReferencesSection` | `DataService.getReferenceItems()` |

---

## Tema ve Spacing

Tüm widget'lar `lib/config/theme.dart` içindeki sabitlerden renk ve boşluk alır:

```dart
AppTheme.background    // Sayfa arka planı
AppTheme.surface       // Kart / konteyner arka planı
AppTheme.accent        // Ana vurgu rengi (mavi)
AppTheme.textPrimary   // Birincil metin
AppTheme.textSecondary // İkincil metin
AppTheme.textMuted     // Soluk metin

Spacing.xs    // 4.0
Spacing.sm    // 8.0
Spacing.md    // 16.0
Spacing.lg    // 24.0
Spacing.xl    // 32.0
Spacing.xxl   // 48.0
Spacing.sectionPadding  // Bölümler arası boşluk
```

---

## Responsive Yardımcılar (`lib/utils/responsive.dart`)

Breakpoint'lere göre layout kararları vermek için:

```dart
Responsive.isMobile(context)   // < 768px
Responsive.isTablet(context)   // 768–1199px
Responsive.isDesktop(context)  // >= 1200px
```
