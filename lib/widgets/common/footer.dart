import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../utils/responsive.dart';

/// Sayfa altında bulunan footer bileşeni.
/// 
/// İçerik:
/// - Sosyal medya linkleri (GitHub, LinkedIn, Email)
/// - Telif hakkı metni (gizli admin tetikleyici)
/// - "Flutter ile geliştirildi" notu
/// 
/// Gizli Özellik: Copyright metnine 3 saniye içinde 7 kez tıklanırsa
/// admin giriş sayfasına (/login) yönlendirir.
/// 
/// Tüm sayfalarda [ShellScaffold] aracılığıyla gösterilir.
class Footer extends StatelessWidget {
  const Footer({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.border,
            width: 1,
          ),
        ),
      ),
      child: ContentContainer(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.contentPadding(context),
          vertical: Spacing.xl,
        ),
        child: Column(
          children: [
            // Sosyal medya linkleri
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SocialLink(
                  icon: Icons.code,
                  label: 'GitHub',
                  url: 'https://github.com',
                ),
                const SizedBox(width: Spacing.lg),
                _SocialLink(
                  icon: Icons.work_outline,
                  label: 'LinkedIn',
                  url: 'https://linkedin.com',
                ),
                const SizedBox(width: Spacing.lg),
                _SocialLink(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  url: 'mailto:contact@example.com',
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            const Divider(),
            const SizedBox(height: Spacing.lg),
            
            // Telif hakkı - Gizli admin tetikleyici
            const _SecretAdminTrigger(),
            const SizedBox(height: Spacing.xs),
            
            // Teknoloji notu
            Text(
              'Flutter ile geliştirildi',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gizli admin giriş tetikleyicisi.
/// 
/// Copyright metnine 3 saniye içinde 7 kez tıklanırsa
/// admin giriş sayfasına (/login) yönlendirir.
/// 
/// Bu özellik tamamen gizlidir - görsel bir ipucu yoktur.
/// Android'deki "Geliştirici Seçenekleri" açma yöntemine benzer.
class _SecretAdminTrigger extends StatefulWidget {
  const _SecretAdminTrigger();

  @override
  State<_SecretAdminTrigger> createState() => _SecretAdminTriggerState();
}

class _SecretAdminTriggerState extends State<_SecretAdminTrigger> {
  /// Tıklama sayacı
  int _tapCount = 0;
  
  /// İlk tıklamanın zamanı
  DateTime? _firstTapTime;
  
  /// Tetikleme için gereken tıklama sayısı
  static const int _requiredTaps = 7;
  
  /// Tıklamaların geçerli sayılacağı süre (saniye)
  static const int _timeWindowSeconds = 3;

  /// Tıklama işleyicisi.
  /// 
  /// 3 saniye içinde 7 tıklama olursa /login sayfasına yönlendirir.
  void _onTap() {
    final now = DateTime.now();
    
    // Zaman penceresi kontrolü
    // İlk tıklamadan bu yana 3 saniyeden fazla geçtiyse sıfırla
    if (_firstTapTime != null) {
      final elapsed = now.difference(_firstTapTime!).inSeconds;
      if (elapsed >= _timeWindowSeconds) {
        _tapCount = 0;
        _firstTapTime = null;
      }
    }
    
    // İlk tıklama ise zamanı kaydet
    _firstTapTime ??= now;
    
    // Sayacı artır
    _tapCount++;
    
    // Kalan tıklama sayısını göster (opsiyonel - debug için)
    // Son 3 tıklamada kullanıcıya ipucu verebiliriz
    if (_tapCount >= _requiredTaps - 2 && _tapCount < _requiredTaps) {
      final remaining = _requiredTaps - _tapCount;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$remaining...'),
          duration: const Duration(milliseconds: 500),
          behavior: SnackBarBehavior.floating,
          width: 60,
          backgroundColor: AppTheme.surface,
        ),
      );
    }
    
    // Hedef tıklama sayısına ulaşıldıysa login'e git
    if (_tapCount >= _requiredTaps) {
      _tapCount = 0;
      _firstTapTime = null;
      
      // Snackbar'ları temizle
      ScaffoldMessenger.of(context).clearSnackBars();
      
      // Login sayfasına yönlendir
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.xs,
        ),
        child: Text(
          '© ${DateTime.now().year} · Mühendislik Portföyü',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

/// Sosyal medya link butonu.
/// 
/// İkon + metin içeren, hover efektli interaktif buton.
/// Tıklandığında ilgili URL'e yönlendirir.
class _SocialLink extends StatefulWidget {
  /// Buton ikonu
  final IconData icon;
  
  /// Buton metni
  final String label;
  
  /// Yönlendirilecek URL
  final String url;
  
  const _SocialLink({
    required this.icon,
    required this.label,
    required this.url,
  });
  
  @override
  State<_SocialLink> createState() => _SocialLinkState();
}

class _SocialLinkState extends State<_SocialLink> {
  /// Mouse üzerinde mi?
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () {
          // URL launcher entegrasyonu buraya eklenebilir
          // launchUrl(Uri.parse(widget.url));
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? AppTheme.surfaceLight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered ? AppTheme.border : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: _isHovered ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _isHovered ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
