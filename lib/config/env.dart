/// Ortam değişkenleri ve build-time konfigürasyon.
///
/// Supabase anahtarları `--dart-define` ile build sırasında geçirilir.
/// Bu sayede hassas bilgiler kaynak kodda tutulmaz.
///
/// Çalıştırma örneği:
/// ```bash
/// flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your_anon_key
/// ```
///
/// Veya `.env` dosyası oluşturup VS Code launch config ile kullanın.
class Env {
  Env._();

  /// Supabase proje URL'si.
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  /// Supabase anon (public) key.
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// Supabase bağlantı bilgilerinin tanımlı olup olmadığını kontrol eder.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
