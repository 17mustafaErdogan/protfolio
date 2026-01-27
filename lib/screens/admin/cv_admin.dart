import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/data_service.dart';

/// CV bilgileri yönetimi ekranı.
/// 
/// Tab yapısında: Eğitim, Sertifikalar, İş Deneyimi, Diller, Başarılar
class CVAdminScreen extends StatefulWidget {
  const CVAdminScreen({super.key});

  @override
  State<CVAdminScreen> createState() => _CVAdminScreenState();
}

class _CVAdminScreenState extends State<CVAdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Başlık
        Container(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Row(
            children: [
              Text(
                'CV Bilgileri',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Tab bar
        Container(
          color: AppTheme.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppTheme.accent,
            labelColor: AppTheme.accent,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: const [
              Tab(text: 'Eğitim'),
              Tab(text: 'Sertifikalar'),
              Tab(text: 'İş Deneyimi'),
              Tab(text: 'Diller'),
              Tab(text: 'Başarılar'),
            ],
          ),
        ),
        
        // Tab içerikleri
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _EducationTab(),
              _CertificatesTab(),
              _WorkExperienceTab(),
              _LanguagesTab(),
              _AchievementsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// EĞİTİM TAB
// ============================================================
class _EducationTab extends StatefulWidget {
  const _EducationTab();

  @override
  State<_EducationTab> createState() => _EducationTabState();
}

class _EducationTabState extends State<_EducationTab> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await context.read<DataService>().getEducation();
    if (mounted) setState(() { _items = data; _isLoading = false; });
  }

  Future<void> _showDialog([Map<String, dynamic>? item]) async {
    final isEdit = item != null;
    final degreeC = TextEditingController(text: item?['degree'] ?? '');
    final fieldC = TextEditingController(text: item?['field'] ?? '');
    final instC = TextEditingController(text: item?['institution'] ?? '');
    final periodC = TextEditingController(text: item?['period'] ?? '');
    final gpaC = TextEditingController(text: item?['gpa'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(isEdit ? 'Eğitim Düzenle' : 'Yeni Eğitim'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: degreeC, decoration: const InputDecoration(labelText: 'Derece (Lisans, Y. Lisans...)')),
              const SizedBox(height: Spacing.md),
              TextField(controller: fieldC, decoration: const InputDecoration(labelText: 'Bölüm')),
              const SizedBox(height: Spacing.md),
              TextField(controller: instC, decoration: const InputDecoration(labelText: 'Kurum')),
              const SizedBox(height: Spacing.md),
              TextField(controller: periodC, decoration: const InputDecoration(labelText: 'Dönem (2018-2022)')),
              const SizedBox(height: Spacing.md),
              TextField(controller: gpaC, decoration: const InputDecoration(labelText: 'GPA (opsiyonel)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              if (degreeC.text.isEmpty || fieldC.text.isEmpty) return;
              final data = {
                'degree': degreeC.text.trim(),
                'field': fieldC.text.trim(),
                'institution': instC.text.trim(),
                'period': periodC.text.trim(),
                'gpa': gpaC.text.trim().isEmpty ? null : gpaC.text.trim(),
              };
              final ds = context.read<DataService>();
              final success = isEdit 
                  ? await ds.updateEducation(item!['id'], data)
                  : await ds.createEducation(data);
              if (success && mounted) { Navigator.pop(context); _load(); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: Text(isEdit ? 'Güncelle' : 'Ekle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildListView(
      isLoading: _isLoading,
      items: _items,
      emptyIcon: Icons.school_outlined,
      emptyText: 'Eğitim bilgisi eklenmemiş',
      onAdd: () => _showDialog(),
      itemBuilder: (item) => ListTile(
        title: Text('${item['degree']} - ${item['field']}'),
        subtitle: Text('${item['institution']} (${item['period']})'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showDialog(item)),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              onPressed: () async {
                await context.read<DataService>().deleteEducation(item['id']);
                _load();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SERTİFİKALAR TAB
// ============================================================
class _CertificatesTab extends StatefulWidget {
  const _CertificatesTab();

  @override
  State<_CertificatesTab> createState() => _CertificatesTabState();
}

class _CertificatesTabState extends State<_CertificatesTab> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await context.read<DataService>().getCertificates();
    if (mounted) setState(() { _items = data; _isLoading = false; });
  }

  Future<void> _showDialog([Map<String, dynamic>? item]) async {
    final isEdit = item != null;
    final nameC = TextEditingController(text: item?['name'] ?? '');
    final issuerC = TextEditingController(text: item?['issuer'] ?? '');
    final urlC = TextEditingController(text: item?['credential_url'] ?? '');
    DateTime date = item?['date'] != null ? DateTime.parse(item!['date']) : DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(isEdit ? 'Sertifika Düzenle' : 'Yeni Sertifika'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Sertifika Adı')),
                const SizedBox(height: Spacing.md),
                TextField(controller: issuerC, decoration: const InputDecoration(labelText: 'Veren Kurum')),
                const SizedBox(height: Spacing.md),
                ListTile(
                  title: const Text('Tarih'),
                  subtitle: Text('${date.day}/${date.month}/${date.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime.now());
                    if (picked != null) setDialogState(() => date = picked);
                  },
                ),
                TextField(controller: urlC, decoration: const InputDecoration(labelText: 'Doğrulama URL (opsiyonel)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                if (nameC.text.isEmpty || issuerC.text.isEmpty) return;
                final data = {
                  'name': nameC.text.trim(),
                  'issuer': issuerC.text.trim(),
                  'date': date.toIso8601String().substring(0, 10),
                  'credential_url': urlC.text.trim().isEmpty ? null : urlC.text.trim(),
                };
                final ds = context.read<DataService>();
                final success = isEdit ? await ds.updateCertificate(item!['id'], data) : await ds.createCertificate(data);
                if (success && mounted) { Navigator.pop(context); _load(); }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
              child: Text(isEdit ? 'Güncelle' : 'Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildListView(
      isLoading: _isLoading,
      items: _items,
      emptyIcon: Icons.verified_outlined,
      emptyText: 'Sertifika eklenmemiş',
      onAdd: () => _showDialog(),
      itemBuilder: (item) => ListTile(
        title: Text(item['name'] ?? ''),
        subtitle: Text(item['issuer'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showDialog(item)),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              onPressed: () async { await context.read<DataService>().deleteCertificate(item['id']); _load(); },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// İŞ DENEYİMİ TAB
// ============================================================
class _WorkExperienceTab extends StatefulWidget {
  const _WorkExperienceTab();

  @override
  State<_WorkExperienceTab> createState() => _WorkExperienceTabState();
}

class _WorkExperienceTabState extends State<_WorkExperienceTab> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await context.read<DataService>().getWorkExperience();
    if (mounted) setState(() { _items = data; _isLoading = false; });
  }

  Future<void> _showDialog([Map<String, dynamic>? item]) async {
    final isEdit = item != null;
    final titleC = TextEditingController(text: item?['title'] ?? '');
    final companyC = TextEditingController(text: item?['company'] ?? '');
    final periodC = TextEditingController(text: item?['period'] ?? '');
    final descC = TextEditingController(text: item?['description'] ?? '');
    final locC = TextEditingController(text: item?['location'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(isEdit ? 'Deneyim Düzenle' : 'Yeni Deneyim'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Pozisyon')),
              const SizedBox(height: Spacing.md),
              TextField(controller: companyC, decoration: const InputDecoration(labelText: 'Şirket')),
              const SizedBox(height: Spacing.md),
              TextField(controller: periodC, decoration: const InputDecoration(labelText: 'Dönem (2020-2022)')),
              const SizedBox(height: Spacing.md),
              TextField(controller: locC, decoration: const InputDecoration(labelText: 'Konum')),
              const SizedBox(height: Spacing.md),
              TextField(controller: descC, decoration: const InputDecoration(labelText: 'Açıklama'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              if (titleC.text.isEmpty || companyC.text.isEmpty) return;
              final data = {
                'title': titleC.text.trim(),
                'company': companyC.text.trim(),
                'period': periodC.text.trim(),
                'location': locC.text.trim().isEmpty ? null : locC.text.trim(),
                'description': descC.text.trim().isEmpty ? null : descC.text.trim(),
              };
              final ds = context.read<DataService>();
              final success = isEdit ? await ds.updateWorkExperience(item!['id'], data) : await ds.createWorkExperience(data);
              if (success && mounted) { Navigator.pop(context); _load(); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: Text(isEdit ? 'Güncelle' : 'Ekle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildListView(
      isLoading: _isLoading,
      items: _items,
      emptyIcon: Icons.work_outline,
      emptyText: 'İş deneyimi eklenmemiş',
      onAdd: () => _showDialog(),
      itemBuilder: (item) => ListTile(
        title: Text('${item['title']} @ ${item['company']}'),
        subtitle: Text(item['period'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showDialog(item)),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              onPressed: () async { await context.read<DataService>().deleteWorkExperience(item['id']); _load(); },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DİLLER TAB
// ============================================================
class _LanguagesTab extends StatefulWidget {
  const _LanguagesTab();

  @override
  State<_LanguagesTab> createState() => _LanguagesTabState();
}

class _LanguagesTabState extends State<_LanguagesTab> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await context.read<DataService>().getLanguages();
    if (mounted) setState(() { _items = data; _isLoading = false; });
  }

  Future<void> _showDialog([Map<String, dynamic>? item]) async {
    final isEdit = item != null;
    final langC = TextEditingController(text: item?['language'] ?? '');
    final levelC = TextEditingController(text: item?['level'] ?? '');
    int prof = item?['proficiency_percent'] ?? 50;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(isEdit ? 'Dil Düzenle' : 'Yeni Dil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: langC, decoration: const InputDecoration(labelText: 'Dil')),
              const SizedBox(height: Spacing.md),
              TextField(controller: levelC, decoration: const InputDecoration(labelText: 'Seviye (A1-C2)')),
              const SizedBox(height: Spacing.lg),
              Row(children: [const Text('Yeterlilik: '), Text('$prof%', style: TextStyle(color: AppTheme.accent))]),
              Slider(
                value: prof.toDouble(), min: 0, max: 100, divisions: 20,
                activeColor: AppTheme.accent,
                onChanged: (v) => setDialogState(() => prof = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                if (langC.text.isEmpty) return;
                final data = {'language': langC.text.trim(), 'level': levelC.text.trim(), 'proficiency_percent': prof};
                final ds = context.read<DataService>();
                final success = isEdit ? await ds.updateLanguage(item!['id'], data) : await ds.createLanguage(data);
                if (success && mounted) { Navigator.pop(context); _load(); }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
              child: Text(isEdit ? 'Güncelle' : 'Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildListView(
      isLoading: _isLoading,
      items: _items,
      emptyIcon: Icons.language,
      emptyText: 'Dil eklenmemiş',
      onAdd: () => _showDialog(),
      itemBuilder: (item) => ListTile(
        title: Text(item['language'] ?? ''),
        subtitle: Text('${item['level']} - ${item['proficiency_percent']}%'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showDialog(item)),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              onPressed: () async { await context.read<DataService>().deleteLanguage(item['id']); _load(); },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BAŞARILAR TAB
// ============================================================
class _AchievementsTab extends StatefulWidget {
  const _AchievementsTab();

  @override
  State<_AchievementsTab> createState() => _AchievementsTabState();
}

class _AchievementsTabState extends State<_AchievementsTab> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final data = await context.read<DataService>().getAchievements();
    if (mounted) setState(() { _items = data; _isLoading = false; });
  }

  Future<void> _showDialog([Map<String, dynamic>? item]) async {
    final isEdit = item != null;
    final titleC = TextEditingController(text: item?['title'] ?? '');
    final descC = TextEditingController(text: item?['description'] ?? '');
    final orgC = TextEditingController(text: item?['organization'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(isEdit ? 'Başarı Düzenle' : 'Yeni Başarı'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleC, decoration: const InputDecoration(labelText: 'Başlık')),
              const SizedBox(height: Spacing.md),
              TextField(controller: descC, decoration: const InputDecoration(labelText: 'Açıklama'), maxLines: 3),
              const SizedBox(height: Spacing.md),
              TextField(controller: orgC, decoration: const InputDecoration(labelText: 'Organizasyon')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              if (titleC.text.isEmpty) return;
              final data = {
                'title': titleC.text.trim(),
                'description': descC.text.trim(),
                'organization': orgC.text.trim().isEmpty ? null : orgC.text.trim(),
              };
              final ds = context.read<DataService>();
              final success = isEdit ? await ds.updateAchievement(item!['id'], data) : await ds.createAchievement(data);
              if (success && mounted) { Navigator.pop(context); _load(); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            child: Text(isEdit ? 'Güncelle' : 'Ekle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildListView(
      isLoading: _isLoading,
      items: _items,
      emptyIcon: Icons.emoji_events_outlined,
      emptyText: 'Başarı eklenmemiş',
      onAdd: () => _showDialog(),
      itemBuilder: (item) => ListTile(
        title: Text(item['title'] ?? ''),
        subtitle: Text(item['organization'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showDialog(item)),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              onPressed: () async { await context.read<DataService>().deleteAchievement(item['id']); _load(); },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ORTAK LISTE GÖRÜNÜMÜ
// ============================================================
Widget _buildListView({
  required bool isLoading,
  required List<Map<String, dynamic>> items,
  required IconData emptyIcon,
  required String emptyText,
  required VoidCallback onAdd,
  required Widget Function(Map<String, dynamic>) itemBuilder,
}) {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  return SingleChildScrollView(
    padding: const EdgeInsets.all(Spacing.xl),
    child: Column(
      children: [
        // Ekle butonu
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: AppTheme.background,
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        
        if (items.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.all(Spacing.xxl),
              child: Column(
                children: [
                  Icon(emptyIcon, size: 64, color: AppTheme.textMuted),
                  const SizedBox(height: Spacing.lg),
                  Text(emptyText, style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => itemBuilder(items[index]),
            ),
          ),
      ],
    ),
  );
}
