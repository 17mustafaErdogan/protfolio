import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/cv_models.dart';
import '../../utils/responsive.dart';
import '../common/section_title.dart';

/// Eğitim bilgilerini gösteren section widget'ı.
/// 
/// Eğitim geçmişini kart formatında grid olarak gösterir.
/// Liste boşsa hiçbir şey render etmez.
class EducationSection extends StatelessWidget {
  /// Gösterilecek eğitim listesi
  final List<Education> items;

  const EducationSection({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Liste boşsa hiçbir şey gösterme
    if (items.isEmpty) return const SizedBox.shrink();

    final crossAxisCount = Responsive.isDesktop(context) ? 2 : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Eğitim',
          subtitle: 'Akademik geçmişim',
        ),
        const SizedBox(height: Spacing.xl),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: Spacing.lg,
            mainAxisSpacing: Spacing.lg,
            mainAxisExtent: 180,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _EducationCard(education: items[index]),
        ),
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }
}

/// Tek bir eğitim kartı widget'ı.
class _EducationCard extends StatelessWidget {
  final Education education;

  const _EducationCard({required this.education});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Derece ve dönem
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  education.degree,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  education.period,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          
          // Bölüm
          Text(
            education.field,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: Spacing.xs),
          
          // Kurum
          Row(
            children: [
              const Icon(
                Icons.school_outlined,
                size: 16,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  education.institution,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          // GPA (varsa)
          if (education.gpa != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              'GPA: ${education.gpa}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
          
          // Açıklama (varsa)
          if (education.description != null) ...[
            const SizedBox(height: Spacing.sm),
            Expanded(
              child: Text(
                education.description!,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
