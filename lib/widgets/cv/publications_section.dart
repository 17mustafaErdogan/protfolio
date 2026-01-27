import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/cv_models.dart';
import '../../utils/responsive.dart';
import '../common/section_title.dart';

/// Yayınları ve makaleleri gösteren section widget'ı.
/// 
/// Yayınları liste formatında gösterir.
/// Liste boşsa hiçbir şey render etmez.
class PublicationsSection extends StatelessWidget {
  /// Gösterilecek yayın listesi
  final List<Publication> items;

  const PublicationsSection({
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
          title: 'Yayınlar',
          subtitle: 'Akademik ve teknik yayınlar',
        ),
        const SizedBox(height: Spacing.xl),
        ...items.map((pub) => _PublicationItem(publication: pub)),
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }
}

/// Tek bir yayın öğesi widget'ı.
class _PublicationItem extends StatelessWidget {
  final Publication publication;

  const _PublicationItem({required this.publication});

  String _formatDate(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasUrl = publication.url != null;

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol ikon
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: AppTheme.software.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.article_outlined,
              color: AppTheme.software,
              size: 24,
            ),
          ),
          const SizedBox(width: Spacing.md),
          
          // İçerik
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Text(
                  publication.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                
                // Venue ve tarih
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        publication.venue,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.software,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(publication.date),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                
                // Ortak yazarlar
                if (publication.coAuthors != null && publication.coAuthors!.isNotEmpty) ...[
                  const SizedBox(height: Spacing.sm),
                  Text(
                    'Yazarlar: ${publication.coAuthors!.join(', ')}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                
                // Abstract
                if (publication.abstract != null) ...[
                  const SizedBox(height: Spacing.sm),
                  Text(
                    publication.abstract!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                // Link
                if (hasUrl) ...[
                  const SizedBox(height: Spacing.sm),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: URL açma işlemi (url_launcher paketi gerekli)
                    },
                    icon: const Icon(Icons.open_in_new, size: 14),
                    label: const Text('Yayını Görüntüle'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppTheme.accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
