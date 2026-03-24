import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Hero bölümündeki istatistik satırı.
///
/// Proje sayısını ve her uzmanlık alanını "Ad · X yıl" formatında gösterir.
/// Veriler Supabase'den otomatik hesaplanır.
class HeroStatsRow extends StatelessWidget {
  final int projectCount;
  final List<Map<String, dynamic>> expertiseAreas;

  const HeroStatsRow({
    super.key,
    required this.projectCount,
    required this.expertiseAreas,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.xl,
      runSpacing: Spacing.md,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        _StatItem(
          value: '$projectCount+',
          label: 'Proje',
          color: AppTheme.accent,
        ),
        ...expertiseAreas.map((area) {
          final color = _parseColor(area['color'] as String? ?? '#58A6FF');
          final years = area['years'] as int? ?? 0;
          return _StatItem(
            value: '${years > 0 ? years : '<1'} yıl',
            label: area['name'] as String? ?? '',
            color: color,
          );
        }),
      ],
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceFirst('#', '');
      final value = int.parse(clean, radix: 16);
      return Color(0xFF000000 | value);
    } catch (_) {
      return AppTheme.accent;
    }
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
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
