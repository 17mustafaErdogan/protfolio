import 'package:flutter/material.dart';
import '../../config/theme.dart';

class HeroWindowChrome extends StatelessWidget {
  const HeroWindowChrome({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _WindowDot(color: AppTheme.accentRed),
          SizedBox(width: Spacing.sm),
          _WindowDot(color: AppTheme.accentOrange),
          SizedBox(width: Spacing.sm),
          _WindowDot(color: AppTheme.accentGreen),
          SizedBox(width: Spacing.sm),
          Text(
            '~/portfolio',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: FontSize.small,
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  final Color color;

  const _WindowDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Spacing.xsm,
      height: Spacing.xsm,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppBorderRadius.xsmall),
      ),
    );
  }
}

