import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/cv_models.dart';
import '../../utils/responsive.dart';
import '../common/section_title.dart';

/// Yabancı dil becerilerini gösteren section widget'ı.
/// 
/// Dilleri seviye barları ile gösterir.
/// Liste boşsa hiçbir şey render etmez.
class LanguagesSection extends StatelessWidget {
  /// Gösterilecek dil listesi
  final List<LanguageSkill> items;

  const LanguagesSection({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Liste boşsa hiçbir şey gösterme
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Diller',
          subtitle: 'Yabancı dil becerileri',
        ),
        const SizedBox(height: Spacing.xl),
        Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border),
          ),
          child: Wrap(
            spacing: Spacing.xxl,
            runSpacing: Spacing.lg,
            children: items.map((lang) => _LanguageItem(language: lang)).toList(),
          ),
        ),
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }
}

/// Tek bir dil öğesi widget'ı.
class _LanguageItem extends StatelessWidget {
  final LanguageSkill language;

  const _LanguageItem({required this.language});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final width = isMobile ? double.infinity : 250.0;
    final percent = language.proficiencyPercent ?? _getLevelPercent(language.level);

    return SizedBox(
      width: isMobile ? null : width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dil adı ve seviye
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.language,
                    size: 18,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    language.language,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  language.level,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getColorForPercent(percent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Seviye metninden yüzde hesapla
  int _getLevelPercent(String level) {
    final upperLevel = level.toUpperCase();
    if (upperLevel.contains('C2') || upperLevel.contains('ANADİL') || upperLevel.contains('NATIVE')) {
      return 100;
    } else if (upperLevel.contains('C1')) {
      return 85;
    } else if (upperLevel.contains('B2')) {
      return 70;
    } else if (upperLevel.contains('B1')) {
      return 55;
    } else if (upperLevel.contains('A2')) {
      return 40;
    } else if (upperLevel.contains('A1')) {
      return 25;
    }
    return 50; // Varsayılan
  }

  /// Yüzdeye göre renk döndür
  Color _getColorForPercent(int percent) {
    if (percent >= 80) {
      return AppTheme.accentGreen;
    } else if (percent >= 60) {
      return AppTheme.accent;
    } else if (percent >= 40) {
      return AppTheme.accentOrange;
    }
    return AppTheme.textMuted;
  }
}
