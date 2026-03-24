import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/env.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/auth_service.dart';
import 'services/data_service.dart';

/// Uygulama giriş noktası.
///
/// Supabase'i başlatır ve Provider'ları yapılandırır.
/// Supabase anahtarları ortam değişkenleri ile geçirilir (güvenlik).
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Env.isSupabaseConfigured) {
    throw FlutterError(
      'Supabase anahtarları tanımlı değil.\n\n'
      '1. config.json.example dosyasını config.json olarak kopyalayın\n'
      '2. config.json içindeki SUPABASE_URL ve SUPABASE_ANON_KEY değerlerini doldurun\n'
      '3. Uygulamayı tekrar çalıştırın (VS Code launch config config.json kullanır)\n\n'
      'Alternatif: flutter run --dart-define-from-file=config.json',
    );
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // AuthService ve DataService router'dan önce oluşturulmalı.
  // Router, login/logout sonrası yönlendirme için AuthService'i dinler.
  final authService = AuthService();
  final dataService = DataService();
  final router = createRouter(authService);

  runApp(PortfolioApp(
    authService: authService,
    dataService: dataService,
    router: router,
  ));
}

/// Portföy uygulamasının kök widget'ı.
/// 
/// Bu widget:
/// - Provider ile state management yapılandırır
/// - [AppTheme.darkTheme] ile koyu temayı uygular
/// - [router] ile go_router tabanlı navigasyonu yapılandırır
/// 
/// Tüm sayfa içerikleri [ShellScaffold] ile sarılır,
/// bu sayede NavBar ve Footer otomatik olarak her sayfada görünür.
class PortfolioApp extends StatelessWidget {
  const PortfolioApp({
    super.key,
    required this.authService,
    required this.dataService,
    required this.router,
  });

  final AuthService authService;
  final DataService dataService;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: dataService),
      ],
      child: MaterialApp.router(
        title: 'Mühendislik Portföyü',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: router,
      ),
    );
  }
}
