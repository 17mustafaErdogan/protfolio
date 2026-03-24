import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Hero bölümündeki uzmanlık alanları chip satırı.
///
/// [areas] boşsa gösterilmez. Doldukça dinamik olarak Supabase'den gelir.
class HeroSpecialtiesRow extends StatelessWidget {
  final List<Map<String, dynamic>> areas;

  const HeroSpecialtiesRow({super.key, required this.areas});

  @override
  Widget build(BuildContext context) {
    if (areas.isEmpty) return const SizedBox.shrink();

    final chips = <Widget>[];
    for (var i = 0; i < areas.length; i++) {
      chips.add(_SpecialtyChip(area: areas[i]));
      if (i < areas.length - 1) {
        chips.add(Text('•', style: TextStyle(color: AppTheme.textMuted)));
      }
    }

    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: chips,
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  final Map<String, dynamic> area;

  const _SpecialtyChip({required this.area});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(area['color'] as String? ?? '#58A6FF');
    final name = area['name'] as String? ?? '';

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
        name,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceFirst('#', '');
      final value = int.parse(clean, radix: 16);
      return Color(0xFF000000 | value);
    } catch (_) {
      return const Color(0xFF58A6FF);
    }
  }
}
