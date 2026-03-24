import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/data_service.dart';
import '../../utils/responsive.dart';
import 'hero_window_chrome.dart';
import 'hero_greeting.dart';
import 'hero_specialties_row.dart';
import 'hero_bio_text.dart';
import 'hero_stats_row.dart';
import 'hero_cta_buttons.dart';

/// Ana sayfanın hero bölümü – ilk izlenim alanı.
///
/// - Kişisel bilgileri ve uzmanlık alanlarını Supabase'den çeker
/// - Uzmanlık alanları + deneyim yılları otomatik hesaplanır
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  Map<String, dynamic>? _personalInfo;
  Map<String, dynamic> _autoStats = {
    'project_count': 0,
    'expertise_areas': <Map<String, dynamic>>[],
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dataService = context.read<DataService>();
    final personalInfo = await dataService.getPersonalInfo();
    final autoStats = await dataService.getAutoStats();

    if (!mounted) return;

    setState(() {
      _personalInfo = personalInfo;
      _autoStats = autoStats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final nameFontSize = Responsive.adaptiveFontSize(context, min: 32, max: 48);
    final bodyFontSize = Responsive.adaptiveFontSize(context, min: 15, max: 18);

    final name = _personalInfo?['full_name'] ?? 'Ad Soyad';
    final bio = _personalInfo?['bio'] ??
        'Karmaşık problemlere pratik çözümler üreten multidisipliner mühendis.';

    final expertiseAreas = ((_autoStats['expertise_areas'] as List?) ?? [])
        .cast<Map<String, dynamic>>();

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
            AppTheme.surface.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: ContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeroWindowChrome(),
            SizedBox(height: isDesktop ? Spacing.xxl : Spacing.xl),
            HeroGreeting(
              name: name,
              isDesktop: isDesktop,
              isLoading: _isLoading,
              nameFontSize: nameFontSize,
            ),
            SizedBox(height: isDesktop ? Spacing.xl : Spacing.lg),
            HeroSpecialtiesRow(areas: expertiseAreas),
            SizedBox(height: isDesktop ? Spacing.xl : Spacing.lg),
            HeroBioText(
              bio: bio,
              isDesktop: isDesktop,
              bodyFontSize: bodyFontSize,
            ),
            SizedBox(height: isDesktop ? Spacing.xxl : Spacing.xl),
            if (!_isLoading) ...[
              HeroStatsRow(
                projectCount: _autoStats['project_count'] as int? ?? 0,
                expertiseAreas: expertiseAreas,
              ),
              SizedBox(height: isDesktop ? Spacing.xxl : Spacing.xl),
            ],
            const HeroCtaButtons(),
          ],
        ),
      ),
    );
  }
}
