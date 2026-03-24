import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/data_service.dart';
import '../utils/responsive.dart';
import '../widgets/common/section_title.dart';

/// Tüm projelerin listelendiği sayfa.
///
/// Kategori filtreleme expertise_areas tablosundan dinamik olarak yüklenir.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String? _selectedAreaId;
  List<Map<String, dynamic>> _allProjects = [];
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
      ds.getProjects(),
      ds.getExpertiseAreas(),
    ]);
    if (mounted) {
      setState(() {
        _allProjects = (results[0] as List).cast<Map<String, dynamic>>();
        _expertiseAreas = (results[1] as List).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredProjects {
    if (_selectedAreaId == null) return _allProjects;
    return _allProjects
        .where((p) => p['expertise_area_id'] == _selectedAreaId)
        .toList();
  }

  Map<String, dynamic>? _areaById(String? id) {
    if (id == null) return null;
    return _expertiseAreas.firstWhere(
      (a) => a['id'] == id,
      orElse: () => {},
    );
  }

  Color _areaColor(String? areaId) {
    final hex =
        (_areaById(areaId)?['color'] as String?)?.replaceFirst('#', '') ?? '';
    try {
      return Color(0xFF000000 | int.parse(hex, radix: 16));
    } catch (_) {
      return AppTheme.accent;
    }
  }

  String _areaName(String? areaId) =>
      (_areaById(areaId)?['name'] as String?) ?? '';

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.gridColumns(context);
    final sectionPadding = Responsive.sectionPadding(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.xxl),
      child: ContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Projeler',
              subtitle: 'Tasarladığım, geliştirdiğim ve hayata geçirdiğim projeler',
            ),
            const SizedBox(height: Spacing.xl),

            _buildCategoryFilter(),
            const SizedBox(height: Spacing.xl),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.xxl),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              Text(
                '${filteredProjects.length} proje',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.textMuted),
              ),
              const SizedBox(height: Spacing.lg),

              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = Spacing.lg;
                  final itemWidth =
                      (constraints.maxWidth - (spacing * (columns - 1))) /
                          columns;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: filteredProjects.map((project) {
                      final areaId =
                          project['expertise_area_id'] as String?;
                      return SizedBox(
                        width:
                            columns == 1 ? constraints.maxWidth : itemWidth,
                        child: _ProjectCard(
                          project: project,
                          categoryColor: _areaColor(areaId),
                          categoryName: _areaName(areaId).isEmpty
                              ? 'Proje'
                              : _areaName(areaId),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              if (filteredProjects.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.xxl),
                    child: Column(
                      children: [
                        Icon(Icons.folder_open,
                            size: 64, color: AppTheme.textMuted),
                        const SizedBox(height: Spacing.md),
                        Text(
                          'Bu alanda henüz proje yok',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
            
              ],

            SizedBox(height: sectionPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        // "Tümü" chip'i
        _buildFilterChip(
          label: 'Tümü',
          areaId: null,
          color: AppTheme.accent,
        ),
        // Dinamik alan chip'leri
        ..._expertiseAreas.map((area) {
          final id = area['id'] as String;
          final name = area['name'] as String? ?? '';
          final color = _areaColor(id);
          return _buildFilterChip(label: name, areaId: id, color: color);
        }),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String? areaId,
    required Color color,
  }) {
    final isSelected = _selectedAreaId == areaId;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) =>
          setState(() => _selectedAreaId = selected ? areaId : null),
      selectedColor: color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? color : AppTheme.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: isSelected ? color : AppTheme.border),
      ),
      backgroundColor: AppTheme.surface,
    );
  }
}

/// Proje kartı widget'ı.
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
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: widget.categoryColor),
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
