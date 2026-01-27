import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/cv_models.dart';
import '../../utils/responsive.dart';
import '../common/section_title.dart';

/// Başarı ve ödülleri gösteren section widget'ı.
/// 
/// Başarıları kart formatında gösterir.
/// Liste boşsa hiçbir şey render etmez.
class AchievementsSection extends StatelessWidget {
  /// Gösterilecek başarı listesi
  final List<Achievement> items;

  const AchievementsSection({
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
          title: 'Başarılar',
          subtitle: 'Ödüller ve öne çıkan başarılar',
        ),
        const SizedBox(height: Spacing.xl),
        Wrap(
          spacing: Spacing.md,
          runSpacing: Spacing.md,
          children: items.map((achievement) => _AchievementCard(achievement: achievement)).toList(),
        ),
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }
}

/// Tek bir başarı kartı widget'ı.
class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  String _formatDate(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.isMobile(context) ? double.infinity : 350,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surface,
            AppTheme.accentOrange.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Üst satır: ikon ve tarih
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: AppTheme.accentOrange,
                  size: 24,
                ),
              ),
              if (achievement.date != null)
                Text(
                  _formatDate(achievement.date!),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          
          // Başlık
          Text(
            achievement.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Organizasyon
          if (achievement.organization != null) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              achievement.organization!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.accentOrange,
              ),
            ),
          ],
          
          // Açıklama
          const SizedBox(height: Spacing.sm),
          Text(
            achievement.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
