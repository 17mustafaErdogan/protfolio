import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/home/hero_section.dart';
import '../widgets/home/featured_projects.dart';
import '../widgets/home/skills_section.dart';

/// Ana sayfa ekranı.
/// 
/// Tamamen portfolyo odaklı içerik gösterir:
/// - Tanıtım (Hero)
/// - Öne çıkan projeler
/// - Teknik beceriler
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ============================================================
        // TANITIM BÖLÜMÜ
        // ============================================================
        const HeroSection(),
        SizedBox(height: Spacing.sectionPadding),
        
        // ============================================================
        // ÖNE ÇIKAN PROJELER
        // ============================================================
        const FeaturedProjects(),
        SizedBox(height: Spacing.sectionPadding),
        
        // ============================================================
        // TEKNİK BECERİLER
        // ============================================================
        const SkillsSection(),
        SizedBox(height: Spacing.sectionPadding),
      ],
    );
  }
}
