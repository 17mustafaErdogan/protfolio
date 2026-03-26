# Mimari Genel Bakış

## Katmanlar

```
┌───────────────────────────────────────────────────────┐
│                     Presentation                       │
│   screens/           widgets/           config/        │
│  (sayfalar)        (bileşenler)    (tema, rota)        │
├───────────────────────────────────────────────────────┤
│                    State / Service                     │
│         AuthService          DataService              │
│         (auth state)       (facade / ChangeNotifier)  │
├───────────────────────────────────────────────────────┤
│                     Repository                         │
│  ProjectRepo  SkillRepo  CvRepo  ExpertiseRepo  ...   │
│         (stateless, sadece Supabase çağrıları)        │
├───────────────────────────────────────────────────────┤
│                      Data / Backend                    │
│              Supabase (PostgreSQL + Auth)              │
└───────────────────────────────────────────────────────┘
```

---

## Widget Ağacı Özeti

```
MaterialApp.router
 └── MultiProvider (AuthService, DataService)
      └── GoRouter
           ├── ShellRoute  ─────────────────────────── public sayfalar
           │    └── ShellScaffold (NavBar + Footer)
           │         ├── HomeScreen
           │         ├── ProjectsScreen
           │         ├── ProjectDetailScreen
           │         ├── AboutScreen
           │         ├── ProfileScreen
           │         └── ContactScreen
           │
           ├── GoRoute /login  ─────────────────────── bağımsız
           │    └── LoginScreen
           │
           └── ShellRoute (korumalı)  ────────────────── admin
                └── AdminShell (sidebar + içerik)
                     ├── DashboardScreen
                     ├── ProjectsAdminScreen
                     ├── ProjectEditScreen
                     ├── SkillsAdminScreen
                     ├── ExpertiseAreasAdminScreen
                     ├── CVAdminScreen
                     ├── ContactMessagesAdminScreen
                     └── SettingsAdminScreen
```

---

## Routing Stratejisi (`lib/config/routes.dart`)

| Bileşen | Açıklama |
|---------|----------|
| `AppRoutes` | Tüm rota yollarını sabit string olarak tutar; yol adını her yerde tekrar yazmayı önler |
| `createRouter(AuthService)` | GoRouter fabrikası; `refreshListenable: authService` ile auth değişimlerini dinler |
| `ShellRoute` (public) | `ShellScaffold` ile sarar — NavBar ve Footer otomatik eklenir |
| `ShellRoute` (admin) | `AdminShell` ile sarar — sol kenar çubuğu ve içerik alanı |
| `_adminRedirect` | Her admin route için çalışır; oturum yoksa `/login`'e yönlendirir |
| `_NotFoundScreen` | Tanımsız rotalarda `errorBuilder` ile gösterilir |

---

## Veri Akışı

```
Supabase DB
    │
    ▼
Repository (stateless)
    │   project_repository.dart
    │   skill_repository.dart
    │   cv_repository.dart
    │   expertise_repository.dart
    │   contact_repository.dart
    │   personal_info_repository.dart
    │
    ▼
DataService (ChangeNotifier facade)
    │  - isLoading / errorMessage state
    │  - _runMutation() helper (yazma işlemleri için)
    │  - _notifyReadFailure() (okuma hataları için)
    │
    ▼
Provider (widget ağacında)
    │
    ▼
Widget / Screen
    context.read<DataService>().getProjects()
    context.watch<DataService>().isLoading
```

---

## Authentication Akışı (`lib/services/auth_service.dart`)

```
Kullanıcı /login'e gider
    │
    ▼
AuthService.signIn(email, password)
    │  Supabase.auth.signInWithPassword()
    │
    ├── Başarılı ──▶ onAuthStateChange tetiklenir
    │                AuthService.isLoggedIn = true
    │                notifyListeners()
    │                GoRouter refreshListenable tetiklenir
    │                _adminRedirect artık null döner ──▶ /admin açılır
    │
    └── Hata ──▶ AuthService.errorMessage dolar, LoginScreen gösterir
```

---

## Admin Erişimi

Admin paneline iki yol ile ulaşılır:

1. **URL**: `/login` adresine doğrudan git.
2. **Gizli tetikleyici**: Footer'daki telif hakkı metnine **7 kez hızlıca tıkla**.
   (`lib/widgets/common/footer.dart` → `_tapCount` sayacı)

---

## Dizin Haritası

```
lib/
├── main.dart                        # Giriş noktası
├── config/
│   ├── env.dart                     # dart-define anahtarları
│   ├── theme.dart                   # AppTheme, Spacing, renk sabitleri
│   └── routes.dart                  # AppRoutes, createRouter
├── models/
│   ├── project.dart                 # Project, Skill, ProjectCategory
│   └── cv_models.dart               # Education, Certificate, WorkExperience, …
├── services/
│   ├── auth_service.dart            # AuthService (ChangeNotifier)
│   ├── data_service.dart            # DataService (ChangeNotifier, facade)
│   └── repositories/
│       ├── project_repository.dart
│       ├── skill_repository.dart
│       ├── cv_repository.dart
│       ├── expertise_repository.dart
│       ├── contact_repository.dart
│       └── personal_info_repository.dart
├── utils/
│   ├── responsive.dart              # Breakpoint yardımcıları
│   ├── open_url.dart                # URL / mailto açma
│   └── form_validators.dart         # E-posta / URL doğrulama
├── screens/
│   ├── home_screen.dart
│   ├── projects_screen.dart
│   ├── project_detail_screen.dart
│   ├── about_screen.dart
│   ├── profile_screen.dart
│   ├── contact_screen.dart
│   ├── login_screen.dart
│   └── admin/                       # Korumalı admin ekranları
│       ├── admin_shell.dart
│       ├── dashboard_screen.dart
│       ├── projects_admin.dart
│       ├── project_edit_screen.dart
│       ├── skills_admin.dart
│       ├── expertise_areas_admin.dart
│       ├── cv_admin.dart
│       ├── contact_messages_admin.dart
│       └── settings_admin.dart
└── widgets/
    ├── common/                      # Paylaşılan bileşenler
    │   ├── shell_scaffold.dart      # NavBar + Footer sarmalayıcı
    │   ├── nav_bar.dart
    │   ├── footer.dart
    │   └── section_title.dart
    ├── home/                        # Ana sayfa bileşenleri
    │   ├── hero_section.dart
    │   ├── hero_greeting.dart
    │   ├── hero_bio_text.dart
    │   ├── hero_cta_buttons.dart
    │   ├── hero_specialties_row.dart
    │   ├── hero_stats_row.dart
    │   ├── hero_window_chrome.dart
    │   ├── featured_projects.dart
    │   └── skills_section.dart
    ├── projects/
    │   ├── project_card.dart
    │   └── project_filter.dart
    └── cv/
        ├── education_section.dart
        ├── certificates_section.dart
        ├── work_experience_section.dart
        ├── languages_section.dart
        ├── achievements_section.dart
        ├── publications_section.dart
        └── references_section.dart
```
