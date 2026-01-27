import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../data/projects_data.dart';
import '../models/project.dart';
import '../utils/responsive.dart';

/// Tek bir projenin detaylı dokümantasyonunu gösteren sayfa.
/// 
/// Bu sayfa, proje dokümantasyon şablonunu görsel olarak sunar:
/// 1. Problem / Amaç
/// 2. Yaklaşım
/// 3. Uygulama
/// 4. Sonuçlar
/// 5. Öğrenilenler
/// 
/// URL parametresi olarak [projectId] alır ve ilgili projeyi
/// [sampleProjects] listesinden bulur.
class ProjectDetailScreen extends StatelessWidget {
  /// Görüntülenecek projenin benzersiz ID'si.
  /// URL'den çıkarılır: /projects/:id
  final String projectId;
  
  const ProjectDetailScreen({super.key, required this.projectId});
  
  @override
  Widget build(BuildContext context) {
    // Proje verilerinden ilgili projeyi bul
    final project = sampleProjects.firstWhere(
      (p) => p.id == projectId,
      orElse: () => throw Exception('Project not found'),
    );
    
    final isDesktop = Responsive.isDesktop(context);
    
    // Kategori rengini belirle
    Color categoryColor;
    switch (project.category) {
      case ProjectCategory.electronics:
        categoryColor = AppTheme.electronics;
      case ProjectCategory.mechanical:
        categoryColor = AppTheme.mechanical;
      case ProjectCategory.software:
        categoryColor = AppTheme.software;
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.xl),
      child: ContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Geri butonu - projelere dön
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.projects),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Projelere Dön'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            
            // Proje başlık alanı - kategori etiketi ve tarih
            Row(
              children: [
                // Kategori etiketi
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: categoryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        project.category.icon,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        project.category.displayName,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: categoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.md),
                // Proje tarihi
                Text(
                  _formatDate(project.date),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            
            // Proje başlığı
            Text(
              project.title,
              style: isDesktop 
                  ? Theme.of(context).textTheme.displayMedium
                  : Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: Spacing.sm),
            
            // Proje alt başlığı
            Text(
              project.subtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: Spacing.lg),
            
            // Kullanılan teknolojiler
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: project.technologies.map((tech) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    tech,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: Spacing.lg),
            
            // Harici linkler (GitHub, Demo)
            if (project.githubUrl != null || project.demoUrl != null)
              Row(
                children: [
                  if (project.githubUrl != null)
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.code, size: 18),
                      label: const Text('Kaynak Kod'),
                    ),
                  if (project.githubUrl != null && project.demoUrl != null)
                    const SizedBox(width: Spacing.md),
                  if (project.demoUrl != null)
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Demo'),
                    ),
                ],
              ),
            
            const SizedBox(height: Spacing.xxl),
            const Divider(),
            const SizedBox(height: Spacing.xxl),
            
            // ============================================================
            // DOKÜMANTASYON BÖLÜMLERİ
            // 5 bölümlük proje anlatım şablonu
            // ============================================================
            
            _DocumentationSection(
              number: '01',
              title: 'Problem / Amaç',
              content: project.problem,
              color: categoryColor,
            ),
            _DocumentationSection(
              number: '02',
              title: 'Yaklaşım',
              content: project.approach,
              color: categoryColor,
            ),
            _DocumentationSection(
              number: '03',
              title: 'Uygulama',
              content: project.implementation,
              color: categoryColor,
            ),
            _DocumentationSection(
              number: '04',
              title: 'Sonuçlar',
              content: project.results,
              color: categoryColor,
            ),
            _DocumentationSection(
              number: '05',
              title: 'Öğrenilenler',
              content: project.lessonsLearned,
              color: categoryColor,
              isLast: true,
            ),
            
            SizedBox(height: Spacing.sectionPadding),
          ],
        ),
      ),
    );
  }
  
  /// DateTime'ı Türkçe tarih formatına çevirir.
  /// Örnek: DateTime(2024, 6, 15) => "Haziran 2024"
  String _formatDate(DateTime date) {
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Proje dokümantasyonunun tek bir bölümünü gösteren widget.
/// 
/// Sol tarafta numaralı gösterge ve bağlantı çizgisi,
/// sağ tarafta başlık ve içerik container'ı bulunur.
/// 
/// [number] - Bölüm numarası (01-05)
/// [title] - Bölüm başlığı
/// [content] - Markdown benzeri içerik metni
/// [color] - Kategori rengi
/// [isLast] - Son bölüm mü? (bağlantı çizgisini gizler)
class _DocumentationSection extends StatelessWidget {
  final String number;
  final String title;
  final String content;
  final Color color;
  final bool isLast;
  
  const _DocumentationSection({
    required this.number,
    required this.title,
    required this.content,
    required this.color,
    this.isLast = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : Spacing.xxl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol taraf - numara göstergesi ve bağlantı çizgisi
          SizedBox(
            width: 50,
            child: Column(
              children: [
                // Numaralı badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // Bölümler arası bağlantı çizgisi
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    margin: const EdgeInsets.only(top: Spacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withOpacity(0.3),
                          color.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.lg),
          
          // Sağ taraf - içerik
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bölüm başlığı
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                // İçerik container'ı
                Container(
                  padding: const EdgeInsets.all(Spacing.lg),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: _MarkdownContent(content: content),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Basit markdown benzeri metin render eden widget.
/// 
/// Desteklenen formatlar:
/// - **kalın metin** 
/// - Madde işaretleri (- ile başlayan satırlar)
/// - Numaralı listeler (1. 2. 3. ile başlayan satırlar)
/// - Paragraflar (boş satırlarla ayrılmış)
class _MarkdownContent extends StatelessWidget {
  final String content;
  
  const _MarkdownContent({required this.content});
  
  @override
  Widget build(BuildContext context) {
    final lines = content.trim().split('\n');
    final widgets = <Widget>[];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Boş satır = paragraf arası boşluk
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: Spacing.md));
        continue;
      }
      
      // Kalın metin içeren satır
      if (line.contains('**')) {
        widgets.add(_parseBoldText(context, line));
      }
      // Madde işareti ile başlayan satır
      else if (line.trim().startsWith('-')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: Spacing.md, bottom: Spacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, right: Spacing.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Text(
                    line.trim().substring(1).trim(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Numaralı liste satırı
      else if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
        final match = RegExp(r'^(\d+)\.\s*(.*)').firstMatch(line.trim());
        if (match != null) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: Spacing.md, bottom: Spacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${match.group(1)}.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _parseBoldText(context, match.group(2) ?? ''),
                  ),
                ],
              ),
            ),
          );
        }
      }
      // Normal metin satırı
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.xs),
            child: Text(
              line,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
  
  /// **kalın** metin işaretlemesini parse eder.
  /// 
  /// RichText widget'ı döndürür. Kalın kısımlar
  /// [AppTheme.textPrimary] renginde ve bold olarak gösterilir.
  Widget _parseBoldText(BuildContext context, String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;
    
    for (final match in regex.allMatches(text)) {
      // Kalın olmayan kısım
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: Theme.of(context).textTheme.bodyMedium,
        ));
      }
      // Kalın kısım
      spans.add(TextSpan(
        text: match.group(1),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ));
      lastEnd = match.end;
    }
    
    // Kalan metin
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: Theme.of(context).textTheme.bodyMedium,
      ));
    }
    
    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
