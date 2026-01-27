import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../data/projects_data.dart';
import '../data/cv_data.dart';
import '../models/project.dart';
import '../utils/responsive.dart';
import '../widgets/common/section_title.dart';
import '../widgets/cv/work_experience_section.dart';
import '../widgets/cv/education_section.dart';
import '../widgets/cv/certificates_section.dart';
import '../widgets/cv/languages_section.dart';

/// Hakkımda sayfası - kişisel bilgiler ve profesyonel geçmiş.
/// 
/// Bu sayfa şu bölümlerden oluşur:
/// 1. Biyografi - profil fotoğrafı, isim, unvan, açıklama, istatistikler
/// 2. Teknik Beceriler - kategorilere göre gruplandırılmış beceriler
/// 3. Deneyim Timeline - iş geçmişi kronolojisi (cv_data'dan)
/// 4. Eğitim - akademik geçmiş (cv_data'dan, boşsa gizlenir)
/// 5. Sertifikalar - profesyonel sertifikalar (cv_data'dan, boşsa gizlenir)
/// 6. Diller - yabancı dil becerileri (cv_data'dan, boşsa gizlenir)
/// 
/// Responsive tasarım:
/// - Masaüstünde: Profil fotoğrafı sol, biyografi sağda
/// - Mobilde: Profil fotoğrafı üstte, biyografi altta
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.xxl),
      child: ContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sayfa başlığı
            const SectionTitle(
              title: 'Hakkımda',
              subtitle: 'Mühendislik yolculuğum ve profesyonel geçmişim',
            ),
            const SizedBox(height: Spacing.xxl),
            
            // ============================================================
            // BİYOGRAFİ BÖLÜMÜ
            // ============================================================
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profil fotoğrafı
                  _buildProfileImage(200),
                  const SizedBox(width: Spacing.xxl),
                  Expanded(child: _BioContent()),
                ],
              )
            else
              Column(
                children: [
                  // Mobil: Daha küçük profil fotoğrafı
                  _buildProfileImage(150),
                  const SizedBox(height: Spacing.xl),
                  _BioContent(),
                ],
              ),
            
            const SizedBox(height: Spacing.xxl),
            const Divider(),
            const SizedBox(height: Spacing.xxl),
            
            // ============================================================
            // TEKNİK BECERİLER BÖLÜMÜ
            // ============================================================
            const SectionTitle(
              title: 'Teknik Beceriler',
              subtitle: 'Uzmanlaştığım araçlar ve teknolojiler',
            ),
            const SizedBox(height: Spacing.xl),
            
            _SkillsGrid(),
            
            const SizedBox(height: Spacing.xxl),
            const Divider(),
            const SizedBox(height: Spacing.xxl),
            
            // ============================================================
            // İŞ DENEYİMİ (CV Data'dan)
            // ============================================================
            if (workExperiences.isNotEmpty) ...[
              WorkExperienceSection(items: workExperiences),
              const Divider(),
              const SizedBox(height: Spacing.xxl),
            ],
            
            // ============================================================
            // EĞİTİM (CV Data'dan - boşsa gizlenir)
            // ============================================================
            EducationSection(items: educationList),
            
            // ============================================================
            // SERTİFİKALAR (CV Data'dan - boşsa gizlenir)
            // ============================================================
            CertificatesSection(items: certificates),
            
            // ============================================================
            // DİLLER (CV Data'dan - boşsa gizlenir)
            // ============================================================
            LanguagesSection(items: languages),
            
            SizedBox(height: Spacing.sectionPadding),
          ],
        ),
      ),
    );
  }
  
  /// Profil fotoğrafı widget'ı oluşturur.
  Widget _buildProfileImage(double size) {
    // Profil fotoğrafı varsa göster, yoksa placeholder
    if (personalInfo.profileImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          personalInfo.profileImageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(size),
        ),
      );
    }
    return _buildPlaceholder(size);
  }
  
  /// Profil fotoğrafı placeholder'ı.
  Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Center(
        child: Icon(
          Icons.person_outline,
          size: size * 0.32,
          color: AppTheme.textMuted,
        ),
      ),
    );
  }
}

/// Biyografi içeriği - isim, unvan, açıklama ve istatistikler.
/// 
/// cv_data.dart'taki personalInfo verisini kullanır.
class _BioContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // İsim
        Text(
          personalInfo.fullName,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: Spacing.sm),
        
        // Unvan
        Text(
          personalInfo.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(height: Spacing.lg),
        
        // Ana açıklama
        Text(
          personalInfo.bio,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        
        // Detay açıklama (varsa)
        if (personalInfo.detailedBio != null) ...[
          const SizedBox(height: Spacing.md),
          Text(
            personalInfo.detailedBio!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: Spacing.lg),
        
        // Konum (varsa)
        if (personalInfo.location != null) ...[
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                personalInfo.location!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
        ],
        
        // İstatistikler satırı
        Row(
          children: [
            _StatItem(value: Stats.projectCount, label: 'Proje'),
            const SizedBox(width: Spacing.xl),
            _StatItem(value: Stats.yearsExperience, label: 'Yıl Deneyim'),
            const SizedBox(width: Spacing.xl),
            _StatItem(value: Stats.expertiseAreas, label: 'Uzmanlık Alanı'),
          ],
        ),
        
        // Sosyal linkler
        const SizedBox(height: Spacing.lg),
        _SocialLinks(),
      ],
    );
  }
}

/// Sosyal medya linkleri widget'ı.
class _SocialLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final links = <_SocialLinkData>[];
    
    if (personalInfo.githubUrl != null) {
      links.add(_SocialLinkData(
        icon: Icons.code,
        label: 'GitHub',
        url: personalInfo.githubUrl!,
      ));
    }
    if (personalInfo.linkedinUrl != null) {
      links.add(_SocialLinkData(
        icon: Icons.business,
        label: 'LinkedIn',
        url: personalInfo.linkedinUrl!,
      ));
    }
    if (personalInfo.email != null) {
      links.add(_SocialLinkData(
        icon: Icons.email_outlined,
        label: personalInfo.email!,
        url: 'mailto:${personalInfo.email}',
      ));
    }
    
    if (links.isEmpty) return const SizedBox.shrink();
    
    return Wrap(
      spacing: Spacing.md,
      runSpacing: Spacing.sm,
      children: links.map((link) => _SocialLinkButton(data: link)).toList(),
    );
  }
}

class _SocialLinkData {
  final IconData icon;
  final String label;
  final String url;
  
  const _SocialLinkData({
    required this.icon,
    required this.label,
    required this.url,
  });
}

class _SocialLinkButton extends StatelessWidget {
  final _SocialLinkData data;
  
  const _SocialLinkButton({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        // TODO: URL açma işlemi (url_launcher paketi gerekli)
      },
      icon: Icon(data.icon, size: 16),
      label: Text(data.label),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.accent,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
      ),
    );
  }
}

/// Tek bir istatistik öğesi (değer + etiket).
class _StatItem extends StatelessWidget {
  /// Büyük gösterilen değer (örn: "15+")
  final String value;
  
  /// Altındaki açıklama etiketi (örn: "Proje")
  final String label;
  
  const _StatItem({required this.value, required this.label});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppTheme.accent,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

/// Beceriler grid'i - kategorilere göre gruplandırılmış beceri chip'leri.
/// 
/// Her kategori (Elektronik/Mekanik/Yazılım) ayrı bir kart içinde gösterilir.
/// Beceriler tooltip ile açıklama içerir.
class _SkillsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Becerileri kategorilere göre grupla
    final skillsByCategory = <ProjectCategory, List<Skill>>{};
    for (final skill in skills) {
      skillsByCategory.putIfAbsent(skill.category, () => []).add(skill);
    }
    
    return Column(
      children: ProjectCategory.values.map((category) {
        final categorySkills = skillsByCategory[category] ?? [];
        final color = _getCategoryColor(category);
        
        return Container(
          margin: const EdgeInsets.only(bottom: Spacing.lg),
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kategori başlığı
              Row(
                children: [
                  Text(
                    category.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    category.displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              
              // Beceri chip'leri
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: categorySkills.map((skill) {
                  return Tooltip(
                    message: skill.description,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        skill.name,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: color,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  /// Kategoriye göre renk döndürür.
  Color _getCategoryColor(ProjectCategory category) {
    switch (category) {
      case ProjectCategory.electronics:
        return AppTheme.electronics;
      case ProjectCategory.mechanical:
        return AppTheme.mechanical;
      case ProjectCategory.software:
        return AppTheme.software;
    }
  }
}
