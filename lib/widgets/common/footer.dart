import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/data_service.dart';
import '../../utils/open_url.dart';
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
///
/// Linkler [personal_info] (GitHub, LinkedIn, email) ile doldurulur.
class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  String _githubUrl = 'https://github.com';
  String _linkedinUrl = 'https://www.linkedin.com';
  String _emailUrl = 'mailto:contact@example.com';
  String? _twitterUrl;
  String? _websiteUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLinks());
  }

  Future<void> _loadLinks() async {
    if (!mounted) return;
    final ds = context.read<DataService>();
    final personalInfo = await ds.getPersonalInfo();
    if (!mounted) return;
    setState(() {
      final gh = personalInfo?['github_url']?.toString().trim();
      if (gh != null && gh.isNotEmpty) {
        _githubUrl = gh.contains('://') ? gh : 'https://$gh';
      }
      final li = personalInfo?['linkedin_url']?.toString().trim();
      if (li != null && li.isNotEmpty) {
        _linkedinUrl = li.contains('://') ? li : 'https://$li';
      }
      final em = personalInfo?['email']?.toString().trim();
      if (em != null && em.isNotEmpty) {
        _emailUrl =
            em.toLowerCase().startsWith('mailto:') ? em : 'mailto:$em';
      }
          final tw = personalInfo?['twitter_url']?.toString().trim();
          if (tw != null && tw.isNotEmpty) {
        _twitterUrl = tw.contains('://') ? tw : 'https://$tw';
      }
      final ws = personalInfo?['website_url']?.toString().trim();
      if (ws != null && ws.isNotEmpty) {
        _websiteUrl = ws.contains('://') ? ws : 'https://$ws';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
            Wrap(
              alignment: WrapAlignment.center,
              spacing: Spacing.lg,
              runSpacing: Spacing.sm,
              children: [
                _SocialLink(
                  icon: Icons.code,
                  label: 'GitHub',
                  url: _githubUrl,
                ),
                _SocialLink(
                  icon: Icons.work_outline,
                  label: 'LinkedIn',
                  url: _linkedinUrl,
                ),
                _SocialLink(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  url: _emailUrl,
                ),
                if (_twitterUrl != null)
                  _SocialLink(
                    icon: Icons.alternate_email,
                    label: 'Twitter',
                    url: _twitterUrl!,
                  ),
                if (_websiteUrl != null)
                  _SocialLink(
                    icon: Icons.language,
                    label: 'Web',
                    url: _websiteUrl!,
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
        onTap: () => openExternalUrl(context, widget.url),
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
