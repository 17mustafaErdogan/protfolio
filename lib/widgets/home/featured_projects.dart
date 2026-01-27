import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/data_service.dart';
import '../../utils/responsive.dart';
import '../common/section_title.dart';

/// Öne çıkan projeler bölümü.
/// 
/// Supabase'den featured=true olan projeleri yükler ve gösterir.
class FeaturedProjects extends StatefulWidget {
  const FeaturedProjects({super.key});

  @override
  State<FeaturedProjects> createState() => _FeaturedProjectsState();
}

class _FeaturedProjectsState extends State<FeaturedProjects> {
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final dataService = context.read<DataService>();
    final projects = await dataService.getProjects(featured: true);
    
    if (mounted) {
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'electronics':
        return AppTheme.electronics;
      case 'mechanical':
        return AppTheme.mechanical;
      case 'software':
        return AppTheme.software;
      default:
        return AppTheme.accent;
    }
  }

  String _getCategoryName(String? category) {
    switch (category) {
      case 'electronics':
        return 'Elektronik';
      case 'mechanical':
        return 'Mekanik';
      case 'software':
        return 'Yazılım';
      default:
        return 'Diğer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.gridColumns(context);
    
    // Proje yoksa veya yükleniyorsa boş göster
    if (_projects.isEmpty && !_isLoading) {
      return const SizedBox.shrink();
    }
    
    return ContentContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'Öne Çıkan Projeler',
            subtitle: 'En son ve en etkileyici çalışmalarım',
            trailing: TextButton(
              onPressed: () => context.go(AppRoutes.projects),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tümünü Gör',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppTheme.accent,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            // Projects Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final spacing = Spacing.lg;
                final itemWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;
                
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: _projects.map((project) {
                    return SizedBox(
                      width: columns == 1 ? constraints.maxWidth : itemWidth,
                      child: _SupabaseProjectCard(
                        project: project,
                        categoryColor: _getCategoryColor(project['category']),
                        categoryName: _getCategoryName(project['category']),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Supabase'den gelen proje verisi için kart widget'ı.
class _SupabaseProjectCard extends StatefulWidget {
  final Map<String, dynamic> project;
  final Color categoryColor;
  final String categoryName;

  const _SupabaseProjectCard({
    required this.project,
    required this.categoryColor,
    required this.categoryName,
  });

  @override
  State<_SupabaseProjectCard> createState() => _SupabaseProjectCardState();
}

class _SupabaseProjectCardState extends State<_SupabaseProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final tags = (project['tags'] as List?)?.take(3).toList() ?? [];
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.go('/projects/${project['id']}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isHovered ? AppTheme.surfaceLight : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? widget.categoryColor.withOpacity(0.3) : AppTheme.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail placeholder
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.categoryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: project['thumbnail_url'] != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          project['thumbnail_url'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.folder_outlined,
                              size: 48,
                              color: widget.categoryColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.folder_outlined,
                          size: 48,
                          color: widget.categoryColor.withOpacity(0.5),
                        ),
                      ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.categoryName,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: widget.categoryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    
                    // Title
                    Text(
                      project['title'] ?? 'Başlıksız',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xs),
                    
                    // Subtitle
                    Text(
                      project['subtitle'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.md),
                    
                    // Tags
                    if (tags.isNotEmpty)
                      Wrap(
                        spacing: Spacing.xs,
                        children: tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(
                            tag.toString(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                        )).toList(),
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
}
