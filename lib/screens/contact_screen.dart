import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/data_service.dart';
import '../utils/form_validators.dart';
import '../utils/open_url.dart';
import '../utils/responsive.dart';
import '../widgets/common/section_title.dart';

/// İletişim sayfası - iletişim bilgileri ve mesaj formu.
///
/// Bu sayfa iki ana bölümden oluşur:
/// 1. İletişim Bilgileri - email, GitHub, LinkedIn ve müsaitlik durumu
/// 2. Mesaj Formu - isim, email, konu ve mesaj alanları
///
/// Responsive tasarım:
/// - Masaüstünde: Bilgiler solda (2 flex), form sağda (3 flex)
/// - Mobilde: Bilgiler üstte, form altta
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final sectionPadding = Responsive.sectionPadding(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.xxl),
      child: ContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sayfa başlığı
            const SectionTitle(
              title: 'İletişim',
              subtitle: 'Projeleriniz veya iş birliği fırsatları için bana ulaşın',
            ),
            const SizedBox(height: Spacing.xxl),
            
            // Responsive layout
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _ContactInfo(),
                  ),
                  const SizedBox(width: Spacing.xxl),
                  Expanded(
                    flex: 3,
                    child: _ContactForm(),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _ContactInfo(),
                  const SizedBox(height: Spacing.xxl),
                  _ContactForm(),
                ],
              ),
            
            SizedBox(height: sectionPadding),
          ],
        ),
      ),
    );
  }
}

/// İletişim bilgileri bölümü.
///
/// İçerir:
/// - Başlık ve açıklama
/// - Email, GitHub, LinkedIn linkleri ([personal_info] ile doldurulur)
/// - Müsaitlik durumu göstergesi
class _ContactInfo extends StatefulWidget {
  @override
  State<_ContactInfo> createState() => _ContactInfoState();
}

class _ContactInfoState extends State<_ContactInfo> {
  String _emailDisplay = 'contact@example.com';
  String _emailUrl = 'mailto:contact@example.com';
  String _githubDisplay = 'github.com/username';
  String _githubUrl = 'https://github.com/username';
  String _linkedinDisplay = 'linkedin.com/in/username';
  String _linkedinUrl = 'https://www.linkedin.com/in/username';
  String? _twitterUrl;
  String? _twitterDisplay;
  String? _websiteUrl;
  String? _websiteDisplay;
  bool _availabilityStatus = true;
  String _availabilityText = 'Yeni projelere açığım';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPersonalInfo());
  }

  Future<void> _loadPersonalInfo() async {
    if (!mounted) return;
    final ds = context.read<DataService>();
    final p = await ds.getPersonalInfo();
    if (!mounted) return;
    setState(() {
      final em = p?['email']?.toString().trim();
      if (em != null && em.isNotEmpty) {
        _emailDisplay =
            em.replaceFirst(RegExp(r'^mailto:', caseSensitive: false), '');
        _emailUrl =
            em.toLowerCase().startsWith('mailto:') ? em : 'mailto:$em';
      }
      final gh = p?['github_url']?.toString().trim();
      if (gh != null && gh.isNotEmpty) {
        _githubUrl = gh.contains('://') ? gh : 'https://$gh';
        _githubDisplay = _stripScheme(_githubUrl);
      }
      final li = p?['linkedin_url']?.toString().trim();
      if (li != null && li.isNotEmpty) {
        _linkedinUrl = li.contains('://') ? li : 'https://$li';
        _linkedinDisplay = _stripScheme(_linkedinUrl);
      }
      final tw = p?['twitter_url']?.toString().trim();
      if (tw != null && tw.isNotEmpty) {
        _twitterUrl = tw.contains('://') ? tw : 'https://$tw';
        _twitterDisplay = _stripScheme(_twitterUrl!);
      }
      final ws = p?['website_url']?.toString().trim();
      if (ws != null && ws.isNotEmpty) {
        _websiteUrl = ws.contains('://') ? ws : 'https://$ws';
        _websiteDisplay = _stripScheme(_websiteUrl!);
      }
      final avail = p?['availability_status'];
      if (avail != null) _availabilityStatus = avail == true;
      final availText = p?['availability_text']?.toString().trim();
      if (availText != null && availText.isNotEmpty) {
        _availabilityText = availText;
      }
    });
  }

  static String _stripScheme(String url) =>
      url.replaceFirst(RegExp(r'^https?://', caseSensitive: false), '');

  @override
  Widget build(BuildContext context) {
    final statusColor =
        _availabilityStatus ? AppTheme.accentGreen : AppTheme.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bana Ulaşın',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: Spacing.md),
        Text(
          'Proje fikirleri, iş birliği önerileri veya sadece merhaba '
          'demek için aşağıdaki kanallardan bana ulaşabilirsiniz.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: Spacing.xl),
        _ContactItem(
          icon: Icons.mail_outline,
          label: 'Email',
          value: _emailDisplay,
          url: _emailUrl,
          color: AppTheme.accent,
        ),
        const SizedBox(height: Spacing.md),
        _ContactItem(
          icon: Icons.code,
          label: 'GitHub',
          value: _githubDisplay,
          url: _githubUrl,
          color: AppTheme.textPrimary,
        ),
        const SizedBox(height: Spacing.md),
        _ContactItem(
          icon: Icons.work_outline,
          label: 'LinkedIn',
          value: _linkedinDisplay,
          url: _linkedinUrl,
          color: AppTheme.electronics,
        ),
        if (_twitterUrl != null) ...[
          const SizedBox(height: Spacing.md),
          _ContactItem(
            icon: Icons.alternate_email,
            label: 'Twitter / X',
            value: _twitterDisplay ?? _twitterUrl!,
            url: _twitterUrl!,
            color: AppTheme.software,
          ),
        ],
        if (_websiteUrl != null) ...[
          const SizedBox(height: Spacing.md),
          _ContactItem(
            icon: Icons.language,
            label: 'Web Sitesi',
            value: _websiteDisplay ?? _websiteUrl!,
            url: _websiteUrl!,
            color: AppTheme.accentOrange,
          ),
        ],
        const SizedBox(height: Spacing.xxl),
        Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  _availabilityText,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: statusColor,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tek bir iletişim kanalı öğesi (icon + label + value).
/// 
/// Hover efekti ile interaktif görünüm sağlar.
class _ContactItem extends StatefulWidget {
  /// Sol taraftaki ikon
  final IconData icon;
  
  /// Üstteki küçük etiket (örn: "Email")
  final String label;
  
  /// Alttaki değer (örn: "contact@example.com")
  final String value;

  /// Tıklanınca açılacak tam URL (mailto: veya https://)
  final String url;
  
  /// Tema rengi
  final Color color;
  
  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.url,
    required this.color,
  });
  
  @override
  State<_ContactItem> createState() => _ContactItemState();
}

class _ContactItemState extends State<_ContactItem> {
  bool _isHovered = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => openExternalUrl(context, widget.url),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: _isHovered ? AppTheme.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHovered ? AppTheme.border : Colors.transparent,
              ),
            ),
            child: Row(
          children: [
            // İkon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 20,
              ),
            ),
            const SizedBox(width: Spacing.md),
            
            // Metin içeriği
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    widget.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _isHovered ? widget.color : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Hover'da ok ikonu
            if (_isHovered)
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: widget.color,
              ),
          ],
            ),
          ),
        ),
      ),
    );
  }
}

/// İletişim formu widget'ı.
/// 
/// Form alanları:
/// - İsim ve Email (yan yana)
/// - Konu
/// - Mesaj (çok satırlı)
/// - Gönder butonu
/// 
/// Basit validasyon içerir (boş alan kontrolü).
class _ContactForm extends StatefulWidget {
  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;
  bool _sent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    final ds = context.read<DataService>();
    ds.clearError();
    final ok = await ds.sendContactMessage(
      name: _nameController.text,
      email: _emailController.text,
      subject: _subjectController.text,
      message: _messageController.text,
    );
    if (!mounted) return;
    setState(() => _isSending = false);
    if (ok) {
      setState(() => _sent = true);
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ds.errorMessage ?? 'Mesaj gönderilemedi. Lütfen tekrar deneyin.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.xl),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: _sent ? _buildSuccessState(context) : _buildForm(context),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: Spacing.xxl),
        Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: AppTheme.accentGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: AppTheme.accentGreen,
            size: 48,
          ),
        ),
        const SizedBox(height: Spacing.lg),
        Text(
          'Mesajınız Gönderildi!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.accentGreen,
              ),
        ),
        const SizedBox(height: Spacing.md),
        Text(
          'En kısa sürede size dönüş yapacağım.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMuted,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.xl),
        TextButton(
          onPressed: () => setState(() => _sent = false),
          child: const Text('Yeni Mesaj Gönder'),
        ),
        const SizedBox(height: Spacing.xxl),
      ],
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mesaj Gönder',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: Spacing.lg),
          Row(
            children: [
              Expanded(
                child: _FormField(
                  controller: _nameController,
                  label: 'İsim',
                  hint: 'Adınız',
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: _FormField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'email@example.com',
                  keyboardType: TextInputType.emailAddress,
                  isEmail: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          _FormField(
            controller: _subjectController,
            label: 'Konu',
            hint: 'Mesajınızın konusu',
          ),
          const SizedBox(height: Spacing.md),
          _FormField(
            controller: _messageController,
            label: 'Mesaj',
            hint: 'Mesajınızı buraya yazın...',
            maxLines: 5,
          ),
          const SizedBox(height: Spacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSending ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                child: _isSending
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.background,
                        ),
                      )
                    : const Text('Gönder'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Form alanı widget'ı - etiketli TextFormField.
///
/// Özelleştirilebilir özellikler:
/// - [maxLines]: Çok satırlı giriş için
/// - [keyboardType]: Email, telefon vb. için özel klavye
/// - [isEmail]: Email format validasyonu uygular
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool isEmail;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.isEmail = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: Spacing.xs),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
            filled: true,
            fillColor: AppTheme.surfaceLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppTheme.accent),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Bu alan gerekli';
            }
            if (isEmail && !FormValidators.isValidEmail(value)) {
              return 'Geçerli bir e-posta adresi girin';
            }
            return null;
          },
        ),
      ],
    );
  }
}
