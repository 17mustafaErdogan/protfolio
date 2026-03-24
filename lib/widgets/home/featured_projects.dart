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
/// Kategori rengi ve adı expertise_areas tablosundan dinamik olarak alınır.
class FeaturedProjects extends StatefulWidget {
  const FeaturedProjects({super.key});

  @override
  State<FeaturedProjects> createState() => _FeaturedProjectsState();
}

class _FeaturedProjectsState extends State<FeaturedProjects> {
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _expertiseAreas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = context.read<DataService>();
    final results = await Future.wait([
      ds.getProjects(featured: true),
      ds.getExpertiseAreas(),
    ]);
    if (mounted) {
      setState(() {
        _projects = (results[0] as List).cast<Map<String, dynamic>>();
        _expertiseAreas = (results[1] as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? _areaOf(Map<String, dynamic> project) {
    final areaId = project['expertise_area_id'] as String?;
    if (areaId == null) return null;
    return _expertiseAreas.firstWhere(
      (a) => a['id'] == areaId,
      orElse: () => {},
    );
  }

  Color _colorOf(Map<String, dynamic>? area) {
    final hex = (area?['color'] as String?)?.replaceFirst('#', '') ?? '';
    try {
      return Color(0xFF000000 | int.parse(hex, radix: 16));
    } catch (_) {
      return AppTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.gridColumns(context);

    if (_projects.isEmpty && !_isLoading) return const SizedBox.shrink();

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
                  const Icon(Icons.arrow_forward, size: 16, color: AppTheme.accent),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final spacing = Spacing.lg;
                final itemWidth = (constraints.maxWidth -
                        (spacing * (columns - 1))) /
                    columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: _projects.map((project) {
                    final area = _areaOf(project);
                    final color = _colorOf(area);
                    final areaName = (area?['name'] as String?) ?? '';
                    return SizedBox(
                      width: columns == 1 ? constraints.maxWidth : itemWidth,
                      child: _ProjectCard(
                        project: project,
                        categoryColor: color,
                        categoryName:
                            areaName.isEmpty ? 'Proje' : areaName,
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

class _ProjectCard extends StatefulWidget {
  final Map<String, dynamic> project;
  final Color categoryColor;
  final String categoryName;

  const _ProjectCard({
    required this.project,
    required this.categoryColor,
    required this.categoryName,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
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
              color: _isHovered
                  ? widget.categoryColor.withOpacity(0.3)
                  : AppTheme.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
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
                            child: Icon(Icons.folder_outlined,
                                size: 48,
                                color: widget.categoryColor.withOpacity(0.5)),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.folder_outlined,
                            size: 48,
                            color: widget.categoryColor.withOpacity(0.5)),
                      ),
              ),

              // İçerik
              Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm, vertical: 2),
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

                    // Başlık
                    Text(
                      project['title'] ?? 'Başlıksız',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xs),

                    // Alt başlık
                    Text(
                      project['subtitle'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.md),

                    // Etiketler
                    if (tags.isNotEmpty)
                      Wrap(
                        spacing: Spacing.xs,
                        children: tags
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: Spacing.xs, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.background,
                                    borderRadius: BorderRadius.circular(4),
                                    border:
                                        Border.all(color: AppTheme.border),
                                  ),
                                  child: Text(
                                    tag.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: AppTheme.textMuted),
                                  ),
                                ))
                            .toList(),
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
