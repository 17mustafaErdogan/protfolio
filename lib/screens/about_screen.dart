import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../services/data_service.dart';
import '../utils/responsive.dart';

/// Hakkımda sayfası.
/// 
/// Kişisel/felsefi içerik - "Bu kişi kim, nasıl düşünüyor, 
/// hangi problemleri çözmeyi seviyor ve neden onunla çalışmalıyım?"
/// 
/// Bölümler:
/// 1. Hero - Profil resmi + kısa tanıtım
/// 2. Hikayem - Kim olduğum, nasıl başladım
/// 3. Vizyonum - Neye inanıyorum, hedeflerim
/// 4. Problem Çözme Yaklaşımım - Nasıl düşünüyorum
/// 5. Neden Benimle Çalışmalısınız? - Değer önerileri
/// 6. CTA - İletişim butonu
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Map<String, dynamic>? _personalInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dataService = context.read<DataService>();
    final personalInfo = await dataService.getPersonalInfo();
    
    if (mounted) {
      setState(() {
        _personalInfo = personalInfo;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final sectionPadding = Responsive.sectionPadding(context);
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Column(
      children: [
        // ============================================================
        // HERO BÖLÜMÜ
        // ============================================================
        RepaintBoundary(child: _buildHeroSection(isDesktop)),
        
        // ============================================================
        // HİKAYEM
        // ============================================================
        RepaintBoundary(child: _buildStorySection(isDesktop)),
        
        // ============================================================
        // VİZYONUM
        // ============================================================
        RepaintBoundary(child: _buildVisionSection(isDesktop)),
        
        // ============================================================
        // PROBLEM ÇÖZME YAKLAŞIMIM
        // ============================================================
        RepaintBoundary(child: _buildApproachSection(isDesktop)),
        
        // ============================================================
        // NEDEN BENİMLE ÇALIŞMALISINIZ?
        // ============================================================
        RepaintBoundary(child: _buildWhyMeSection(isDesktop)),
        
        // ============================================================
        // CTA
        // ============================================================
        RepaintBoundary(child: _buildCTASection()),
        
        SizedBox(height: sectionPadding),
      ],
    );
  }

  Widget _buildHeroSection(bool isDesktop) {
    final name = _personalInfo?['full_name'] ?? 'Mühendis İsmi';
    final title = _personalInfo?['title'] ?? 'Multidisipliner Mühendis';
    final bio = _personalInfo?['bio'] ?? '';
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? Spacing.xxxl * 2 : Spacing.xxl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.background,
            AppTheme.surface.withOpacity(0.5),
          ],
        ),
      ),
      child: ContentContainer(
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profil resmi
                  _buildProfileImage(150),
                  const SizedBox(width: Spacing.xxl),
                  
                  // Bilgiler
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merhaba,',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          'Ben $name',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.accent,
                          ),
                        ),
                        if (bio.isNotEmpty) ...[
                          const SizedBox(height: Spacing.lg),
                          Text(
                            bio,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildProfileImage(120),
                  const SizedBox(height: Spacing.xl),
                  Text(
                    'Merhaba,',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    'Ben $name',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: Spacing.lg),
                    Text(
                      bio,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildProfileImage(double size) {
    final name = _personalInfo?['full_name'] ?? '';
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: AppTheme.accent.withOpacity(0.3),
          width: 4,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: AppTheme.accent,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStorySection(bool isDesktop) {
    final story = _personalInfo?['story'] ?? 
        'Hikayem henüz eklenmedi. Admin panelinden "Ayarlar" bölümünden hikayenizi ekleyebilirsiniz.';
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: Responsive.sectionPadding(context)),
      child: ContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.auto_stories,
              title: 'Hikayem',
              color: AppTheme.electronics,
            ),
            const SizedBox(height: Spacing.xl),
            Container(
              padding: const EdgeInsets.all(Spacing.xl),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                story,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisionSection(bool isDesktop) {
    final vision = _personalInfo?['vision'] ?? 
        'Vizyonum henüz eklenmedi. Admin panelinden "Ayarlar" bölümünden vizyonunuzu ekleyebilirsiniz.';
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: Responsive.sectionPadding(context)),
      color: AppTheme.surface.withOpacity(0.3),
      child: ContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.visibility,
              title: 'Vizyonum',
              color: AppTheme.mechanical,
            ),
            const SizedBox(height: Spacing.xl),
            Container(
              padding: const EdgeInsets.all(Spacing.xl),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                vision,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApproachSection(bool isDesktop) {
    final approach = _personalInfo?['approach'] ?? 
        'Problem çözme yaklaşımım henüz eklenmedi. Admin panelinden "Ayarlar" bölümünden ekleyebilirsiniz.';
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: Responsive.sectionPadding(context)),
      child: ContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.psychology,
              title: 'Problem Çözme Yaklaşımım',
              color: AppTheme.software,
            ),
            const SizedBox(height: Spacing.xl),
            Container(
              padding: const EdgeInsets.all(Spacing.xl),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                approach,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhyMeSection(bool isDesktop) {
    final whyMe = _personalInfo?['why_me'] ?? 
        'Neden benimle çalışmalısınız içeriği henüz eklenmedi. Admin panelinden "Ayarlar" bölümünden ekleyebilirsiniz.';
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: Responsive.sectionPadding(context)),
      color: AppTheme.surface.withOpacity(0.3),
      child: ContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              icon: Icons.handshake,
              title: 'Neden Benimle Çalışmalısınız?',
              color: AppTheme.accentGreen,
            ),
            const SizedBox(height: Spacing.xl),
            Container(
              padding: const EdgeInsets.all(Spacing.xl),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                whyMe,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: Spacing.lg),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCTASection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Responsive.sectionPadding(context)),
      child: ContentContainer(
        child: Center(
          child: Column(
            children: [
              Text(
                'Birlikte çalışmak ister misiniz?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.md),
              Text(
                'Projeleriniz veya fikirleriniz hakkında konuşmak için benimle iletişime geçin.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xl),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.contact),
                icon: const Icon(Icons.mail_outline),
                label: const Text('İletişime Geç'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xl,
                    vertical: Spacing.md,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
