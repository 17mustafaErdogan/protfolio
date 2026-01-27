import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uygulama genelinde kullanılan tema yapılandırması.
/// 
/// Bu sınıf, mühendislik portföyüne uygun minimal ve profesyonel
/// bir koyu tema tanımlar. GitHub'ın koyu temasından ilham alınmıştır.
/// 
/// Kullanım:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.darkTheme,
/// )
/// ```
class AppTheme {
  // ============================================================
  // RENK PALETİ
  // ============================================================
  
  /// Ana arka plan rengi - en koyu ton (#0D1117)
  /// Scaffold ve ana container'lar için kullanılır
  static const Color background = Color(0xFF0D1117);
  
  /// Yüzey rengi - kartlar ve elevated elementler için (#161B22)
  static const Color surface = Color(0xFF161B22);
  
  /// Açık yüzey rengi - hover durumları ve input alanları için (#21262D)
  static const Color surfaceLight = Color(0xFF21262D);
  
  /// Kenarlık rengi - tüm border ve divider'lar için (#30363D)
  static const Color border = Color(0xFF30363D);
  
  // ============================================================
  // METİN RENKLERİ
  // ============================================================
  
  /// Birincil metin rengi - başlıklar ve önemli içerik (#E6EDF3)
  static const Color textPrimary = Color(0xFFE6EDF3);
  
  /// İkincil metin rengi - gövde metinleri ve açıklamalar (#8B949E)
  static const Color textSecondary = Color(0xFF8B949E);
  
  /// Soluk metin rengi - etiketler ve yardımcı metinler (#6E7681)
  static const Color textMuted = Color(0xFF6E7681);
  
  // ============================================================
  // VURGU RENKLERİ
  // ============================================================
  
  /// Ana vurgu rengi - linkler ve birincil aksiyonlar (mavi)
  static const Color accent = Color(0xFF58A6FF);
  
  /// Başarı/pozitif durumlar için yeşil vurgu
  static const Color accentGreen = Color(0xFF3FB950);
  
  /// Uyarı ve dikkat çekici elementler için turuncu
  static const Color accentOrange = Color(0xFFD29922);
  
  /// Hata ve tehlike durumları için kırmızı
  static const Color accentRed = Color(0xFFF85149);
  
  // ============================================================
  // KATEGORİ RENKLERİ
  // Her proje kategorisinin kendine özgü rengi vardır
  // ============================================================
  
  /// Elektronik projeleri için mavi renk
  static const Color electronics = Color(0xFF58A6FF);
  
  /// Mekanik projeleri için turuncu renk
  static const Color mechanical = Color(0xFFD29922);
  
  /// Yazılım projeleri için yeşil renk
  static const Color software = Color(0xFF3FB950);

  /// Uygulamanın ana koyu temasını döndürür.
  /// 
  /// Bu tema:
  /// - Material 3 tasarım sistemini kullanır
  /// - JetBrains Mono (başlıklar) ve Source Sans 3 (gövde) fontlarını içerir
  /// - Tüm widget'lar için tutarlı stil tanımları sağlar
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      
      // Renk şeması tanımı
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: accent,
        secondary: accentGreen,
        error: accentRed,
        onSurface: textPrimary,
        onPrimary: background,
      ),
      
      // ============================================================
      // TİPOGRAFİ TANIMLARI
      // ============================================================
      textTheme: TextTheme(
        // Büyük başlıklar - Monospace font (JetBrains Mono)
        // Ana sayfa hero bölümü gibi büyük başlıklar için
        displayLarge: GoogleFonts.jetBrainsMono(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1,
        ),
        
        // Orta başlıklar - sayfa başlıkları için
        displayMedium: GoogleFonts.jetBrainsMono(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        
        // Küçük başlıklar - bölüm başlıkları için
        displaySmall: GoogleFonts.jetBrainsMono(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        
        // Headline stilleri - alt başlıklar için
        headlineLarge: GoogleFonts.jetBrainsMono(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.jetBrainsMono(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.jetBrainsMono(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        
        // Gövde metni stilleri - Sans-serif font (Source Sans 3)
        // Okunabilirlik için optimize edilmiş satır yüksekliği
        bodyLarge: GoogleFonts.sourceSans3(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.sourceSans3(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.6,
        ),
        bodySmall: GoogleFonts.sourceSans3(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textMuted,
          height: 1.5,
        ),
        
        // Etiket stilleri - butonlar, chip'ler, küçük metinler için
        labelLarge: GoogleFonts.jetBrainsMono(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textMuted,
          letterSpacing: 1,
        ),
      ),
      
      // ============================================================
      // WIDGET TEMA TANIMLARI
      // ============================================================
      
      /// AppBar teması - saydam, minimal tasarım
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.jetBrainsMono(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      
      /// Card teması - kenarlıklı, düz tasarım
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      
      /// ElevatedButton teması - vurgu renkli, belirgin
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      /// OutlinedButton teması - kenarlıklı, minimal
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          side: const BorderSide(color: border, width: 1),
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      /// Divider teması
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      
      /// Chip teması - etiketler ve filtreler için
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        labelStyle: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        side: const BorderSide(color: border, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

/// Responsive tasarım için ekran genişliği kırılma noktaları.
/// 
/// Bu değerler, farklı cihaz boyutlarına göre layout değişiklikleri
/// yapmak için kullanılır.
/// 
/// Örnek kullanım:
/// ```dart
/// if (screenWidth < Breakpoints.mobile) {
///   // Mobil layout
/// }
/// ```
class Breakpoints {
  /// Mobil cihazlar için maksimum genişlik (600px altı)
  static const double mobile = 600;
  
  /// Tablet cihazlar için maksimum genişlik (900px altı)
  static const double tablet = 900;
  
  /// Masaüstü için maksimum genişlik (1200px altı)
  static const double desktop = 1200;
  
  /// Geniş ekranlar için minimum genişlik (1440px ve üstü)
  static const double wide = 1440;
}

/// Uygulama genelinde tutarlı boşluk değerleri.
/// 
/// Bu sabitleri kullanarak tasarımda tutarlılık sağlanır.
/// 4px'lik bir grid sistemine dayanır.
/// 
/// Örnek kullanım:
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(Spacing.md),
///   child: ...
/// )
/// ```
class Spacing {
  /// Ekstra küçük boşluk: 4px
  static const double xs = 4;
  
  /// Küçük boşluk: 8px
  static const double sm = 8;
  
  /// Orta boşluk: 16px - varsayılan padding
  static const double md = 16;
  
  /// Büyük boşluk: 24px
  static const double lg = 24;
  
  /// Ekstra büyük boşluk: 32px
  static const double xl = 32;
  
  /// 2x ekstra büyük boşluk: 48px
  static const double xxl = 48;
  
  /// 3x ekstra büyük boşluk: 64px
  static const double xxxl = 64;
  
  /// Bölümler arası dikey boşluk: 80px
  static const double sectionPadding = 80;
  
  /// İçerik alanının maksimum genişliği: 1200px
  static const double contentMaxWidth = 1200;
}
