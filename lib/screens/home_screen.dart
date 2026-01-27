import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/cv_models.dart';
import '../services/data_service.dart';
import '../utils/responsive.dart';
import '../widgets/home/hero_section.dart';
import '../widgets/home/featured_projects.dart';
import '../widgets/home/skills_section.dart';
import '../widgets/cv/education_section.dart';
import '../widgets/cv/certificates_section.dart';
import '../widgets/cv/work_experience_section.dart';
import '../widgets/cv/achievements_section.dart';
import '../widgets/cv/languages_section.dart';
import '../widgets/cv/publications_section.dart';
import '../widgets/cv/references_section.dart';

/// Ana sayfa ekranı.
/// 
/// Portföyün giriş noktası olup kariyer bilgilerini Supabase'den dinamik olarak gösterir.
/// 
/// Bölümler (boş olanlar otomatik gizlenir):
/// 1. [HeroSection] - Tanıtım ve CTA butonları
/// 2. [FeaturedProjects] - Öne çıkan projeler grid'i
/// 3. [SkillsSection] - Uzmanlık alanları (Elektronik/Mekanik/Yazılım)
/// 4. CV Bölümleri - İş deneyimi, eğitim, sertifikalar vb.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Education> _education = [];
  List<Certificate> _certificates = [];
  List<WorkExperience> _workExperiences = [];
  List<Achievement> _achievements = [];
  List<LanguageSkill> _languages = [];
  List<Publication> _publications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCVData();
  }

  Future<void> _loadCVData() async {
    final dataService = context.read<DataService>();
    
    // Tüm CV verilerini paralel olarak yükle
    final results = await Future.wait([
      dataService.getEducation(),
      dataService.getCertificates(),
      dataService.getWorkExperience(),
      dataService.getAchievements(),
      dataService.getLanguages(),
      dataService.getPublications(),
    ]);

    if (mounted) {
      setState(() {
        _education = (results[0] as List).map((e) => Education(
          degree: e['degree'] ?? '',
          field: e['field'] ?? '',
          institution: e['institution'] ?? '',
          period: e['period'] ?? '',
          description: e['description'],
          gpa: e['gpa'],
        )).toList();
        
        _certificates = (results[1] as List).map((e) => Certificate(
          name: e['name'] ?? '',
          issuer: e['issuer'] ?? '',
          date: e['date'] ?? '',
          credentialUrl: e['credential_url'],
          credentialId: e['credential_id'],
        )).toList();
        
        _workExperiences = (results[2] as List).map((e) => WorkExperience(
          title: e['title'] ?? '',
          company: e['company'] ?? '',
          period: e['period'] ?? '',
          description: e['description'],
          highlights: (e['highlights'] as List?)?.cast<String>() ?? [],
          location: e['location'],
          employmentType: e['employment_type'],
        )).toList();
        
        _achievements = (results[3] as List).map((e) => Achievement(
          title: e['title'] ?? '',
          description: e['description'] ?? '',
          date: e['date'],
          organization: e['organization'],
        )).toList();
        
        _languages = (results[4] as List).map((e) => LanguageSkill(
          language: e['language'] ?? '',
          level: e['level'] ?? '',
          proficiencyPercent: e['proficiency_percent'],
        )).toList();
        
        _publications = (results[5] as List).map((e) => Publication(
          title: e['title'] ?? '',
          venue: e['venue'] ?? '',
          date: e['date'] ?? '',
          url: e['url'],
          coAuthors: (e['co_authors'] as List?)?.cast<String>() ?? [],
          abstract: e['abstract'],
        )).toList();
        
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ============================================================
        // TANITIM BÖLÜMÜ
        // ============================================================
        const HeroSection(),
        SizedBox(height: Spacing.sectionPadding),
        
        // ============================================================
        // ÖNE ÇIKAN PROJELER
        // ============================================================
        const FeaturedProjects(),
        SizedBox(height: Spacing.sectionPadding),
        
        // ============================================================
        // TEKNİK BECERİLER
        // ============================================================
        const SkillsSection(),
        SizedBox(height: Spacing.sectionPadding),
        
        // ============================================================
        // CV BÖLÜMLERİ (Dinamik - boş olanlar gösterilmez)
        // ============================================================
        if (!_isLoading)
          ContentContainer(
            child: Column(
              children: [
                // İş Deneyimi Timeline
                WorkExperienceSection(items: _workExperiences),
                
                // Eğitim Bilgileri
                EducationSection(items: _education),
                
                // Sertifikalar
                CertificatesSection(items: _certificates),
                
                // Başarılar ve Ödüller
                AchievementsSection(items: _achievements),
                
                // Yabancı Dil Becerileri
                LanguagesSection(items: _languages),
                
                // Yayınlar
                PublicationsSection(items: _publications),
                
                // Referanslar (boş liste - istenirse eklenebilir)
                const ReferencesSection(items: []),
              ],
            ),
          ),
        
        SizedBox(height: Spacing.sectionPadding),
      ],
    );
  }
}
