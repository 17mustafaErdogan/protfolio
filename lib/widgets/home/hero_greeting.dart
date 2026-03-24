import 'package:flutter/material.dart';
import '../../config/theme.dart';

class HeroGreeting extends StatelessWidget {
  final String name;
  final bool isDesktop;
  final bool isLoading;
  final double nameFontSize;

  const HeroGreeting({
    super.key,
    required this.name,
    required this.isDesktop,
    required this.isLoading,
    required this.nameFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Merhaba, ben',
          style: textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        if (isLoading)
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
            style: (isDesktop ? textTheme.displayLarge : textTheme.displayMedium)
                ?.copyWith(fontSize: nameFontSize),
          ),
      ],
    );
  }
}

