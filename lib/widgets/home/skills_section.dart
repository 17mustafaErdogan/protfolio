import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/data_service.dart';
import '../../utils/responsive.dart';
import '../common/section_title.dart';

/// Uzmanlık alanları bölümü.
/// 
/// Supabase'den becerileri yükler ve kategorilere göre gösterir.
class SkillsSection extends StatefulWidget {
  const SkillsSection({super.key});

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> {
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    
    // Beceri yoksa gösterme
    if (_skills.isEmpty && !_isLoading) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: Spacing.xxl),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.5),
        border: Border.symmetric(
          horizontal: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: ContentContainer(
        child: Column(
          children: [
            const SectionTitle(
              title: 'Uzmanlık Alanları',
              subtitle: 'Üzerinde çalıştığım ana disiplinler',
            ),
            const SizedBox(height: Spacing.xl),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _SkillCategory(
                    category: 'electronics',
                    categoryName: 'Elektronik',
                    color: AppTheme.electronics,
                    icon: '⚡',
                    skills: _skills.where((s) => s['category'] == 'electronics').toList(),
                  )),
                  Expanded(child: _SkillCategory(
                    category: 'mechanical',
                    categoryName: 'Mekanik',
                    color: AppTheme.mechanical,
                    icon: '⚙️',
                    skills: _skills.where((s) => s['category'] == 'mechanical').toList(),
                  )),
                  Expanded(child: _SkillCategory(
                    category: 'software',
                    categoryName: 'Yazılım',
                    color: AppTheme.software,
                    icon: '💻',
                    skills: _skills.where((s) => s['category'] == 'software').toList(),
                  )),
                ],
              )
            else
              Column(
                children: [
                  _SkillCategory(
                    category: 'electronics',
                    categoryName: 'Elektronik',
                    color: AppTheme.electronics,
                    icon: '⚡',
                    skills: _skills.where((s) => s['category'] == 'electronics').toList(),
                  ),
                  const SizedBox(height: Spacing.lg),
                  _SkillCategory(
                    category: 'mechanical',
                    categoryName: 'Mekanik',
                    color: AppTheme.mechanical,
                    icon: '⚙️',
                    skills: _skills.where((s) => s['category'] == 'mechanical').toList(),
                  ),
                  const SizedBox(height: Spacing.lg),
                  _SkillCategory(
                    category: 'software',
                    categoryName: 'Yazılım',
                    color: AppTheme.software,
                    icon: '💻',
                    skills: _skills.where((s) => s['category'] == 'software').toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SkillCategory extends StatelessWidget {
  final String category;
  final String categoryName;
  final Color color;
  final String icon;
  final List<Map<String, dynamic>> skills;
  
  const _SkillCategory({
    required this.category,
    required this.categoryName,
    required this.color,
    required this.icon,
    required this.skills,
  });
  
  @override
  Widget build(BuildContext context) {
    // Boş kategori gösterme
    if (skills.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  categoryName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          
          // Skills List
          ...skills.map((skill) => Padding(
            padding: const EdgeInsets.only(bottom: Spacing.md),
            child: _SkillItem(skill: skill, color: color),
          )),
        ],
      ),
    );
  }
}

class _SkillItem extends StatelessWidget {
  final Map<String, dynamic> skill;
  final Color color;
  
  const _SkillItem({required this.skill, required this.color});
  
  @override
  Widget build(BuildContext context) {
    final proficiency = skill['proficiency_percent'] ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              skill['name'] ?? '',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              '$proficiency%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        if (skill['description'] != null && skill['description'].isNotEmpty)
          Text(
            skill['description'],
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: Spacing.sm),
        // Progress bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: proficiency / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
