import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/cv_models.dart';
import '../services/data_service.dart';
import '../utils/open_url.dart';
import '../utils/responsive.dart';
import '../widgets/common/section_title.dart';
import '../widgets/cv/education_section.dart';
import '../widgets/cv/certificates_section.dart';
import '../widgets/cv/work_experience_section.dart';
import '../widgets/cv/achievements_section.dart';
import '../widgets/cv/languages_section.dart';
import '../widgets/cv/publications_section.dart';
import '../widgets/cv/references_section.dart';

/// Profil sayfası - CV bilgilerini içerir.
/// 
/// Bölümler:
/// 1. Kişisel Bilgi Header'ı
/// 2. İş Deneyimi Timeline
/// 3. Eğitim
/// 4. Sertifikalar
/// 5. Başarılar
/// 6. Diller
/// 7. Yayınlar
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _personalInfo;
  List<Education> _education = [];
  List<Certificate> _certificates = [];
  List<WorkExperience> _workExperiences = [];
  List<Achievement> _achievements = [];
  List<LanguageSkill> _languages = [];
  List<Publication> _publications = [];
  List<Reference> _references = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dataService = context.read<DataService>();
    
    // Tüm verileri paralel olarak yükle
    final results = await Future.wait([
      dataService.getPersonalInfo(),
      dataService.getEducationItems(),
      dataService.getCertificateItems(),
      dataService.getWorkExperienceItems(),
      dataService.getAchievementItems(),
      dataService.getLanguageItems(),
      dataService.getPublicationItems(),
      dataService.getReferenceItems(),
    ]);

    if (mounted) {
      setState(() {
        _personalInfo = results[0] as Map<String, dynamic>?;
        _education = results[1] as List<Education>;
        _certificates = results[2] as List<Certificate>;
        _workExperiences = results[3] as List<WorkExperience>;
        _achievements = results[4] as List<Achievement>;
        _languages = results[5] as List<LanguageSkill>;
        _publications = results[6] as List<Publication>;
        _references = results[7] as List<Reference>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final sectionPadding = Responsive.sectionPadding(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.xxl),
      child: Column(
        children: [
          // Sayfa başlığı
          ContentContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: SectionTitle(
                        title: 'Profil',
                        subtitle: 'Eğitim, deneyim ve yetkinliklerim',
                      ),
                    ),
                    if (_personalInfo?['cv_pdf_url'] != null)
                      OutlinedButton.icon(
                        onPressed: () => tryLaunchUrlString(
                          _personalInfo!['cv_pdf_url'] as String,
                          context: context,
                        ),
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('CV İndir'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accent,
                          side: const BorderSide(color: AppTheme.accent),
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.lg,
                            vertical: Spacing.sm,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.xxl),

                // Kişisel bilgi header'ı
                if (_personalInfo != null)
                  RepaintBoundary(child: _buildProfileHeader(isDesktop)),
              ],
            ),
          ),
          
          SizedBox(height: sectionPadding),
          
          // CV Bölümleri
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(Spacing.xxl),
                child: CircularProgressIndicator(),
              ),
            )
          else
            RepaintBoundary(
              child: ContentContainer(
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
                    
                    // Referanslar
                    ReferencesSection(items: _references),
                  ],
                ),
              ),
            ),
          
          SizedBox(height: sectionPadding),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isDesktop) {
    final name = _personalInfo?['full_name'] ?? 'İsim';
    final title = _personalInfo?['title'] ?? 'Ünvan';
    final email = _personalInfo?['email'];
    final location = _personalInfo?['location'];
    final githubUrl = _personalInfo?['github_url'];
    final linkedinUrl = _personalInfo?['linkedin_url'];
    final militaryStatus = _personalInfo?['military_status'] as String?;
    final driverLicense = _personalInfo?['driver_license'] as String?;
    
    return Container(
      padding: const EdgeInsets.all(Spacing.xl),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: isDesktop
          ? Row(
              children: [
                // Profil resmi placeholder
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: AppTheme.accent.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.xl),
                
                // Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      Wrap(
                        spacing: Spacing.lg,
                        runSpacing: Spacing.sm,
                        children: [
                          if (email != null)
                            _buildInfoChip(Icons.email_outlined, email),
                          if (location != null)
                            _buildInfoChip(Icons.location_on_outlined, location),
                          if (githubUrl != null)
                            _buildInfoChip(Icons.code, 'GitHub'),
                          if (linkedinUrl != null)
                            _buildInfoChip(Icons.business, 'LinkedIn'),
                          if (militaryStatus != null)
                            _buildInfoChip(Icons.shield_outlined, 'Askerlik: $militaryStatus'),
                          if (driverLicense != null)
                            _buildInfoChip(Icons.directions_car_outlined, 'Ehliyet: $driverLicense'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                // Profil resmi
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: AppTheme.accent.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                
                // Bilgiler
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.accent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.md),
                Wrap(
                  spacing: Spacing.md,
                  runSpacing: Spacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    if (email != null)
                      _buildInfoChip(Icons.email_outlined, email),
                    if (location != null)
                      _buildInfoChip(Icons.location_on_outlined, location),
                    if (militaryStatus != null)
                      _buildInfoChip(Icons.shield_outlined, 'Askerlik: $militaryStatus'),
                    if (driverLicense != null)
                      _buildInfoChip(Icons.directions_car_outlined, 'Ehliyet: $driverLicense'),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    final maxChipWidth = MediaQuery.of(context).size.width * 0.75;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxChipWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textMuted),
          const SizedBox(width: Spacing.xs),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }
}
