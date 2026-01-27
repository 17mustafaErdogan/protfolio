/// Proje kategorilerini tanımlayan enum.
/// 
/// Her proje bu üç kategoriden birine ait olmalıdır.
/// Kategoriler, projelerin filtrelenmesi ve görsel ayrımı için kullanılır.
enum ProjectCategory {
  /// Elektronik projeleri: PCB tasarımı, devre, sensör, IoT vb.
  electronics,
  
  /// Mekanik projeler: CNC, 3D baskı, mekanizma tasarımı vb.
  mechanical,
  
  /// Yazılım projeleri: mobil, web, gömülü yazılım vb.
  software,
}

/// ProjectCategory enum'u için yardımcı extension metotları.
/// 
/// Kategorilerin Türkçe adlarını ve ikonlarını sağlar.
extension ProjectCategoryExtension on ProjectCategory {
  /// Kategorinin Türkçe görünen adını döndürür.
  /// 
  /// Örnek: ProjectCategory.electronics.displayName => 'Elektronik'
  String get displayName {
    switch (this) {
      case ProjectCategory.electronics:
        return 'Elektronik';
      case ProjectCategory.mechanical:
        return 'Mekanik';
      case ProjectCategory.software:
        return 'Yazılım';
    }
  }
  
  /// Kategorinin emoji ikonunu döndürür.
  /// 
  /// UI'da kategori gösteriminde kullanılır.
  String get icon {
    switch (this) {
      case ProjectCategory.electronics:
        return '⚡';
      case ProjectCategory.mechanical:
        return '⚙️';
      case ProjectCategory.software:
        return '💻';
    }
  }
}

/// Bir mühendislik projesini temsil eden veri modeli.
/// 
/// Bu model, proje dokümantasyon şablonunu içerir:
/// 1. Problem/Amaç
/// 2. Yaklaşım
/// 3. Uygulama
/// 4. Sonuçlar
/// 5. Öğrenilenler
/// 
/// Örnek kullanım:
/// ```dart
/// final project = Project(
///   id: 'smart-irrigation',
///   title: 'Akıllı Sulama Sistemi',
///   category: ProjectCategory.electronics,
///   ...
/// );
/// ```
class Project {
  // ============================================================
  // TEMEL BİLGİLER
  // ============================================================
  
  /// Projenin benzersiz kimliği (URL'de kullanılır)
  final String id;
  
  /// Projenin başlığı
  final String title;
  
  /// Projenin kısa açıklaması (kartlarda gösterilir)
  final String subtitle;
  
  /// Projenin kategorisi (Elektronik/Mekanik/Yazılım)
  final ProjectCategory category;
  
  /// Projeyle ilgili etiketler (teknolojiler, kavramlar)
  final List<String> tags;
  
  /// Proje kartında gösterilecek küçük resim URL'si
  final String thumbnailUrl;
  
  /// Proje ana sayfada öne çıkarılacak mı?
  final bool featured;
  
  /// Projenin tamamlanma tarihi
  final DateTime date;
  
  // ============================================================
  // DOKÜMANTASYON BÖLÜMLERİ
  // Her proje bu 5 bölümü içermelidir
  // ============================================================
  
  /// 1. PROBLEM / AMAÇ
  /// Ne çözmeye çalışıyorum? Neden bu önemli?
  final String problem;
  
  /// 2. YAKLAŞIM
  /// Nasıl düşündüm? Hangi alternatifleri değerlendirdim?
  final String approach;
  
  /// 3. UYGULAMA
  /// Teknik detaylar, kullanılan teknolojiler, mimari
  final String implementation;
  
  /// 4. SONUÇLAR
  /// Ne elde ettim? Metrikler, demo, görseller
  final String results;
  
  /// 5. ÖĞRENİLENLER
  /// Ne öğrendim? Neleri farklı yapardım?
  final String lessonsLearned;
  
  // ============================================================
  // EK BİLGİLER
  // ============================================================
  
  /// Projede kullanılan teknolojiler listesi
  final List<String> technologies;
  
  /// Proje görselleri URL'leri
  final List<String> imageUrls;
  
  /// GitHub repository URL'si (opsiyonel)
  final String? githubUrl;
  
  /// Canlı demo URL'si (opsiyonel)
  final String? demoUrl;
  
  /// Proje tanıtım videosu URL'si (opsiyonel)
  final String? videoUrl;

  /// Yeni bir Project nesnesi oluşturur.
  /// 
  /// Zorunlu alanlar: id, title, subtitle, category, tags, thumbnailUrl,
  /// date, problem, approach, implementation, results, lessonsLearned, technologies
  const Project({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.tags,
    required this.thumbnailUrl,
    required this.date,
    this.featured = false,
    required this.problem,
    required this.approach,
    required this.implementation,
    required this.results,
    required this.lessonsLearned,
    required this.technologies,
    this.imageUrls = const [],
    this.githubUrl,
    this.demoUrl,
    this.videoUrl,
  });
}

/// Bir teknik beceriyi temsil eden veri modeli.
/// 
/// Hakkımda sayfasındaki beceri bölümünde kullanılır.
/// Her beceri bir kategoriye aittir ve yeterlilik yüzdesi içerir.
class Skill {
  /// Becerinin adı (örn: "PCB Tasarımı")
  final String name;
  
  /// Becerinin kısa açıklaması
  final String description;
  
  /// Becerinin ait olduğu kategori
  final ProjectCategory category;
  
  /// Yeterlilik yüzdesi (0-100 arası)
  final int proficiencyPercent;
  
  /// Yeni bir Skill nesnesi oluşturur.
  const Skill({
    required this.name,
    required this.description,
    required this.category,
    required this.proficiencyPercent,
  });
}
