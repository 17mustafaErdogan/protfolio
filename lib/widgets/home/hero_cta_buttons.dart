import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';

class HeroCtaButtons extends StatelessWidget {
  const HeroCtaButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.md,
      runSpacing: Spacing.md,
      children: [
        ElevatedButton(
          onPressed: () => context.go(AppRoutes.projects),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Projeleri Gör'),
              SizedBox(width: Spacing.sm),
              Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () => context.go(AppRoutes.contact),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.mail_outline, size: 18),
              SizedBox(width: Spacing.sm),
              Text('İletişime Geç'),
            ],
          ),
        ),
      ],
    );
  }
}

