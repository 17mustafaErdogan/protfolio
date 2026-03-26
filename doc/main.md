# Uygulama Giriş Noktası — `lib/main.dart`

`main.dart` uygulamanın başlangıç noktasıdır. İki sorumluluk üstlenir:

1. **Altyapı başlatma** — Supabase SDK'sını, servis nesnelerini ve GoRouter'ı hazırlar.
2. **Widget ağacının kökü** — `PortfolioApp` widget'ı Provider ve MaterialApp.router'ı bir araya getirir.

---

## Başlatma Akışı

```
main()
 ├── WidgetsFlutterBinding.ensureInitialized()
 ├── Env.isSupabaseConfigured kontrolü  →  false ise FlutterError fırlatır
 ├── Supabase.initialize(url, anonKey)
 ├── AuthService()         (ChangeNotifier)
 ├── DataService()         (ChangeNotifier)
 ├── createRouter(authService)
 └── runApp(PortfolioApp)
```

`AuthService` ve `DataService`, `createRouter` çağrısından **önce** oluşturulur.
Router `refreshListenable: authService` ile dinleme başlar; login/logout sonrası
yönlendirme otomatik tetiklenir.

---

## Supabase Yapılandırması

Anahtarlar kaynak kodda tutulmaz; build zamanında `--dart-define` veya
`--dart-define-from-file` ile geçirilir.

```jsonc
// config.json (versiyon kontrolüne dahil edilmez)
{
  "SUPABASE_URL": "https://xxxx.supabase.co",
  "SUPABASE_ANON_KEY": "eyJhb..."
}
```

```bash
flutter run --dart-define-from-file=config.json
```

VS Code kullanıcıları için `.vscode/launch.json` bu yapılandırmayı hazır içerir.
`config.json` yoksa uygulama anlamlı bir hata mesajıyla durur.

---

## `PortfolioApp` Widget

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: authService),
    ChangeNotifierProvider.value(value: dataService),
  ],
  child: MaterialApp.router(
    theme: AppTheme.darkTheme,
    routerConfig: router,
  ),
)
```

- `AuthService` → kimlik doğrulama state'i; tüm ağaçtan `context.read<AuthService>()` ile erişilir.
- `DataService` → Supabase veri işlemleri; tüm ağaçtan `context.read<DataService>()` ile erişilir.
- `AppTheme.darkTheme` → `lib/config/theme.dart` içinde tanımlı koyu tema.
- `router` → `lib/config/routes.dart` içindeki `createRouter()` çıktısı.

---

## İlgili Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `lib/config/env.dart` | `SUPABASE_URL` / `SUPABASE_ANON_KEY` dart-define okuma |
| `lib/config/theme.dart` | Renk paleti, tipografi, widget temaları |
| `lib/config/routes.dart` | `AppRoutes` sabitleri + `createRouter()` |
| `lib/services/auth_service.dart` | Supabase authentication |
| `lib/services/data_service.dart` | Tüm CRUD işlemleri (repository facade) |
