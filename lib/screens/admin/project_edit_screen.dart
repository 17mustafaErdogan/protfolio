import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/data_service.dart';
import '../../utils/responsive.dart';

/// Proje ekleme/düzenleme ekranı.
class ProjectEditScreen extends StatefulWidget {
  final String? projectId;
  
  const ProjectEditScreen({super.key, this.projectId});

  @override
  State<ProjectEditScreen> createState() => _ProjectEditScreenState();
}

class _ProjectEditScreenState extends State<ProjectEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
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
  
  String _category = 'electronics';
  bool _featured = false;
  DateTime _date = DateTime.now();
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.projectId != null;
    if (_isEditMode) {
      _loadProject();
    }
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

  Future<void> _loadProject() async {
    setState(() => _isLoading = true);
    
    final dataService = context.read<DataService>();
    final project = await dataService.getProject(widget.projectId!);
    
    if (project != null && mounted) {
      setState(() {
        _titleController.text = project['title'] ?? '';
        _subtitleController.text = project['subtitle'] ?? '';
        _problemController.text = project['problem'] ?? '';
        _approachController.text = project['approach'] ?? '';
        _implementationController.text = project['implementation'] ?? '';
        _resultsController.text = project['results'] ?? '';
        _lessonsController.text = project['lessons_learned'] ?? '';
        _githubController.text = project['github_url'] ?? '';
        _demoController.text = project['demo_url'] ?? '';
        _category = project['category'] ?? 'electronics';
        _featured = project['featured'] ?? false;
        _tagsController.text = (project['tags'] as List?)?.join(', ') ?? '';
        _techController.text = (project['technologies'] as List?)?.join(', ') ?? '';
        if (project['date'] != null) {
          _date = DateTime.parse(project['date']);
        }
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final data = {
      'title': _titleController.text.trim(),
      'subtitle': _subtitleController.text.trim(),
      'category': _category,
      'featured': _featured,
      'date': _date.toIso8601String().substring(0, 10),
      'problem': _problemController.text.trim(),
      'approach': _approachController.text.trim(),
      'implementation': _implementationController.text.trim(),
      'results': _resultsController.text.trim(),
      'lessons_learned': _lessonsController.text.trim(),
      'github_url': _githubController.text.trim().isEmpty ? null : _githubController.text.trim(),
      'demo_url': _demoController.text.trim().isEmpty ? null : _demoController.text.trim(),
      'tags': _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'technologies': _techController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    };
    
    final dataService = context.read<DataService>();
    bool success;
    
    if (_isEditMode) {
      success = await dataService.updateProject(widget.projectId!, data);
    } else {
      success = await dataService.createProject(data);
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Proje güncellendi' : 'Proje oluşturuldu'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        context.go('/admin/projects');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dataService.errorMessage ?? 'Bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _isEditMode) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
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
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Kategori',
                      value: _category,
                      items: const [
                        DropdownMenuItem(value: 'electronics', child: Text('Elektronik')),
                        DropdownMenuItem(value: 'mechanical', child: Text('Mekanik')),
                        DropdownMenuItem(value: 'software', child: Text('Yazılım')),
                      ],
                      onChanged: (value) => setState(() => _category = value!),
                    ),
                  ),
                  const SizedBox(width: Spacing.lg),
                  Expanded(
                    child: _buildDatePicker(),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              _buildSwitch(
                label: 'Öne Çıkan Proje',
                subtitle: 'Ana sayfada gösterilsin mi?',
                value: _featured,
                onChanged: (value) => setState(() => _featured = value),
              ),
            ]),
            
            const SizedBox(height: Spacing.xxl),
            
            // Dokümantasyon
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
            
            // Ek Bilgiler
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
            
            // Kaydet butonu
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
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
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
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
              ? (value) => value?.isEmpty == true ? 'Bu alan zorunludur' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: AppTheme.surface,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarih',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() => _date = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: AppTheme.textMuted),
                const SizedBox(width: Spacing.sm),
                Text(
                  '${_date.day}/${_date.month}/${_date.year}',
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
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
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppTheme.textMuted),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.accent,
      contentPadding: EdgeInsets.zero,
    );
  }
}
