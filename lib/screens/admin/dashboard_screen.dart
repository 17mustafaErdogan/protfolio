import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/data_service.dart';
import '../../utils/responsive.dart';

/// Admin dashboard ekranı.
/// 
/// Özet istatistikler ve hızlı erişim butonları içerir.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final dataService = context.read<DataService>();
    final stats = await dataService.getDashboardStats();
    
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
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
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'Portfolyo yönetim paneline hoş geldiniz',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: Spacing.xxl),
          
          // İstatistik kartları
          _buildStatsGrid(),
          const SizedBox(height: Spacing.xxl),
          
          // Hızlı erişim
          Text(
            'Hızlı Erişim',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.lg),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDesktop = Responsive.isDesktop(context);
    final crossAxisCount = isDesktop ? 4 : 2;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: Spacing.lg,
      mainAxisSpacing: Spacing.lg,
      childAspectRatio: isDesktop ? 1.5 : 1.2,
      children: [
        _StatCard(
          icon: Icons.folder_outlined,
          label: 'Projeler',
          value: '${_stats['projects'] ?? 0}',
          color: AppTheme.accent,
          onTap: () => context.go('/admin/projects'),
        ),
        _StatCard(
          icon: Icons.psychology_outlined,
          label: 'Beceriler',
          value: '${_stats['skills'] ?? 0}',
          color: AppTheme.accentGreen,
          onTap: () => context.go('/admin/skills'),
        ),
        _StatCard(
          icon: Icons.school_outlined,
          label: 'Eğitim',
          value: '${_stats['education'] ?? 0}',
          color: AppTheme.accentOrange,
          onTap: () => context.go('/admin/cv'),
        ),
        _StatCard(
          icon: Icons.work_outline,
          label: 'Deneyim',
          value: '${_stats['workExperience'] ?? 0}',
          color: AppTheme.software,
          onTap: () => context.go('/admin/cv'),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: Spacing.md,
      runSpacing: Spacing.md,
      children: [
        _QuickActionButton(
          icon: Icons.add,
          label: 'Yeni Proje',
          onTap: () => context.go('/admin/projects/new'),
        ),
        _QuickActionButton(
          icon: Icons.person_outline,
          label: 'Profili Düzenle',
          onTap: () => context.go('/admin/settings'),
        ),
        _QuickActionButton(
          icon: Icons.description_outlined,
          label: 'CV Güncelle',
          onTap: () => context.go('/admin/cv'),
        ),
        _QuickActionButton(
          icon: Icons.open_in_new,
          label: 'Siteyi Görüntüle',
          onTap: () => context.go('/'),
        ),
      ],
    );
  }
}

/// İstatistik kartı.
class _StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: _isHovered ? AppTheme.surfaceLight : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? widget.color.withOpacity(0.3) : AppTheme.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                widget.value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hızlı erişim butonu.
class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.md,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? AppTheme.accent.withOpacity(0.1) : AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? AppTheme.accent : AppTheme.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: _isHovered ? AppTheme.accent : AppTheme.textSecondary,
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _isHovered ? AppTheme.accent : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
