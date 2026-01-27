import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/data_service.dart';

/// Ayarlar / Kişisel bilgiler düzenleme ekranı.
class SettingsAdminScreen extends StatefulWidget {
  const SettingsAdminScreen({super.key});

  @override
  State<SettingsAdminScreen> createState() => _SettingsAdminScreenState();
}

class _SettingsAdminScreenState extends State<SettingsAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _bioController = TextEditingController();
  final _detailedBioController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _twitterController = TextEditingController();
  final _websiteController = TextEditingController();
  
  // Stats
  final _projectCountController = TextEditingController();
  final _yearsExpController = TextEditingController();
  final _expertiseController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _bioController.dispose();
    _detailedBioController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _websiteController.dispose();
    _projectCountController.dispose();
    _yearsExpController.dispose();
    _expertiseController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final dataService = context.read<DataService>();
    
    final personalInfo = await dataService.getPersonalInfo();
    final stats = await dataService.getStats();
    
    if (mounted) {
      setState(() {
        if (personalInfo != null) {
          _nameController.text = personalInfo['full_name'] ?? '';
          _titleController.text = personalInfo['title'] ?? '';
          _bioController.text = personalInfo['bio'] ?? '';
          _detailedBioController.text = personalInfo['detailed_bio'] ?? '';
          _emailController.text = personalInfo['email'] ?? '';
          _locationController.text = personalInfo['location'] ?? '';
          _githubController.text = personalInfo['github_url'] ?? '';
          _linkedinController.text = personalInfo['linkedin_url'] ?? '';
          _twitterController.text = personalInfo['twitter_url'] ?? '';
          _websiteController.text = personalInfo['website_url'] ?? '';
        }
        
        if (stats != null) {
          _projectCountController.text = stats['project_count'] ?? '0';
          _yearsExpController.text = stats['years_experience'] ?? '0';
          _expertiseController.text = stats['expertise_areas'] ?? '3';
        }
        
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final dataService = context.read<DataService>();
    
    // Personal info
    final personalSuccess = await dataService.updatePersonalInfo({
      'full_name': _nameController.text.trim(),
      'title': _titleController.text.trim(),
      'bio': _bioController.text.trim(),
      'detailed_bio': _detailedBioController.text.trim().isEmpty ? null : _detailedBioController.text.trim(),
      'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      'location': _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      'github_url': _githubController.text.trim().isEmpty ? null : _githubController.text.trim(),
      'linkedin_url': _linkedinController.text.trim().isEmpty ? null : _linkedinController.text.trim(),
      'twitter_url': _twitterController.text.trim().isEmpty ? null : _twitterController.text.trim(),
      'website_url': _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
    });
    
    // Stats
    final statsSuccess = await dataService.updateStats({
      'project_count': _projectCountController.text.trim(),
      'years_experience': _yearsExpController.text.trim(),
      'expertise_areas': _expertiseController.text.trim(),
    });
    
    if (mounted) {
      setState(() => _isSaving = false);
      
      if (personalSuccess && statsSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ayarlar kaydedildi'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
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
    if (_isLoading) {
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
            Text(
              'Ayarlar',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'Kişisel bilgilerinizi ve site ayarlarını düzenleyin',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: Spacing.xxl),
            
            // Kişisel Bilgiler
            _buildSection('Kişisel Bilgiler', [
              _buildTextField(
                controller: _nameController,
                label: 'Ad Soyad',
                required: true,
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _titleController,
                label: 'Ünvan',
                hint: 'Multidisipliner Mühendis',
                required: true,
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _bioController,
                label: 'Kısa Biyografi',
                maxLines: 3,
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _detailedBioController,
                label: 'Detaylı Biyografi',
                maxLines: 4,
              ),
            ]),
            
            const SizedBox(height: Spacing.xxl),
            
            // İletişim
            _buildSection('İletişim', [
              _buildTextField(
                controller: _emailController,
                label: 'E-posta',
                hint: 'email@example.com',
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _locationController,
                label: 'Konum',
                hint: 'İstanbul, Türkiye',
              ),
            ]),
            
            const SizedBox(height: Spacing.xxl),
            
            // Sosyal Medya
            _buildSection('Sosyal Medya', [
              _buildTextField(
                controller: _githubController,
                label: 'GitHub URL',
                hint: 'https://github.com/username',
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _linkedinController,
                label: 'LinkedIn URL',
                hint: 'https://linkedin.com/in/username',
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _twitterController,
                label: 'Twitter URL',
                hint: 'https://twitter.com/username',
              ),
              const SizedBox(height: Spacing.lg),
              _buildTextField(
                controller: _websiteController,
                label: 'Web Sitesi',
                hint: 'https://example.com',
              ),
            ]),
            
            const SizedBox(height: Spacing.xxl),
            
            // İstatistikler
            _buildSection('İstatistikler (Ana Sayfada Gösterilir)', [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _projectCountController,
                      label: 'Proje Sayısı',
                      hint: '15+',
                    ),
                  ),
                  const SizedBox(width: Spacing.lg),
                  Expanded(
                    child: _buildTextField(
                      controller: _yearsExpController,
                      label: 'Yıl Deneyim',
                      hint: '5+',
                    ),
                  ),
                  const SizedBox(width: Spacing.lg),
                  Expanded(
                    child: _buildTextField(
                      controller: _expertiseController,
                      label: 'Uzmanlık Alanı',
                      hint: '3',
                    ),
                  ),
                ],
              ),
            ]),
            
            const SizedBox(height: Spacing.xxl),
            
            // Kaydet butonu
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save, size: 18),
                label: const Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xl,
                    vertical: Spacing.md,
                  ),
                ),
              ),
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
}
