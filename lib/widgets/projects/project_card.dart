import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/project.dart';

/// Proje kartı bileşeni.
/// 
/// Proje listelerinde kullanılan interaktif kart widget'ı.
/// Tıklandığında proje detay sayfasına yönlendirir.
/// 
/// Özellikler:
/// - Hover efekti (yukarı kayma + gölge)
/// - Kategori renk kodlaması
/// - Öne çıkan projeler için yıldız badge'i
/// - Teknoloji etiketleri
/// 
/// [compact] parametresi ile daha küçük boyutta kullanılabilir.
class ProjectCard extends StatefulWidget {
  /// Gösterilecek proje verisi
  final Project project;
  
  /// Kompakt mod - daha küçük thumbnail ve az detay
  final bool compact;
  
  const ProjectCard({
    super.key,
    required this.project,
    this.compact = false,
  });
  
  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  /// Mouse kart üzerinde mi?
  bool _isHovered = false;
  
  /// Projenin kategorisine göre tema rengini döndürür
  Color get categoryColor {
    switch (widget.project.category) {
      case ProjectCategory.electronics:
        return AppTheme.electronics;
      case ProjectCategory.mechanical:
        return AppTheme.mechanical;
      case ProjectCategory.software:
        return AppTheme.software;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.projectDetailPath(widget.project.id)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          // Hover'da yukarı kayma efekti
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? categoryColor.withOpacity(0.5) : AppTheme.border,
              width: 1,
            ),
            // Hover'da kategori renginde gölge
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: categoryColor.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // THUMBNAIL ALANI
              // ============================================================
              Container(
                height: widget.compact ? 120 : 160,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(7),
                  ),
                ),
                child: Stack(
                  children: [
                    // Placeholder ikon (gerçek resim olmadığında)
                    Center(
                      child: Icon(
                        _getCategoryIcon(),
                        size: 48,
                        color: categoryColor.withOpacity(0.3),
                      ),
                    ),
                    
                    // Sol üst: Kategori badge'i
                    Positioned(
                      top: Spacing.sm,
                      left: Spacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: Spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.project.category.displayName,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.background,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    // Sağ üst: Öne çıkan projeler için yıldız
                    if (widget.project.featured)
                      Positioned(
                        top: Spacing.sm,
                        right: Spacing.sm,
                        child: Container(
                          padding: const EdgeInsets.all(Spacing.xs),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.star,
                            size: 14,
                            color: AppTheme.background,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // ============================================================
              // İÇERİK ALANI
              // ============================================================
              Padding(
                padding: EdgeInsets.all(widget.compact ? Spacing.md : Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Proje başlığı
                    Text(
                      widget.project.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xs),
                    
                    // Proje açıklaması
                    Text(
                      widget.project.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Kompakt modda etiketler gizlenir
                    if (!widget.compact) ...[
                      const SizedBox(height: Spacing.md),
                      // Teknoloji etiketleri (max 3)
                      Wrap(
                        spacing: Spacing.xs,
                        runSpacing: Spacing.xs,
                        children: widget.project.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: Spacing.md),
                    
                    // Alt bilgi satırı
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tarih
                        Text(
                          _formatDate(widget.project.date),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                        // Hover'da "Detaylar" linki görünür
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isHovered ? 1 : 0,
                          child: Row(
                            children: [
                              Text(
                                'Detaylar',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: categoryColor,
                                ),
                              ),
                              const SizedBox(width: Spacing.xs),
                              Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: categoryColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Kategoriye göre placeholder ikon döndürür
  IconData _getCategoryIcon() {
    switch (widget.project.category) {
      case ProjectCategory.electronics:
        return Icons.memory;
      case ProjectCategory.mechanical:
        return Icons.settings;
      case ProjectCategory.software:
        return Icons.code;
    }
  }
  
  /// Tarihi kısa Türkçe formatına çevirir
  /// Örnek: DateTime(2024, 6, 15) => "Haz 2024"
  String _formatDate(DateTime date) {
    final months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
