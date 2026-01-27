import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/data_service.dart';
import '../utils/responsive.dart';
import '../widgets/common/section_title.dart';

/// Tüm projelerin listelendiği sayfa.
/// 
/// Bu sayfa şu özellikleri içerir:
/// - Kategori filtreleme (Tümü/Elektronik/Mekanik/Yazılım)
/// - Responsive grid layout
/// - Supabase'den dinamik veri yükleme
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});
  
  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String? _selectedCategory;
  List<Map<String, dynamic>> _allProjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final dataService = context.read<DataService>();
    final projects = await dataService.getProjects();
    
    if (mounted) {
      setState(() {
        _allProjects = projects;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredProjects {
    if (_selectedCategory == null) {
      return _allProjects;
    }
    return _allProjects.where((p) => p['category'] == _selectedCategory).toList();
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
        return 'Tümü';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final columns = Responsive.gridColumns(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.xxl),
      child: ContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sayfa başlığı
            const SectionTitle(
              title: 'Projeler',
              subtitle: 'Tasarladığım, geliştirdiğim ve hayata geçirdiğim projeler',
            ),
            const SizedBox(height: Spacing.xl),
            
            // Kategori filtre butonları
            _buildCategoryFilter(),
            const SizedBox(height: Spacing.xl),
            
            // Yükleniyor durumu
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.xxl),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              // Filtrelenmiş proje sayısı
              Text(
                '${filteredProjects.length} proje',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: Spacing.lg),
              
              // Responsive proje kartları grid'i
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = Spacing.lg;
                  final itemWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;
                  
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: filteredProjects.map((project) {
                      return SizedBox(
                        width: columns == 1 ? constraints.maxWidth : itemWidth,
                        child: _ProjectCard(
                          project: project,
                          categoryColor: _getCategoryColor(project['category']),
                          categoryName: _getCategoryName(project['category']),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              
              // Boş durum
              if (filteredProjects.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.xxl),
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(height: Spacing.md),
                        Text(
                          'Bu kategoride henüz proje yok',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
              
            SizedBox(height: Spacing.sectionPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      (null, 'Tümü'),
      ('electronics', 'Elektronik'),
      ('mechanical', 'Mekanik'),
      ('software', 'Yazılım'),
    ];

    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: categories.map((cat) {
        final isSelected = _selectedCategory == cat.$1;
        final color = cat.$1 != null ? _getCategoryColor(cat.$1) : AppTheme.accent;
        
        return ChoiceChip(
          label: Text(cat.$2),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = selected ? cat.$1 : null;
            });
          },
          selectedColor: color.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? color : AppTheme.textSecondary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? color : AppTheme.border,
            ),
          ),
          backgroundColor: AppTheme.surface,
        );
      }).toList(),
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
              color: _isHovered ? widget.categoryColor.withOpacity(0.3) : AppTheme.border,
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
