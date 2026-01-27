import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/cv_models.dart';
import '../common/section_title.dart';

/// İş deneyimini timeline formatında gösteren section widget'ı.
/// 
/// Profesyonel iş geçmişini kronolojik sırayla gösterir.
/// Liste boşsa hiçbir şey render etmez.
class WorkExperienceSection extends StatelessWidget {
  /// Gösterilecek deneyim listesi
  final List<WorkExperience> items;

  const WorkExperienceSection({
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
          title: 'Deneyim',
          subtitle: 'Profesyonel iş geçmişim',
        ),
        const SizedBox(height: Spacing.xl),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final exp = entry.value;
          final isLast = index == items.length - 1;
          
          return _ExperienceTimelineItem(
            experience: exp,
            isLast: isLast,
          );
        }),
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }
}

/// Timeline'daki tek bir deneyim öğesi.
class _ExperienceTimelineItem extends StatelessWidget {
  final WorkExperience experience;
  final bool isLast;

  const _ExperienceTimelineItem({
    required this.experience,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = experience.color ?? AppTheme.accent;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sol taraf - timeline göstergesi
        Column(
          children: [
            // Renkli nokta
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: AppTheme.background,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            // Bağlantı çizgisi
            if (!isLast)
              Container(
                width: 2,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withOpacity(0.5),
                      AppTheme.border,
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: Spacing.lg),
        
        // Sağ taraf - içerik
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : Spacing.lg),
            child: Container(
              padding: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst satır: Dönem ve çalışma tipi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        experience.period,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (experience.employmentType != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            experience.employmentType!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: color,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  
                  // Pozisyon
                  Text(
                    experience.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  
                  // Şirket ve konum
                  Row(
                    children: [
                      Text(
                        experience.company,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (experience.location != null) ...[
                        const SizedBox(width: Spacing.sm),
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          experience.location!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Açıklama
                  if (experience.description != null) ...[
                    const SizedBox(height: Spacing.md),
                    Text(
                      experience.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  
                  // Öne çıkan başarılar
                  if (experience.highlights.isNotEmpty) ...[
                    const SizedBox(height: Spacing.md),
                    ...experience.highlights.map((highlight) => Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.arrow_right,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: Spacing.xs),
                          Expanded(
                            child: Text(
                              highlight,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
