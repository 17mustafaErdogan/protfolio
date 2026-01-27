import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/cv_models.dart';
import '../../utils/responsive.dart';
import '../common/section_title.dart';

/// Referansları gösteren section widget'ı.
/// 
/// Referansları kart formatında gösterir.
/// Liste boşsa hiçbir şey render etmez.
/// 
/// Not: Referans bilgileri genellikle gizli tutulur ve
/// "İstek üzerine paylaşılır" şeklinde gösterilir.
class ReferencesSection extends StatelessWidget {
  /// Gösterilecek referans listesi
  final List<Reference> items;
  
  /// Referansları gizle ve sadece "İstek üzerine" mesajı göster
  final bool hideDetails;

  const ReferencesSection({
    super.key,
    required this.items,
    this.hideDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    // Liste boşsa hiçbir şey gösterme
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Referanslar',
          subtitle: 'Profesyonel referanslar',
        ),
        const SizedBox(height: Spacing.xl),
        
        if (hideDetails)
          // Gizli mod: Sadece mesaj göster
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.people_outline,
                    color: AppTheme.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${items.length} referans mevcut',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        'Referans bilgileri istek üzerine paylaşılmaktadır.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          // Açık mod: Tüm referansları göster
          Wrap(
            spacing: Spacing.md,
            runSpacing: Spacing.md,
            children: items.map((ref) => _ReferenceCard(reference: ref)).toList(),
          ),
        
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }
}

/// Tek bir referans kartı widget'ı.
class _ReferenceCard extends StatelessWidget {
  final Reference reference;

  const _ReferenceCard({required this.reference});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.isMobile(context) ? double.infinity : 300,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // İsim
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.accent.withOpacity(0.1),
                child: Text(
                  reference.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reference.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      reference.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          
          // Şirket
          Row(
            children: [
              const Icon(
                Icons.business_outlined,
                size: 14,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  reference.company,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
          
          // İlişki
          if (reference.relationship != null) ...[
            const SizedBox(height: Spacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.handshake_outlined,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  reference.relationship!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ],
          
          // İletişim bilgileri
          if (reference.email != null || reference.phone != null) ...[
            const SizedBox(height: Spacing.md),
            const Divider(),
            const SizedBox(height: Spacing.sm),
            if (reference.email != null)
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    reference.email!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            if (reference.phone != null) ...[
              const SizedBox(height: Spacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    reference.phone!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
