import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/data_service.dart';
import '../../utils/responsive.dart';

/// Ana sayfa hero bölümü - ilk izlenim alanı.
/// 
/// Bu widget, ziyaretçilerin siteye girdiklerinde ilk gördükleri
/// tanıtım alanıdır. Terminal tarzı tasarım ile mühendislik
/// estetiğini yansıtır.
/// 
/// Supabase'den kişisel bilgileri yükler.
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  Map<String, dynamic>? _personalInfo;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dataService = context.read<DataService>();
    final personalInfo = await dataService.getPersonalInfo();
    final stats = await dataService.getStats();
    
    if (mounted) {
      setState(() {
        _personalInfo = personalInfo;
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    
    final name = _personalInfo?['full_name'] ?? 'Mühendis İsmi';
    final title = _personalInfo?['title'] ?? 'Multidisipliner Mühendis';
    final bio = _personalInfo?['bio'] ?? 
        'Karmaşık problemlere pratik çözümler üreten multidisipliner mühendis.';
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? Spacing.xxxl * 2 : Spacing.xxl,
      ),
      // Gradient arka plan - üstten alta solma
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Terminal penceresi görünümü
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // macOS tarzı pencere kontrolleri
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.accentRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  // Terminal yolu
                  Text(
                    '~/portfolio',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: isDesktop ? Spacing.xxl : Spacing.xl),
            
            // Karşılama metni
            Text(
              'Merhaba, ben',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            
            // İsim - loading durumu
            if (_isLoading)
              Container(
                width: 300,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            else
              Text(
                name,
                style: isDesktop 
                    ? Theme.of(context).textTheme.displayLarge
                    : Theme.of(context).textTheme.displayMedium,
              ),
            const SizedBox(height: Spacing.md),
            
            // Uzmanlık alanları chip'leri
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: [
                _SpecialtyChip(
                  label: 'Elektronik',
                  color: AppTheme.electronics,
                ),
                Text('•', style: TextStyle(color: AppTheme.textMuted)),
                _SpecialtyChip(
                  label: 'Mekanik',
                  color: AppTheme.mechanical,
                ),
                Text('•', style: TextStyle(color: AppTheme.textMuted)),
                _SpecialtyChip(
                  label: 'Yazılım',
                  color: AppTheme.software,
                ),
              ],
            ),
            
            SizedBox(height: isDesktop ? Spacing.xl : Spacing.lg),
            
            // Tanıtım metni - masaüstünde sınırlı genişlik
            SizedBox(
              width: isDesktop ? 600 : double.infinity,
              child: Text(
                bio,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            
            SizedBox(height: isDesktop ? Spacing.xxl : Spacing.xl),
            
            // İstatistikler
            if (_stats != null) ...[
              Wrap(
                spacing: Spacing.xl,
                runSpacing: Spacing.md,
                children: [
                  _StatItem(
                    value: _stats!['project_count'] ?? '0',
                    label: 'Proje',
                  ),
                  _StatItem(
                    value: _stats!['years_experience'] ?? '0',
                    label: 'Yıl Deneyim',
                  ),
                  _StatItem(
                    value: _stats!['expertise_areas'] ?? '3',
                    label: 'Uzmanlık Alanı',
                  ),
                ],
              ),
              SizedBox(height: isDesktop ? Spacing.xxl : Spacing.xl),
            ],
            
            // Call-to-Action butonları
            Wrap(
              spacing: Spacing.md,
              runSpacing: Spacing.md,
              children: [
                // Birincil CTA - projelere yönlendir
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.projects),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Projeleri Gör'),
                      const SizedBox(width: Spacing.sm),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
                // İkincil CTA - iletişime yönlendir
                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.contact),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mail_outline, size: 18),
                      const SizedBox(width: Spacing.sm),
                      Text('İletişime Geç'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Uzmanlık alanı chip'i.
class _SpecialtyChip extends StatelessWidget {
  final String label;
  final Color color;
  
  const _SpecialtyChip({required this.label, required this.color});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
        ),
      ),
    );
  }
}

/// İstatistik öğesi.
class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.accent,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
