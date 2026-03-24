import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/data_service.dart';

/// Beceri yönetimi ekranı.
///
/// Beceriler dinamik uzmanlık alanlarına (expertise_areas tablosundan) göre gruplandırılır.
class SkillsAdminScreen extends StatefulWidget {
  const SkillsAdminScreen({super.key});

  @override
  State<SkillsAdminScreen> createState() => _SkillsAdminScreenState();
}

class _SkillsAdminScreenState extends State<SkillsAdminScreen> {
  List<Map<String, dynamic>> _skills = [];
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
      ds.getSkills(),
      ds.getExpertiseAreas(),
    ]);
    if (!mounted) return;
    setState(() {
      _skills = (results[0] as List).cast<Map<String, dynamic>>();
      _expertiseAreas = (results[1] as List).cast<Map<String, dynamic>>();
      _isLoading = false;
    });
  }

  Future<void> _showSkillDialog([Map<String, dynamic>? skill]) async {
    final isEdit = skill != null;
    final nameController = TextEditingController(text: skill?['name'] ?? '');
    final descController =
        TextEditingController(text: skill?['description'] ?? '');
    String? selectedAreaId = skill?['expertise_area_id'] as String?;
    int proficiency = skill?['proficiency_percent'] ?? 50;

    // Yerel kopya – dialog alanlar yüklenmemiş olabilir
    final areas = List<Map<String, dynamic>>.from(_expertiseAreas);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDs) => AlertDialog(
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
                if (areas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                    child: Text(
                      'Önce "Uzmanlık Alanları" bölümünden alan ekleyin.',
                      style: TextStyle(color: AppTheme.accentOrange),
                    ),
                  )
                else
                  DropdownButtonFormField<String?>(
                    value: selectedAreaId,
                    decoration:
                        const InputDecoration(labelText: 'Uzmanlık Alanı'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('— Seçilmedi —'),
                      ),
                      ...areas.map((a) => DropdownMenuItem<String?>(
                            value: a['id'] as String,
                            child: Text(a['name'] as String? ?? ''),
                          )),
                    ],
                    onChanged: (v) => setDs(() => selectedAreaId = v),
                    dropdownColor: AppTheme.surface,
                  ),
                const SizedBox(height: Spacing.lg),
                Row(
                  children: [
                    const Text('Yeterlilik: '),
                    Text('$proficiency%',
                        style: const TextStyle(color: AppTheme.accent)),
                  ],
                ),
                Slider(
                  value: proficiency.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  activeColor: AppTheme.accent,
                  onChanged: (v) =>
                      setDs(() => proficiency = v.round()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                final data = {
                  'name': nameController.text.trim(),
                  'description': descController.text.trim(),
                  'expertise_area_id': selectedAreaId,
                  'proficiency_percent': proficiency,
                };
                final ds = context.read<DataService>();
                final ok = isEdit
                    ? await ds.updateSkill(skill['id'] as String, data)
                    : await ds.createSkill(data);
                if (!mounted) return;
                Navigator.pop(ctx);
                if (ok) {
                  _load();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(isEdit ? 'Beceri güncellendi' : 'Beceri eklendi'),
                    backgroundColor: AppTheme.accentGreen,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.background),
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
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Beceriyi Sil'),
        content: Text('"$name" becerisini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<DataService>().deleteSkill(id);
      _load();
    }
  }

  Color _areaColor(String? areaId) {
    if (areaId == null) return AppTheme.textMuted;
    final area = _expertiseAreas.firstWhere(
      (a) => a['id'] == areaId,
      orElse: () => {},
    );
    try {
      final hex = (area['color'] as String?)?.replaceFirst('#', '') ?? '';
      return Color(0xFF000000 | int.parse(hex, radix: 16));
    } catch (_) {
      return AppTheme.accent;
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
            ..._buildSkillsByArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          children: [
            Icon(Icons.psychology_outlined,
                size: 64, color: AppTheme.textMuted),
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

  List<Widget> _buildSkillsByArea() {
    // Alanına göre grupla, alan yok ise "Diğer" grubuna koy
    final grouped = <String?, List<Map<String, dynamic>>>{};
    for (final skill in _skills) {
      final areaId = skill['expertise_area_id'] as String?;
      grouped.putIfAbsent(areaId, () => []).add(skill);
    }

    final widgets = <Widget>[];

    // Önce bilinen alanlar
    for (final area in _expertiseAreas) {
      final areaId = area['id'] as String;
      final areaSkills = grouped[areaId];
      if (areaSkills == null || areaSkills.isEmpty) continue;
      final color = _areaColor(areaId);
      widgets.add(_buildGroup(area['name'] as String? ?? '', areaSkills, color));
    }

    // Sonra alansız beceriler
    final unassigned = grouped[null];
    if (unassigned != null && unassigned.isNotEmpty) {
      widgets.add(_buildGroup('Diğer', unassigned, AppTheme.textMuted));
    }

    return widgets;
  }

  Widget _buildGroup(
      String title, List<Map<String, dynamic>> skills, Color color) {
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
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          ...skills.map((skill) => _buildSkillItem(skill, color)),
        ],
      ),
    );
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
                if ((skill['description'] ?? '').isNotEmpty)
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
            color: AppTheme.accentRed,
          ),
        ],
      ),
    );
  }
}
