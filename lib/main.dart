import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/auth_service.dart';
import 'services/data_service.dart';

/// Uygulama giriş noktası.
/// 
/// Supabase'i başlatır ve Provider'ları yapılandırır.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://BASE_YOUR_URL.supabase.co',
    anonKey: 'YOUR_KEY',
  );
  
  runApp(const PortfolioApp());
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
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication Service
        ChangeNotifierProvider(create: (_) => AuthService()),
        // Data Service
        ChangeNotifierProvider(create: (_) => DataService()),
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
