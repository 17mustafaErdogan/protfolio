import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/cv_models.dart';
import '../../utils/open_url.dart';
import '../../utils/responsive.dart';
import '../common/section_title.dart';

/// Sertifikaları gösteren section widget'ı.
/// 
/// Sertifikaları yatay kaydırılabilir kart listesi olarak gösterir.
/// Liste boşsa hiçbir şey render etmez.
class CertificatesSection extends StatelessWidget {
  /// Gösterilecek sertifika listesi
  final List<Certificate> items;

  const CertificatesSection({
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
          title: 'Sertifikalar',
          subtitle: 'Profesyonel sertifikalar ve kurslar',
        ),
        const SizedBox(height: Spacing.xl),
        Wrap(
          spacing: Spacing.md,
          runSpacing: Spacing.md,
          children: items.map((cert) => _CertificateCard(certificate: cert)).toList(),
        ),
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }
}

/// Tek bir sertifika kartı widget'ı.
class _CertificateCard extends StatelessWidget {
  final Certificate certificate;

  const _CertificateCard({required this.certificate});

  String _formatDate(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasUrl = certificate.credentialUrl != null;

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
          // Sertifika adı
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_outlined,
                  color: AppTheme.accentGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificate.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      certificate.issuer,
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
          
          // Tarih ve doğrulama linki
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(certificate.date),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
              if (hasUrl)
                TextButton.icon(
                  onPressed: () => tryLaunchUrlString(
                    certificate.credentialUrl,
                    context: context,
                  ),
                  icon: const Icon(Icons.open_in_new, size: 14),
                  label: const Text('Doğrula'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppTheme.accent,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
