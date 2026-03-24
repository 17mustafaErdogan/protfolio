import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Cihaz tipi enumeration'ı.
/// 
/// Ekran genişliğine göre belirlenen cihaz kategorileri.
/// Responsive layout kararları için kullanılır.
enum DeviceType { 
  /// Mobil cihazlar (< 600px)
  mobile, 
  
  /// Tablet cihazlar (600px - 900px)
  tablet, 
  
  /// Masaüstü (900px - 1200px)
  desktop, 
  
  /// Geniş ekranlar (> 1440px)
  wide 
}

/// Responsive tasarım için yardımcı metotlar sağlayan sınıf.
/// 
/// Bu sınıf, ekran boyutuna göre layout kararları almak için
/// statik metotlar içerir. Tüm metotlar BuildContext gerektirir.
/// 
/// Örnek kullanım:
/// ```dart
/// if (Responsive.isMobile(context)) {
///   // Mobil layout
/// } else {
///   // Masaüstü layout
/// }
/// ```
class Responsive {
  /// Mevcut ekran genişliğine göre cihaz tipini belirler.
  /// 
  /// [context] - Ekran boyutu bilgisini almak için gerekli
  /// 
  /// Döndürür: [DeviceType] enum değeri
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < Breakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < Breakpoints.tablet) {
      return DeviceType.tablet;
    } else if (width < Breakpoints.desktop) {
      return DeviceType.desktop;
    } else {
      return DeviceType.wide;
    }
  }
  
  /// Ekran mobil boyutunda mı kontrol eder.
  /// 
  /// Döndürür: Ekran genişliği < 600px ise true
  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width < Breakpoints.mobile;
  
  /// Ekran tablet boyutunda mı kontrol eder.
  /// 
  /// Döndürür: Ekran genişliği 600px-900px arasında ise true
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= Breakpoints.mobile &&
      MediaQuery.of(context).size.width < Breakpoints.tablet;
  
  /// Ekran masaüstü boyutunda veya daha büyük mü kontrol eder.
  /// 
  /// Döndürür: Ekran genişliği >= 900px ise true
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= Breakpoints.tablet;
  
  /// Ekran geniş ekran boyutunda mı kontrol eder.
  /// 
  /// Döndürür: Ekran genişliği >= 1440px ise true
  static bool isWide(BuildContext context) => 
      MediaQuery.of(context).size.width >= Breakpoints.wide;

  /// Ekran boyutuna göre uygun içerik padding değerini döndürür.
  /// 
  /// Küçük ekranlarda az, büyük ekranlarda fazla padding kullanılır.
  /// 
  /// Döndürür:
  /// - Mobil: 16px
  /// - Tablet: 24px
  /// - Masaüstü: 32px
  /// - Geniş: 48px
  static double contentPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < Breakpoints.mobile) return Spacing.md;
    if (width < Breakpoints.tablet) return Spacing.lg;
    if (width < Breakpoints.desktop) return Spacing.xl;
    return Spacing.xxl;
  }
  
  /// Ekran boyutuna göre grid sütun sayısını döndürür.
  /// 
  /// Proje kartları gibi grid layout'lar için kullanılır.
  /// 
  /// Döndürür:
  /// - Mobil: 1 sütun
  /// - Tablet: 2 sütun
  /// - Masaüstü+: 3 sütun
  static int gridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < Breakpoints.mobile) return 1;
    if (width < Breakpoints.tablet) return 2;
    return 3;
  }

  /// Bölümler arası dikey boşluğu ekran boyutuna göre ölçekler.
  static double sectionPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < Breakpoints.mobile) return 48;
    if (width < Breakpoints.tablet) return 64;
    return Spacing.sectionPadding;
  }

  /// Küçük ekranlarda başlık/body fontlarını kontrollü ölçeklemek için.
  static double adaptiveFontSize(
    BuildContext context, {
    required double min,
    required double max,
  }) {
    final width = MediaQuery.of(context).size.width;
    final normalized = ((width - 320) / (1200 - 320)).clamp(0.0, 1.0);
    return min + (max - min) * normalized;
  }
}

/// Cihaz tipine göre farklı widget'lar oluşturmak için builder widget.
/// 
/// LayoutBuilder ile sarılmış olup, ekran boyutu değiştiğinde
/// otomatik olarak yeniden build edilir.
/// 
/// Örnek kullanım:
/// ```dart
/// ResponsiveBuilder(
///   builder: (context, deviceType) {
///     if (deviceType == DeviceType.mobile) {
///       return MobileLayout();
///     }
///     return DesktopLayout();
///   },
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  /// Cihaz tipine göre widget oluşturan builder fonksiyonu
  final Widget Function(BuildContext context, DeviceType deviceType) builder;
  
  /// Yeni bir ResponsiveBuilder oluşturur.
  /// 
  /// [builder] - Cihaz tipine göre widget döndüren fonksiyon
  const ResponsiveBuilder({super.key, required this.builder});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, Responsive.getDeviceType(context));
      },
    );
  }
}

/// İçeriği ortalayan ve maksimum genişlik sınırlayan container widget.
/// 
/// Geniş ekranlarda içeriğin çok yayılmasını önler ve
/// tutarlı bir okuma deneyimi sağlar.
/// 
/// Varsayılan maksimum genişlik: 1200px
/// 
/// Örnek kullanım:
/// ```dart
/// ContentContainer(
///   child: Column(
///     children: [...],
///   ),
/// )
/// ```
class ContentContainer extends StatelessWidget {
  /// Container içinde gösterilecek widget
  final Widget child;
  
  /// Maksimum genişlik (varsayılan: 1200px)
  final double? maxWidth;
  
  /// Özel padding değeri
  final EdgeInsetsGeometry? padding;
  
  /// Yeni bir ContentContainer oluşturur.
  /// 
  /// [child] - İçerik widget'ı (zorunlu)
  /// [maxWidth] - Maksimum genişlik (opsiyonel)
  /// [padding] - Özel padding (opsiyonel, varsayılan: ekran boyutuna göre)
  const ContentContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Spacing.contentMaxWidth,
        ),
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: Responsive.contentPadding(context),
        ),
        child: child,
      ),
    );
  }
}
