import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/data_service.dart';
import '../../utils/responsive.dart';

/// Proje yönetimi ekranı.
/// 
/// Projeleri listeler ve CRUD işlemleri sağlar.
class ProjectsAdminScreen extends StatefulWidget {
  const ProjectsAdminScreen({super.key});

  @override
  State<ProjectsAdminScreen> createState() => _ProjectsAdminScreenState();
}

class _ProjectsAdminScreenState extends State<ProjectsAdminScreen> {
  List<Map<String, dynamic>> _projects = [];
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
        _projects = projects;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProject(String id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Projeyi Sil'),
        content: Text('"$title" projesini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final dataService = context.read<DataService>();
      final success = await dataService.deleteProject(id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proje silindi'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        _loadProjects();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve buton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Projeler',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    '${_projects.length} proje',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/admin/projects/new'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Yeni Proje'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.background,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),
          
          // Proje listesi
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_projects.isEmpty)
            _buildEmptyState()
          else
            _buildProjectsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          children: [
            Icon(
              Icons.folder_off_outlined,
              size: 64,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'Henüz proje eklenmemiş',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: Spacing.md),
            ElevatedButton.icon(
              onPressed: () => context.go('/admin/projects/new'),
              icon: const Icon(Icons.add),
              label: const Text('İlk Projeyi Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.background,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
      itemBuilder: (context, index) {
        final project = _projects[index];
        return _ProjectListItem(
          project: project,
          onEdit: () => context.go('/admin/projects/${project['id']}/edit'),
          onDelete: () => _deleteProject(project['id'], project['title']),
        );
      },
    );
  }
}

/// Proje listesi öğesi.
class _ProjectListItem extends StatefulWidget {
  final Map<String, dynamic> project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectListItem({
    required this.project,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ProjectListItem> createState() => _ProjectListItemState();
}

class _ProjectListItemState extends State<_ProjectListItem> {
  bool _isHovered = false;

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
    final color = _getCategoryColor(widget.project['category']);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: _isHovered ? AppTheme.surfaceLight : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            // Kategori rengi göstergesi
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: Spacing.lg),
            
            // Proje bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.project['title'] ?? 'Başlıksız',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.project['featured'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Öne Çıkan',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.accentOrange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    widget.project['subtitle'] ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getCategoryName(widget.project['category']),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      if (widget.project['date'] != null)
                        Text(
                          widget.project['date'].toString().substring(0, 10),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Aksiyonlar
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: widget.onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Düzenle',
                  color: AppTheme.textSecondary,
                ),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Sil',
                  color: Colors.red.withOpacity(0.7),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
