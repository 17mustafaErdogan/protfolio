import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/data_service.dart';
import '../../utils/form_validators.dart';

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
    _tabController = TabController(length: 7, vsync: this);
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
              Tab(text: 'Yayınlar'),
              Tab(text: 'Referanslar'),
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
              _PublicationsTab(),
              _ReferencesTab(),
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
    final formKey = GlobalKey<FormState>();
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
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextFormField(
                controller: degreeC,
                decoration: const InputDecoration(labelText: 'Derece (Lisans, Y. Lisans...)'),
                validator: (v) => FormValidators.requiredTrim(v),
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: fieldC,
                decoration: const InputDecoration(labelText: 'Bölüm'),
                validator: (v) => FormValidators.requiredTrim(v),
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: instC,
                decoration: const InputDecoration(labelText: 'Kurum'),
                validator: (v) => FormValidators.requiredTrim(v),
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: periodC,
                decoration: const InputDecoration(labelText: 'Dönem (2018-2022)'),
                validator: (v) => FormValidators.requiredTrim(v),
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(controller: gpaC, decoration: const InputDecoration(labelText: 'GPA (opsiyonel)')),
            ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final data = {
                'degree': degreeC.text.trim(),
                'field': fieldC.text.trim(),
                'institution': instC.text.trim(),
                'period': periodC.text.trim(),
                'gpa': gpaC.text.trim().isEmpty ? null : gpaC.text.trim(),
              };
              final ds = context.read<DataService>();
              final success = isEdit 
                  ? await ds.updateEducation(item['id'], data)
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
    final formKey = GlobalKey<FormState>();
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
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                TextFormField(
                  controller: nameC,
                  decoration: const InputDecoration(labelText: 'Sertifika Adı'),
                  validator: (v) => FormValidators.requiredTrim(v),
                ),
                const SizedBox(height: Spacing.md),
                TextFormField(
                  controller: issuerC,
                  decoration: const InputDecoration(labelText: 'Veren Kurum'),
                  validator: (v) => FormValidators.requiredTrim(v),
                ),
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
                TextFormField(
                  controller: urlC,
                  decoration: const InputDecoration(labelText: 'Doğrulama URL (opsiyonel)'),
                  keyboardType: TextInputType.url,
                  validator: FormValidators.optionalUrl,
                ),
              ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final data = {
                  'name': nameC.text.trim(),
                  'issuer': issuerC.text.trim(),
                  'date': date.toIso8601String().substring(0, 10),
                  'credential_url': urlC.text.trim().isEmpty ? null : urlC.text.trim(),
                };
                final ds = context.read<DataService>();
                final success = isEdit ? await ds.updateCertificate(item['id'], data) : await ds.createCertificate(data);
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
    final formKey = GlobalKey<FormState>();
    final titleC = TextEditingController(text: item?['title'] ?? '');
    final companyC = TextEditingController(text: item?['company'] ?? '');
    final periodC = TextEditingController(text: item?['period'] ?? '');
    final descC = TextEditingController(text: item?['description'] ?? '');
    final locC = TextEditingController(text: item?['location'] ?? '');

    DateTime? startDate = item != null
        ? DateTime.tryParse(item['start_date'] ?? '')
        : null;
    DateTime? endDate = item != null
        ? DateTime.tryParse(item['end_date'] ?? '')
        : null;
    bool isOngoing = endDate == null;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDs) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(isEdit ? 'Deneyim Düzenle' : 'Yeni Deneyim'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  TextFormField(
                      controller: titleC,
                      decoration:
                          const InputDecoration(labelText: 'Pozisyon *'),
                      validator: (v) => FormValidators.requiredTrim(v)),
                  const SizedBox(height: Spacing.md),
                  TextFormField(
                      controller: companyC,
                      decoration:
                          const InputDecoration(labelText: 'Şirket *'),
                      validator: (v) => FormValidators.requiredTrim(v)),
                  const SizedBox(height: Spacing.md),
                  TextFormField(
                      controller: locC,
                      decoration: const InputDecoration(labelText: 'Konum')),
                  const SizedBox(height: Spacing.lg),

                  // Tarih aralığı
                  Text(
                    'Tarih Aralığı',
                    style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _dateTile(
                          ctx,
                          label: 'Başlangıç',
                          date: startDate,
                          hint: 'Seç',
                          onPick: () async {
                            final p = await showDatePicker(
                              context: ctx,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(1980),
                              lastDate: DateTime.now(),
                            );
                            if (p != null) setDs(() => startDate = p);
                          },
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: isOngoing
                            ? Container(
                                padding: const EdgeInsets.all(Spacing.md),
                                decoration: BoxDecoration(
                                  color: AppTheme.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Text(
                                  'Devam Ediyor',
                                  style: TextStyle(
                                      color: AppTheme.accentGreen,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            : _dateTile(
                                ctx,
                                label: 'Bitiş',
                                date: endDate,
                                hint: 'Seç',
                                onPick: () async {
                                  final p = await showDatePicker(
                                    context: ctx,
                                    initialDate:
                                        endDate ?? DateTime.now(),
                                    firstDate:
                                        startDate ?? DateTime(1980),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365 * 5)),
                                  );
                                  if (p != null) setDs(() => endDate = p);
                                },
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),
                  CheckboxListTile(
                    dense: true,
                    title: const Text('Devam Ediyor'),
                    value: isOngoing,
                    activeColor: AppTheme.accent,
                    onChanged: (v) => setDs(() {
                      isOngoing = v ?? true;
                      if (isOngoing) endDate = null;
                    }),
                  ),
                  const SizedBox(height: Spacing.md),

                  // Görüntü için metin dönem (opsiyonel)
                  TextField(
                    controller: periodC,
                    decoration: const InputDecoration(
                      labelText: 'Görüntü Metni (opsiyonel)',
                      hintText: 'Örn: 2020 - 2022 · Tam Zamanlı',
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  TextFormField(
                      controller: descC,
                      decoration:
                          const InputDecoration(labelText: 'Açıklama'),
                      maxLines: 3),
                ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (startDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Başlangıç tarihi seçin')),
                  );
                  return;
                }

                // Otomatik period metni oluştur (boşsa)
                String periodText = periodC.text.trim();
                if (periodText.isEmpty && startDate != null) {
                  final startStr =
                      '${startDate!.year}/${startDate!.month.toString().padLeft(2, '0')}';
                  final endStr = isOngoing
                      ? 'devam ediyor'
                      : endDate != null
                          ? '${endDate!.year}/${endDate!.month.toString().padLeft(2, '0')}'
                          : '';
                  periodText = '$startStr → $endStr';
                }

                final data = {
                  'title': titleC.text.trim(),
                  'company': companyC.text.trim(),
                  'period': periodText,
                  'start_date': startDate
                      ?.toIso8601String()
                      .substring(0, 10),
                  'end_date': isOngoing
                      ? null
                      : endDate?.toIso8601String().substring(0, 10),
                  'location': locC.text.trim().isEmpty
                      ? null
                      : locC.text.trim(),
                  'description': descC.text.trim().isEmpty
                      ? null
                      : descC.text.trim(),
                };
                final ds = context.read<DataService>();
                final success = isEdit
                    ? await ds.updateWorkExperience(item['id'], data)
                    : await ds.createWorkExperience(data);
                if (success && mounted) {
                  Navigator.pop(ctx);
                  _load();
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

  Widget _dateTile(
    BuildContext ctx, {
    required String label,
    required DateTime? date,
    required String hint,
    required VoidCallback onPick,
  }) {
    return InkWell(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(ctx)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  date != null
                      ? '${date.year}/${date.month.toString().padLeft(2, '0')}'
                      : hint,
                  style: TextStyle(
                    color:
                        date != null ? AppTheme.textPrimary : AppTheme.textMuted,
                  ),
                ),
              ],
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
      emptyIcon: Icons.work_outline,
      emptyText: 'İş deneyimi eklenmemiş',
      onAdd: () => _showDialog(),
      itemBuilder: (item) => ListTile(
        title: Text('${item['title']} @ ${item['company']}'),
        subtitle: Text(
          item['start_date'] != null
              ? '${item['start_date']} → ${item['end_date'] ?? 'devam ediyor'}'
              : item['period'] ?? '',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => _showDialog(item)),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.red),
              onPressed: () async {
                await context
                    .read<DataService>()
                    .deleteWorkExperience(item['id']);
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
    final formKey = GlobalKey<FormState>();
    final langC = TextEditingController(text: item?['language'] ?? '');
    final levelC = TextEditingController(text: item?['level'] ?? '');
    int prof = item?['proficiency_percent'] ?? 50;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(isEdit ? 'Dil Düzenle' : 'Yeni Dil'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextFormField(
                controller: langC,
                decoration: const InputDecoration(labelText: 'Dil'),
                validator: (v) => FormValidators.requiredTrim(v),
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: levelC,
                decoration: const InputDecoration(labelText: 'Seviye (A1-C2)'),
                validator: (v) => FormValidators.requiredTrim(v),
              ),
              const SizedBox(height: Spacing.lg),
              Row(children: [const Text('Yeterlilik: '), Text('$prof%', style: TextStyle(color: AppTheme.accent))]),
              Slider(
                value: prof.toDouble(), min: 0, max: 100, divisions: 20,
                activeColor: AppTheme.accent,
                onChanged: (v) => setDialogState(() => prof = v.round()),
              ),
            ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final data = {'language': langC.text.trim(), 'level': levelC.text.trim(), 'proficiency_percent': prof};
                final ds = context.read<DataService>();
                final success = isEdit ? await ds.updateLanguage(item['id'], data) : await ds.createLanguage(data);
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
    final formKey = GlobalKey<FormState>();
    final titleC = TextEditingController(text: item?['title'] ?? '');
    final descC = TextEditingController(text: item?['description'] ?? '');
    final orgC = TextEditingController(text: item?['organization'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(isEdit ? 'Başarı Düzenle' : 'Yeni Başarı'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextFormField(
                controller: titleC,
                decoration: const InputDecoration(labelText: 'Başlık'),
                validator: (v) => FormValidators.requiredTrim(v),
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(controller: descC, decoration: const InputDecoration(labelText: 'Açıklama'), maxLines: 3),
              const SizedBox(height: Spacing.md),
              TextFormField(controller: orgC, decoration: const InputDecoration(labelText: 'Organizasyon')),
            ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final data = {
                'title': titleC.text.trim(),
                'description': descC.text.trim(),
                'organization': orgC.text.trim().isEmpty ? null : orgC.text.trim(),
              };
              final ds = context.read<DataService>();
              final success = isEdit ? await ds.updateAchievement(item['id'], data) : await ds.createAchievement(data);
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
// REFERANSLAR TAB
// ============================================================
class _ReferencesTab extends StatefulWidget {
  const _ReferencesTab();

  @override
  State<_ReferencesTab> createState() => _ReferencesTabState();
}

class _ReferencesTabState extends State<_ReferencesTab> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await context.read<DataService>().getReferences();
    if (mounted) setState(() {
      _items = data;
      _isLoading = false;
    });
  }

  Future<void> _showDialog([Map<String, dynamic>? item]) async {
    final isEdit = item != null;
    final formKey = GlobalKey<FormState>();
    final nameC = TextEditingController(text: item?['name'] ?? '');
    final titleC = TextEditingController(text: item?['title'] ?? '');
    final companyC = TextEditingController(text: item?['company'] ?? '');
    final emailC = TextEditingController(text: item?['email'] ?? '');
    final phoneC = TextEditingController(text: item?['phone'] ?? '');
    final relationC = TextEditingController(text: item?['relationship'] ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(isEdit ? 'Referans Düzenle' : 'Yeni Referans'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Ad Soyad *'),
                validator: (v) => FormValidators.requiredTrim(v),
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: titleC,
                decoration: const InputDecoration(labelText: 'Ünvan *'),
                validator: (v) => FormValidators.requiredTrim(v),
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: companyC,
                decoration: const InputDecoration(labelText: 'Şirket *'),
                validator: (v) => FormValidators.requiredTrim(v),
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: emailC,
                decoration: const InputDecoration(labelText: 'Email (opsiyonel)'),
                keyboardType: TextInputType.emailAddress,
                validator: FormValidators.optionalEmail,
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(controller: phoneC, decoration: const InputDecoration(labelText: 'Telefon (opsiyonel)')),
              const SizedBox(height: Spacing.md),
              TextFormField(controller: relationC, decoration: const InputDecoration(labelText: 'İlişki (örn: Eski Yönetici)')),
            ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final data = {
                'name': nameC.text.trim(),
                'title': titleC.text.trim(),
                'company': companyC.text.trim(),
                'email': emailC.text.trim().isEmpty ? null : emailC.text.trim(),
                'phone': phoneC.text.trim().isEmpty ? null : phoneC.text.trim(),
                'relationship': relationC.text.trim().isEmpty ? null : relationC.text.trim(),
              };
              final ds = context.read<DataService>();
              final success = isEdit
                  ? await ds.updateReference(item['id'] as String, data)
                  : await ds.createReference(data);
              if (success && mounted) {
                Navigator.pop(context);
                _load();
              }
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
      emptyIcon: Icons.people_outline,
      emptyText: 'Referans eklenmemiş',
      onAdd: () => _showDialog(),
      itemBuilder: (item) => ListTile(
        title: Text('${item['name']} - ${item['title']}'),
        subtitle: Text(item['company'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showDialog(item)),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              onPressed: () async {
                await context.read<DataService>().deleteReference(item['id']);
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
// YAYINLAR TAB
// ============================================================
class _PublicationsTab extends StatefulWidget {
  const _PublicationsTab();

  @override
  State<_PublicationsTab> createState() => _PublicationsTabState();
}

class _PublicationsTabState extends State<_PublicationsTab> {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await context.read<DataService>().getPublications();
    if (mounted) setState(() {
      _items = data;
      _isLoading = false;
    });
  }

  Future<void> _showDialog([Map<String, dynamic>? item]) async {
    final isEdit = item != null;
    final formKey = GlobalKey<FormState>();
    final titleC = TextEditingController(text: item?['title'] ?? '');
    final venueC = TextEditingController(text: item?['venue'] ?? '');
    final urlC = TextEditingController(text: item?['url'] ?? '');
    final abstractC = TextEditingController(text: item?['abstract'] ?? '');
    final coAuthorsC = TextEditingController(
      text: item?['co_authors'] != null
          ? (item!['co_authors'] as List).join(', ')
          : '',
    );
    DateTime date = item?['date'] != null
        ? DateTime.parse(item!['date'])
        : DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(isEdit ? 'Yayın Düzenle' : 'Yeni Yayın'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                TextFormField(
                  controller: titleC,
                  decoration: const InputDecoration(labelText: 'Başlık *'),
                  validator: (v) => FormValidators.requiredTrim(v),
                ),
                const SizedBox(height: Spacing.md),
                TextFormField(
                  controller: venueC,
                  decoration: const InputDecoration(labelText: 'Yayın yeri (Dergi, Konferans) *'),
                  validator: (v) => FormValidators.requiredTrim(v),
                ),
                const SizedBox(height: Spacing.md),
                ListTile(
                  title: const Text('Tarih'),
                  subtitle: Text('${date.day}/${date.month}/${date.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setDialogState(() => date = picked);
                  },
                ),
                TextFormField(
                  controller: urlC,
                  decoration: const InputDecoration(labelText: 'URL (opsiyonel)'),
                  keyboardType: TextInputType.url,
                  validator: FormValidators.optionalUrl,
                ),
                const SizedBox(height: Spacing.md),
                TextField(
                  controller: coAuthorsC,
                  decoration: const InputDecoration(labelText: 'Ortak yazarlar (virgülle ayırın)'),
                ),
                const SizedBox(height: Spacing.md),
                TextField(
                  controller: abstractC,
                  decoration: const InputDecoration(labelText: 'Özet'),
                  maxLines: 3,
                ),
              ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final coAuthorsStr = coAuthorsC.text.trim();
                final coAuthors = coAuthorsStr.isEmpty
                    ? null
                    : coAuthorsStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                final data = {
                  'title': titleC.text.trim(),
                  'venue': venueC.text.trim(),
                  'date': date.toIso8601String().substring(0, 10),
                  'url': urlC.text.trim().isEmpty ? null : urlC.text.trim(),
                  'co_authors': coAuthors,
                  'abstract': abstractC.text.trim().isEmpty ? null : abstractC.text.trim(),
                };
                final ds = context.read<DataService>();
                final success = isEdit
                    ? await ds.updatePublication(item['id'] as String, data)
                    : await ds.createPublication(data);
                if (success && mounted) {
                  Navigator.pop(context);
                  _load();
                }
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
      emptyIcon: Icons.article_outlined,
      emptyText: 'Yayın eklenmemiş',
      onAdd: () => _showDialog(),
      itemBuilder: (item) => ListTile(
        title: Text(item['title'] ?? ''),
        subtitle: Text('${item['venue'] ?? ''} - ${item['date'] ?? ''}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showDialog(item)),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
              onPressed: () async {
                await context.read<DataService>().deletePublication(item['id']);
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
