import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/data_service.dart';
/// Proje ekleme/düzenleme ekranı.
class ProjectEditScreen extends StatefulWidget {
  final String? projectId;

  const ProjectEditScreen({super.key, this.projectId});

  @override
  State<ProjectEditScreen> createState() => _ProjectEditScreenState();
}

class _ProjectEditScreenState extends State<ProjectEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _problemController = TextEditingController();
  final _approachController = TextEditingController();
  final _implementationController = TextEditingController();
  final _resultsController = TextEditingController();
  final _lessonsController = TextEditingController();
  final _githubController = TextEditingController();
  final _demoController = TextEditingController();
  final _tagsController = TextEditingController();
  final _techController = TextEditingController();

  String? _expertiseAreaId;
  bool _featured = false;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isOngoing = true;
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _projectMissing = false;
  List<Map<String, dynamic>> _expertiseAreas = [];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.projectId != null;
    _loadExpertiseAreas().then((_) {
      if (_isEditMode) _loadProject();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _problemController.dispose();
    _approachController.dispose();
    _implementationController.dispose();
    _resultsController.dispose();
    _lessonsController.dispose();
    _githubController.dispose();
    _demoController.dispose();
    _tagsController.dispose();
    _techController.dispose();
    super.dispose();
  }

  Future<void> _loadExpertiseAreas() async {
    final areas = await context.read<DataService>().getExpertiseAreas();
    if (mounted) setState(() => _expertiseAreas = areas);
  }

  Future<void> _loadProject() async {
    setState(() => _isLoading = true);
    final project =
        await context.read<DataService>().getProject(widget.projectId!);
    if (project != null && mounted) {
      setState(() {
        _projectMissing = false;
        _titleController.text = project['title'] ?? '';
        _subtitleController.text = project['subtitle'] ?? '';
        _problemController.text = project['problem'] ?? '';
        _approachController.text = project['approach'] ?? '';
        _implementationController.text = project['implementation'] ?? '';
        _resultsController.text = project['results'] ?? '';
        _lessonsController.text = project['lessons_learned'] ?? '';
        _githubController.text = project['github_url'] ?? '';
        _demoController.text = project['demo_url'] ?? '';
        _expertiseAreaId = project['expertise_area_id'] as String?;
        _featured = project['featured'] ?? false;
        _tagsController.text =
            (project['tags'] as List?)?.join(', ') ?? '';
        _techController.text =
            (project['technologies'] as List?)?.join(', ') ?? '';
        if (project['start_date'] != null) {
          _startDate = DateTime.parse(project['start_date']);
        } else if (project['date'] != null) {
          _startDate = DateTime.parse(project['date']);
        }
        if (project['end_date'] != null) {
          _endDate = DateTime.parse(project['end_date']);
          _isOngoing = false;
        } else {
          _endDate = null;
          _isOngoing = true;
        }
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
        _projectMissing = _isEditMode;
      });
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'title': _titleController.text.trim(),
      'subtitle': _subtitleController.text.trim(),
      'expertise_area_id': _expertiseAreaId,
      'featured': _featured,
      'start_date': _startDate.toIso8601String().substring(0, 10),
      'end_date': _isOngoing ? null : _endDate?.toIso8601String().substring(0, 10),
      'date': _startDate.toIso8601String().substring(0, 10),
      'problem': _problemController.text.trim(),
      'approach': _approachController.text.trim(),
      'implementation': _implementationController.text.trim(),
      'results': _resultsController.text.trim(),
      'lessons_learned': _lessonsController.text.trim(),
      'github_url': _githubController.text.trim().isEmpty
          ? null
          : _githubController.text.trim(),
      'demo_url': _demoController.text.trim().isEmpty
          ? null
          : _demoController.text.trim(),
      'tags': _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'technologies': _techController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    };

    final ds = context.read<DataService>();
    final success = _isEditMode
        ? await ds.updateProject(widget.projectId!, data)
        : await ds.createProject(data);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(_isEditMode ? 'Proje güncellendi' : 'Proje oluşturuldu'),
          backgroundColor: AppTheme.accentGreen,
        ));
        context.go('/admin/projects');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ds.errorMessage ?? 'Bir hata oluştu'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _isEditMode) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isEditMode && _projectMissing) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.textMuted),
              const SizedBox(height: Spacing.lg),
              Text(
                'Proje bulunamadı',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Bu ID ile eşleşen bir proje yok veya erişim reddedildi.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMuted,
                    ),
              ),
              const SizedBox(height: Spacing.xl),
              OutlinedButton.icon(
                onPressed: () => context.go('/admin/projects'),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Projelere dön'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/admin/projects'),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: Spacing.md),
                Text(
                  _isEditMode ? 'Proje Düzenle' : 'Yeni Proje',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xxl),

            // Temel Bilgiler
            _buildSection('Temel Bilgiler', [
              _buildTextField(
                controller: _titleController,
                label: 'Proje Başlığı',
                hint: 'Akıllı Sulama Sistemi',
                required: true,
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _subtitleController,
                label: 'Kısa Açıklama',
                hint: 'IoT tabanlı toprak nem sensörü ve otomatik sulama kontrolü',
                maxLines: 2,
              ),
              const SizedBox(height: Spacing.lg),
              _buildExpertiseAreaDropdown(),
              const SizedBox(height: Spacing.lg),
              _buildDateRangePicker(),
              const SizedBox(height: Spacing.lg),
              _buildSwitch(
                label: 'Öne Çıkan Proje',
                subtitle: 'Ana sayfada gösterilsin mi?',
                value: _featured,
                onChanged: (v) => setState(() => _featured = v),
              ),
            ]),

            const SizedBox(height: Spacing.xxl),

            _buildSection('Dokümantasyon', [
              _buildTextField(
                controller: _problemController,
                label: 'Problem / Amaç',
                hint: 'Ne çözmeye çalışıyorum? Neden bu önemli?',
                maxLines: 4,
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _approachController,
                label: 'Yaklaşım',
                hint: 'Nasıl düşündüm? Hangi alternatifleri değerlendirdim?',
                maxLines: 4,
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _implementationController,
                label: 'Uygulama',
                hint: 'Teknik detaylar, kullanılan teknolojiler',
                maxLines: 4,
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _resultsController,
                label: 'Sonuçlar',
                hint: 'Ne elde ettim? Metrikler, ölçümler',
                maxLines: 4,
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _lessonsController,
                label: 'Öğrenilenler',
                hint: 'Ne öğrendim? Neleri farklı yapardım?',
                maxLines: 4,
              ),
            ]),

            const SizedBox(height: Spacing.xxl),

            _buildSection('Ek Bilgiler', [
              _buildTextField(
                controller: _tagsController,
                label: 'Etiketler',
                hint: 'ESP32, IoT, PCB (virgülle ayırın)',
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _techController,
                label: 'Teknolojiler',
                hint: 'KiCad, FreeRTOS, C++ (virgülle ayırın)',
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _githubController,
                label: 'GitHub URL',
                hint: 'https://github.com/...',
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _demoController,
                label: 'Demo URL',
                hint: 'https://demo.example.com',
              ),
            ]),

            const SizedBox(height: Spacing.xxl),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => context.go('/admin/projects'),
                  child: const Text('İptal'),
                ),
                const SizedBox(width: Spacing.md),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.background,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditMode ? 'Güncelle' : 'Oluştur'),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertiseAreaDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uzmanlık Alanı',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: Spacing.sm),
        if (_expertiseAreas.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md, vertical: Spacing.md),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              'Önce Uzmanlık Alanı ekleyin',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          )
        else
          DropdownButtonFormField<String?>(
            value: _expertiseAreaId,
            dropdownColor: AppTheme.surface,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('— Seçilmedi —'),
              ),
              ..._expertiseAreas.map((a) => DropdownMenuItem<String?>(
                    value: a['id'] as String,
                    child: Text(a['name'] as String? ?? ''),
                  )),
            ],
            onChanged: (v) => setState(() => _expertiseAreaId = v),
          ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: Spacing.lg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: Spacing.sm),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textMuted),
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.accent, width: 2),
            ),
          ),
          validator: required
              ? (v) => v?.isEmpty == true ? 'Bu alan zorunludur' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildDateRangePicker() {
    final fmt = (DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proje Tarihleri',
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            // Başlangıç tarihi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Başlangıç',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textMuted,
                          )),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                    child: _dateBox(fmt(_startDate)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.md),
            // Bitiş tarihi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bitiş',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textMuted,
                          )),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: _isOngoing
                        ? null
                        : () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: _startDate,
                              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                            );
                            if (picked != null) setState(() => _endDate = picked);
                          },
                    child: _dateBox(
                      _isOngoing ? 'Devam Ediyor' : fmt(_endDate ?? DateTime.now()),
                      muted: _isOngoing,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Checkbox(
              value: _isOngoing,
              activeColor: AppTheme.accent,
              onChanged: (v) => setState(() {
                _isOngoing = v ?? true;
                if (_isOngoing) _endDate = null;
              }),
            ),
            Text('Devam Ediyor',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppTheme.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _dateBox(String text, {bool muted = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md, vertical: Spacing.md),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today,
              size: 16,
              color: muted ? AppTheme.textMuted : AppTheme.textSecondary),
          const SizedBox(width: Spacing.xs),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: muted ? AppTheme.textMuted : AppTheme.textPrimary,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(label),
      subtitle: Text(subtitle, style: TextStyle(color: AppTheme.textMuted)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.accent,
      contentPadding: EdgeInsets.zero,
    );
  }
}
