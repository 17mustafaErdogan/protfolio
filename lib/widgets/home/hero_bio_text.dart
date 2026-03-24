import 'package:flutter/material.dart';

class HeroBioText extends StatelessWidget {
  final String bio;
  final bool isDesktop;
  final double bodyFontSize;

  const HeroBioText({
    super.key,
    required this.bio,
    required this.isDesktop,
    required this.bodyFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isDesktop ? 600 : double.infinity,
      child: Text(
        bio,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: bodyFontSize,
            ),
      ),
    );
  }
}

