import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/data_service.dart';

/// Beceri yönetimi ekranı.
class SkillsAdminScreen extends StatefulWidget {
  const SkillsAdminScreen({super.key});

  @override
  State<SkillsAdminScreen> createState() => _SkillsAdminScreenState();
}

class _SkillsAdminScreenState extends State<SkillsAdminScreen> {
  List<Map<String, dynamic>> _skills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    final dataService = context.read<DataService>();
    final skills = await dataService.getSkills();
    
    if (mounted) {
      setState(() {
        _skills = skills;
        _isLoading = false;
      });
    }
  }

  Future<void> _showSkillDialog([Map<String, dynamic>? skill]) async {
    final isEdit = skill != null;
    final nameController = TextEditingController(text: skill?['name'] ?? '');
    final descController = TextEditingController(text: skill?['description'] ?? '');
    String category = skill?['category'] ?? 'electronics';
    int proficiency = skill?['proficiency_percent'] ?? 50;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(isEdit ? 'Beceri Düzenle' : 'Yeni Beceri'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Beceri Adı',
                    hintText: 'PCB Tasarımı',
                  ),
                ),
                const SizedBox(height: Spacing.md),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    hintText: 'KiCad, Altium Designer ile şematik ve layout',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: Spacing.md),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: const [
                    DropdownMenuItem(value: 'electronics', child: Text('Elektronik')),
                    DropdownMenuItem(value: 'mechanical', child: Text('Mekanik')),
                    DropdownMenuItem(value: 'software', child: Text('Yazılım')),
                  ],
                  onChanged: (value) => setDialogState(() => category = value!),
                  dropdownColor: AppTheme.surface,
                ),
                const SizedBox(height: Spacing.lg),
                Row(
                  children: [
                    const Text('Yeterlilik: '),
                    Text('$proficiency%', style: TextStyle(color: AppTheme.accent)),
                  ],
                ),
                Slider(
                  value: proficiency.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  activeColor: AppTheme.accent,
                  onChanged: (value) => setDialogState(() => proficiency = value.round()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                
                final data = {
                  'name': nameController.text.trim(),
                  'description': descController.text.trim(),
                  'category': category,
                  'proficiency_percent': proficiency,
                };
                
                final dataService = context.read<DataService>();
                bool success;
                
                if (isEdit) {
                  success = await dataService.updateSkill(skill!['id'], data);
                } else {
                  success = await dataService.createSkill(data);
                }
                
                if (success && mounted) {
                  Navigator.pop(context);
                  _loadSkills();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? 'Beceri güncellendi' : 'Beceri eklendi'),
                      backgroundColor: AppTheme.accentGreen,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
              ),
              child: Text(isEdit ? 'Güncelle' : 'Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSkill(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Beceriyi Sil'),
        content: Text('"$name" becerisini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final dataService = context.read<DataService>();
      await dataService.deleteSkill(id);
      _loadSkills();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Beceriler',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showSkillDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Yeni Beceri'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.background,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_skills.isEmpty)
            _buildEmptyState()
          else
            ..._buildSkillsByCategory(),
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
            Icon(Icons.psychology_outlined, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: Spacing.lg),
            Text(
              'Henüz beceri eklenmemiş',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSkillsByCategory() {
    final categories = {
      'electronics': ('Elektronik', AppTheme.electronics),
      'mechanical': ('Mekanik', AppTheme.mechanical),
      'software': ('Yazılım', AppTheme.software),
    };

    return categories.entries.map((entry) {
      final categorySkills = _skills.where((s) => s['category'] == entry.key).toList();
      if (categorySkills.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: Spacing.xl),
        padding: const EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: entry.value.$2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Text(
                  entry.value.$1,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: entry.value.$2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            ...categorySkills.map((skill) => _buildSkillItem(skill, entry.value.$2)),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSkillItem(Map<String, dynamic> skill, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill['name'] ?? '',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (skill['description'] != null && skill['description'].isNotEmpty)
                  Text(
                    skill['description'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (skill['proficiency_percent'] ?? 0) / 100,
                          minHeight: 6,
                          backgroundColor: AppTheme.border,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Text(
                      '${skill['proficiency_percent'] ?? 0}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showSkillDialog(skill),
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AppTheme.textSecondary,
          ),
          IconButton(
            onPressed: () => _deleteSkill(skill['id'], skill['name']),
            icon: const Icon(Icons.delete_outline, size: 18),
            color: Colors.red.withOpacity(0.7),
          ),
        ],
      ),
    );
  }
}
