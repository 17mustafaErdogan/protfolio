import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../utils/responsive.dart';

/// Sayfa üstünde bulunan navigasyon çubuğu.
/// 
/// Bu widget, tüm sayfalarda görünen üst navigasyon barını sağlar.
/// 
/// Responsive davranış:
/// - Masaüstünde: Yatay link listesi
/// - Mobilde: Hamburger menü butonu (bottom sheet açar)
/// 
/// İçerik:
/// - Sol: Logo/site adı (ana sayfaya yönlendirir)
/// - Sağ: Navigasyon linkleri veya menü butonu
class NavBar extends StatelessWidget {
  const NavBar({super.key});
  
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.border,
            width: 1,
          ),
        ),
      ),
      child: ContentContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo / Site adı - tıklandığında ana sayfaya yönlendirir
            InkWell(
              onTap: () => context.go(AppRoutes.home),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                child: Row(
                  children: [
                    // Yeşil durum göstergesi
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Text(
                      'portfolio',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Navigasyon bölümü - responsive
            if (isMobile)
              _MobileMenuButton()
            else
              Row(
                children: [
                  _NavLink(
                    label: 'Projeler',
                    path: AppRoutes.projects,
                  ),
                  const SizedBox(width: Spacing.lg),
                  _NavLink(
                    label: 'Hakkımda',
                    path: AppRoutes.about,
                  ),
                  const SizedBox(width: Spacing.lg),
                  _NavLink(
                    label: 'İletişim',
                    path: AppRoutes.contact,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Masaüstü navigasyon linki.
/// 
/// Hover ve aktif durumlarına göre farklı stiller uygular.
/// Aktif sayfa linki vurgu renginde gösterilir.
class _NavLink extends StatefulWidget {
  /// Link metni
  final String label;
  
  /// Yönlendirilecek sayfa yolu
  final String path;
  
  const _NavLink({required this.label, required this.path});
  
  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  /// Mouse üzerinde mi?
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    // Mevcut URL'i kontrol et
    final currentPath = GoRouterState.of(context).uri.path;
    
    // Aktif link kontrolü - proje detay sayfaları için özel kontrol
    final isActive = currentPath == widget.path || 
        (widget.path == AppRoutes.projects && currentPath.startsWith('/projects'));
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () => context.go(widget.path),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isActive 
                  ? AppTheme.accent 
                  : _isHovered 
                      ? AppTheme.textPrimary 
                      : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobil hamburger menü butonu.
/// 
/// Tıklandığında [_MobileMenu] bottom sheet'ini açar.
class _MobileMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: AppTheme.textPrimary),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppTheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) => const _MobileMenu(),
        );
      },
    );
  }
}

/// Mobil navigasyon menüsü (bottom sheet).
/// 
/// Tüm sayfa linklerini dikey liste halinde gösterir.
/// Her linke tıklandığında menü kapanır ve sayfaya yönlendirilir.
class _MobileMenu extends StatelessWidget {
  const _MobileMenu();
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sürükleme göstergesi (drag handle)
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            
            // Menü öğeleri
            _MobileMenuItem(
              label: 'Ana Sayfa',
              icon: Icons.home_outlined,
              path: AppRoutes.home,
            ),
            _MobileMenuItem(
              label: 'Projeler',
              icon: Icons.folder_outlined,
              path: AppRoutes.projects,
            ),
            _MobileMenuItem(
              label: 'Hakkımda',
              icon: Icons.person_outline,
              path: AppRoutes.about,
            ),
            _MobileMenuItem(
              label: 'İletişim',
              icon: Icons.mail_outline,
              path: AppRoutes.contact,
            ),
            const SizedBox(height: Spacing.md),
          ],
        ),
      ),
    );
  }
}

/// Mobil menüdeki tek bir link öğesi.
/// 
/// İkon + metin şeklinde ListTile formatında gösterilir.
class _MobileMenuItem extends StatelessWidget {
  /// Menü öğesi metni
  final String label;
  
  /// Sol taraftaki ikon
  final IconData icon;
  
  /// Yönlendirilecek sayfa yolu
  final String path;
  
  const _MobileMenuItem({
    required this.label,
    required this.icon,
    required this.path,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppTheme.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Menüyü kapat
        context.go(path); // Sayfaya yönlendir
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
