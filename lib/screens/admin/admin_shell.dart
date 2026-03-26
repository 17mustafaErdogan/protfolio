import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive.dart';

/// Admin paneli ana layout'u.
/// 
/// Sol tarafta navigasyon menüsü, sağ tarafta içerik alanı.
/// Mobilde hamburger menü ile çalışır.
class AdminShell extends StatelessWidget {
  final Widget child;
  
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: isDesktop ? null : _buildMobileAppBar(context),
      drawer: isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          // Desktop sidebar
          if (isDesktop) _AdminSidebar(),
          
          // İçerik alanı
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  /// Mobil app bar
  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.surface,
      title: const Text('Admin Panel'),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go('/'),
          tooltip: 'Siteye Git',
        ),
      ],
    );
  }

  /// Mobil drawer
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: _AdminSidebar(),
    );
  }
}

/// Admin sidebar navigasyon menüsü.
class _AdminSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          right: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),
          
          const Divider(height: 1),
          
          // Navigasyon öğeleri
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: Spacing.md),
              children: [
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  path: '/admin',
                  isSelected: currentPath == '/admin',
                ),
                _NavItem(
                  icon: Icons.folder_outlined,
                  label: 'Projeler',
                  path: '/admin/projects',
                  isSelected: currentPath.startsWith('/admin/projects'),
                ),
                _NavItem(
                  icon: Icons.psychology_outlined,
                  label: 'Beceriler',
                  path: '/admin/skills',
                  isSelected: currentPath == '/admin/skills',
                ),
                _NavItem(
                  icon: Icons.star_outline,
                  label: 'Uzmanlık Alanları',
                  path: '/admin/expertise-areas',
                  isSelected: currentPath == '/admin/expertise-areas',
                ),
                _NavItem(
                  icon: Icons.description_outlined,
                  label: 'CV Bilgileri',
                  path: '/admin/cv',
                  isSelected: currentPath == '/admin/cv',
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  label: 'Ayarlar',
                  path: '/admin/settings',
                  isSelected: currentPath == '/admin/settings',
                ),
                _NavItem(
                  icon: Icons.mail_outline,
                  label: 'Mesajlar',
                  path: '/admin/messages',
                  isSelected: currentPath == '/admin/messages',
                ),

                const Divider(height: Spacing.xl),
                
                // Siteye git
                _NavItem(
                  icon: Icons.open_in_new,
                  label: 'Siteyi Görüntüle',
                  path: '/',
                  isSelected: false,
                  isExternal: true,
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Footer - Çıkış yap
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: AppTheme.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Panel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Portfolyo Yönetimi',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final authService = context.watch<AuthService>();
    
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        children: [
          // Kullanıcı bilgisi
          if (authService.userEmail != null) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.accent.withOpacity(0.1),
                  child: Text(
                    authService.userEmail![0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    authService.userEmail!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
          ],
          
          // Çıkış butonu
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await authService.signOut();
                if (context.mounted) {
                  context.go('/');
                }
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Çıkış Yap'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: const BorderSide(color: AppTheme.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sidebar navigasyon öğesi.
class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String path;
  final bool isSelected;
  final bool isExternal;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.isSelected,
    this.isExternal = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () {
          // Mobil drawer'ı kapat
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.of(context).pop();
          }
          context.go(widget.path);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.accent.withOpacity(0.1)
                : _isHovered
                    ? AppTheme.surfaceLight
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? Border.all(color: AppTheme.accent.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.isSelected
                    ? AppTheme.accent
                    : _isHovered
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: widget.isSelected
                        ? AppTheme.accent
                        : _isHovered
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                    fontWeight: widget.isSelected ? FontWeight.w600 : null,
                  ),
                ),
              ),
              if (widget.isExternal)
                Icon(
                  Icons.open_in_new,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
