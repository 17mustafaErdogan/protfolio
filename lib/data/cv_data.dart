import 'package:flutter/material.dart';
import '../models/cv_models.dart';
import '../config/theme.dart';

/// CV / Özgeçmiş Verileri
/// 
/// Bu dosya tüm kariyer bilgilerinizi içerir.
/// Boş bırakılan listeler ilgili bölümün görünmemesine neden olur.
/// Verileri doldurdukça ilgili bölümler otomatik olarak görünür hale gelir.

// ============================================================
// KİŞİSEL BİLGİLER
// ============================================================

/// Kişisel bilgileriniz - Hero section ve Hakkımda sayfasında kullanılır
const PersonalInfo personalInfo = PersonalInfo(
  fullName: 'Mühendis İsmi',
  title: 'Multidisipliner Mühendis',
  bio: 'Elektronik, mekanik ve yazılım alanlarında 5+ yıllık deneyime sahip '
       'bir mühendisim. Karmaşık sistemleri anlamak ve pratik çözümler '
       'üretmek benim için bir tutku.',
  detailedBio: 'Gömülü sistemlerden mobil uygulamalara, PCB tasarımından CNC '
               'işlemeye kadar geniş bir yelpazede projeler geliştiriyorum. '
               'Her projede "neden" sorusunu sormayı ve temelden anlamayı '
               'önemsiyorum.',
  // profileImageUrl: 'assets/images/profile.png',
  email: 'email@example.com',
  location: 'İstanbul, Türkiye',
  githubUrl: 'https://github.com/username',
  linkedinUrl: 'https://linkedin.com/in/username',
  // twitterUrl: 'https://twitter.com/username',
  // websiteUrl: 'https://example.com',
);

// ============================================================
// EĞİTİM BİLGİLERİ
// ============================================================

/// Eğitim geçmişiniz - en yeniden en eskiye sıralı
/// 
/// Boş bırakırsanız eğitim bölümü görünmez.
final List<Education> educationList = [
  // Örnek eğitim - kendi bilgilerinizle değiştirin
  // const Education(
  //   degree: 'Lisans',
  //   field: 'Elektrik-Elektronik Mühendisliği',
  //   institution: 'İstanbul Teknik Üniversitesi',
  //   period: '2014 - 2018',
  //   gpa: '3.45 / 4.00',
  //   description: 'Gömülü sistemler ve sinyal işleme alanlarında uzmanlaşma',
  // ),
];

// ============================================================
// SERTİFİKALAR
// ============================================================

/// Sertifika ve kurslarınız
/// 
/// Boş bırakırsanız sertifika bölümü görünmez.
final List<Certificate> certificates = [
  // Örnek sertifika - kendi bilgilerinizle değiştirin
  // Certificate(
  //   name: 'Google Project Management Certificate',
  //   issuer: 'Google / Coursera',
  //   date: DateTime(2023, 6, 15),
  //   credentialUrl: 'https://coursera.org/verify/...',
  // ),
];

// ============================================================
// YABANCI DİL BECERİLERİ
// ============================================================

/// Bildiğiniz yabancı diller
/// 
/// Boş bırakırsanız dil bölümü görünmez.
final List<LanguageSkill> languages = [
  // Örnek dil - kendi bilgilerinizle değiştirin
  // const LanguageSkill(
  //   language: 'İngilizce',
  //   level: 'C1 - İleri Düzey',
  //   proficiencyPercent: 85,
  // ),
  // const LanguageSkill(
  //   language: 'Almanca',
  //   level: 'B1 - Orta Düzey',
  //   proficiencyPercent: 60,
  // ),
];

// ============================================================
// BAŞARILAR VE ÖDÜLLER
// ============================================================

/// Kazandığınız ödüller ve başarılarınız
/// 
/// Boş bırakırsanız başarılar bölümü görünmez.
final List<Achievement> achievements = [
  // Örnek başarı - kendi bilgilerinizle değiştirin
  // Achievement(
  //   title: 'Teknofest Finalist',
  //   description: 'Akıllı tarım projesi ile yarışmada finale kaldık',
  //   date: DateTime(2023, 9),
  //   organization: 'Teknofest',
  // ),
];

// ============================================================
// YAYINLAR VE MAKALELER
// ============================================================

/// Akademik veya teknik yayınlarınız
/// 
/// Boş bırakırsanız yayınlar bölümü görünmez.
final List<Publication> publications = [
  // Örnek yayın - kendi bilgilerinizle değiştirin
  // Publication(
  //   title: 'IoT Tabanlı Akıllı Sulama Sistemlerinde Enerji Optimizasyonu',
  //   venue: 'IEEE Sensors Journal',
  //   date: DateTime(2023, 4),
  //   url: 'https://doi.org/10.1109/...',
  //   coAuthors: ['Dr. Ahmet Yılmaz', 'Prof. Mehmet Demir'],
  // ),
];

// ============================================================
// REFERANSLAR
// ============================================================

/// Profesyonel referanslarınız
/// 
/// Boş bırakırsanız referanslar bölümü görünmez.
/// Not: Genellikle "Referanslar istek üzerine paylaşılır" şeklinde gösterilir.
final List<Reference> references = [
  // Örnek referans - kendi bilgilerinizle değiştirin
  // const Reference(
  //   name: 'Dr. Ahmet Yılmaz',
  //   title: 'Ar-Ge Direktörü',
  //   company: 'ABC Teknoloji',
  //   relationship: 'Eski Yönetici',
  //   email: 'ahmet@example.com',
  // ),
];

// ============================================================
// İŞ DENEYİMİ
// ============================================================

/// İş geçmişiniz - en yeniden en eskiye sıralı
/// 
/// Boş bırakırsanız iş deneyimi bölümü görünmez.
final List<WorkExperience> workExperiences = [
  // Örnek deneyimler - kendi bilgilerinizle değiştirin
  WorkExperience(
    title: 'Kıdemli Mühendis',
    company: 'Şirket Adı',
    period: '2022 - Günümüz',
    description: 'Gömülü sistemler ve IoT projeleri geliştirme',
    highlights: [
      'IoT platformu tasarımı ve geliştirmesi',
      'Ekip liderliği (3 kişilik teknik ekip)',
    ],
    location: 'İstanbul, Türkiye',
    employmentType: 'Tam Zamanlı',
    color: AppTheme.accentGreen,
  ),
  WorkExperience(
    title: 'Mühendis',
    company: 'Önceki Şirket',
    period: '2020 - 2022',
    description: 'PCB tasarımı ve prototip geliştirme',
    highlights: [
      '10+ PCB tasarımı tamamlandı',
      'Üretim süreçlerinde %30 verimlilik artışı',
    ],
    location: 'Ankara, Türkiye',
    employmentType: 'Tam Zamanlı',
    color: AppTheme.accent,
  ),
  WorkExperience(
    title: 'Stajyer Mühendis',
    company: 'İlk Şirket',
    period: '2019 - 2020',
    description: 'Test ve otomasyon sistemleri',
    highlights: [
      'Otomatik test sistemi geliştirme',
      'Dokümantasyon ve kalite kontrol',
    ],
    employmentType: 'Staj',
    color: AppTheme.accentOrange,
  ),
];

// ============================================================
// İSTATİSTİKLER (Ana sayfada gösterilir)
// ============================================================

/// İstatistikler - Hero section veya Hakkımda sayfasında gösterilir
class Stats {
  static const String projectCount = '15+';
  static const String yearsExperience = '5+';
  static const String expertiseAreas = '3';
}
