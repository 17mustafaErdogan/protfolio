import 'package:flutter/material.dart';

/// Eğitim bilgisini temsil eden veri modeli.
/// 
/// Üniversite, lise veya diğer eğitim kurumlarındaki
/// eğitim geçmişini dokümante etmek için kullanılır.
class Education {
  /// Derece türü (Lisans, Yüksek Lisans, Doktora, vb.)
  final String degree;
  
  /// Bölüm/Alan (Elektrik-Elektronik Mühendisliği, vb.)
  final String field;
  
  /// Kurum adı (Üniversite, Okul)
  final String institution;
  
  /// Eğitim dönemi (örn: "2018 - 2022")
  final String period;
  
  /// Opsiyonel açıklama veya notlar
  final String? description;
  
  /// Genel not ortalaması (opsiyonel)
  final String? gpa;

  const Education({
    required this.degree,
    required this.field,
    required this.institution,
    required this.period,
    this.description,
    this.gpa,
  });
}

/// Sertifika veya kurs bilgisini temsil eden veri modeli.
/// 
/// Profesyonel sertifikalar, online kurslar, bootcamp'ler
/// ve diğer eğitim sertifikalarını dokümante etmek için kullanılır.
class Certificate {
  /// Sertifika adı
  final String name;
  
  /// Veren kurum (Coursera, Udemy, Google, vb.)
  final String issuer;
  
  /// Alınma tarihi
  final DateTime date;
  
  /// Sertifika doğrulama URL'si (opsiyonel)
  final String? credentialUrl;
  
  /// Sertifika ID'si (opsiyonel)
  final String? credentialId;

  const Certificate({
    required this.name,
    required this.issuer,
    required this.date,
    this.credentialUrl,
    this.credentialId,
  });
}

/// Yabancı dil becerisini temsil eden veri modeli.
/// 
/// Bilinen diller ve seviyelerini göstermek için kullanılır.
class LanguageSkill {
  /// Dil adı (İngilizce, Almanca, vb.)
  final String language;
  
  /// Dil seviyesi (A1-C2 veya Başlangıç-Anadil)
  final String level;
  
  /// Yeterlilik yüzdesi (opsiyonel, progress bar için)
  final int? proficiencyPercent;

  const LanguageSkill({
    required this.language,
    required this.level,
    this.proficiencyPercent,
  });
}

/// Başarı veya ödül bilgisini temsil eden veri modeli.
/// 
/// Yarışma ödülleri, onur listeleri, başarı belgeleri
/// ve diğer takdirleri dokümante etmek için kullanılır.
class Achievement {
  /// Başarı/Ödül başlığı
  final String title;
  
  /// Açıklama veya detaylar
  final String description;
  
  /// Tarih (opsiyonel)
  final DateTime? date;
  
  /// İlgili kurum veya organizasyon (opsiyonel)
  final String? organization;

  const Achievement({
    required this.title,
    required this.description,
    this.date,
    this.organization,
  });
}

/// Yayın veya makale bilgisini temsil eden veri modeli.
/// 
/// Akademik makaleler, blog yazıları, konferans sunumları
/// ve diğer yayınları dokümante etmek için kullanılır.
class Publication {
  /// Yayın başlığı
  final String title;
  
  /// Yayınlandığı yer (Dergi, Konferans, Blog, vb.)
  final String venue;
  
  /// Yayın tarihi
  final DateTime date;
  
  /// Yayın URL'si (opsiyonel)
  final String? url;
  
  /// Ortak yazarlar (opsiyonel)
  final List<String>? coAuthors;
  
  /// Özet/Abstract (opsiyonel)
  final String? abstract;

  const Publication({
    required this.title,
    required this.venue,
    required this.date,
    this.url,
    this.coAuthors,
    this.abstract,
  });
}

/// Referans bilgisini temsil eden veri modeli.
/// 
/// Profesyonel referansları dokümante etmek için kullanılır.
/// Not: Referans bilgileri genellikle istek üzerine paylaşılır.
class Reference {
  /// Referansın adı
  final String name;
  
  /// Ünvanı/Pozisyonu
  final String title;
  
  /// Çalıştığı şirket/kurum
  final String company;
  
  /// E-posta adresi (opsiyonel)
  final String? email;
  
  /// Telefon numarası (opsiyonel)
  final String? phone;
  
  /// İlişki türü (örn: "Eski Yönetici", "Proje Ortağı")
  final String? relationship;

  const Reference({
    required this.name,
    required this.title,
    required this.company,
    this.email,
    this.phone,
    this.relationship,
  });
}

/// İş deneyimini temsil eden veri modeli.
/// 
/// Profesyonel iş geçmişini dokümante etmek için kullanılır.
/// Timeline görünümünde gösterilir.
class WorkExperience {
  /// Pozisyon/Ünvan
  final String title;
  
  /// Şirket/Kurum adı
  final String company;
  
  /// Çalışma dönemi (örn: "2022 - Günümüz")
  final String period;
  
  /// Genel açıklama (opsiyonel)
  final String? description;
  
  /// Öne çıkan başarılar/sorumluluklar
  final List<String> highlights;
  
  /// Şirket logosu URL'si (opsiyonel)
  final String? logoUrl;
  
  /// Konum (örn: "İstanbul, Türkiye")
  final String? location;
  
  /// Çalışma tipi (Tam Zamanlı, Yarı Zamanlı, Serbest, vb.)
  final String? employmentType;
  
  /// Timeline'da gösterilecek renk
  final Color? color;

  const WorkExperience({
    required this.title,
    required this.company,
    required this.period,
    this.description,
    this.highlights = const [],
    this.logoUrl,
    this.location,
    this.employmentType,
    this.color,
  });
}

/// Kişisel bilgileri temsil eden veri modeli.
/// 
/// Hero section ve hakkımda sayfasında gösterilecek
/// temel kişisel bilgileri içerir.
class PersonalInfo {
  /// Tam ad
  final String fullName;
  
  /// Profesyonel ünvan (örn: "Multidisipliner Mühendis")
  final String title;
  
  /// Kısa biyografi
  final String bio;
  
  /// Detaylı açıklama (opsiyonel)
  final String? detailedBio;
  
  /// Profil fotoğrafı URL'si (opsiyonel)
  final String? profileImageUrl;
  
  /// E-posta adresi
  final String? email;
  
  /// Konum
  final String? location;
  
  /// GitHub profil URL'si (opsiyonel)
  final String? githubUrl;
  
  /// LinkedIn profil URL'si (opsiyonel)
  final String? linkedinUrl;
  
  /// Twitter/X profil URL'si (opsiyonel)
  final String? twitterUrl;
  
  /// Kişisel web sitesi URL'si (opsiyonel)
  final String? websiteUrl;

  const PersonalInfo({
    required this.fullName,
    required this.title,
    required this.bio,
    this.detailedBio,
    this.profileImageUrl,
    this.email,
    this.location,
    this.githubUrl,
    this.linkedinUrl,
    this.twitterUrl,
    this.websiteUrl,
  });
}
