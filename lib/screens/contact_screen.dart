import 'package:flutter/material.dart';
import '../config/theme.dart';
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
            
            SizedBox(height: Spacing.sectionPadding),
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
/// - Email, GitHub, LinkedIn linkleri
/// - Müsaitlik durumu göstergesi
class _ContactInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Text(
          'Bana Ulaşın',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: Spacing.md),
        
        // Açıklama
        Text(
          'Proje fikirleri, iş birliği önerileri veya sadece merhaba '
          'demek için aşağıdaki kanallardan bana ulaşabilirsiniz.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: Spacing.xl),
        
        // İletişim kanalları
        _ContactItem(
          icon: Icons.mail_outline,
          label: 'Email',
          value: 'contact@example.com',
          color: AppTheme.accent,
        ),
        const SizedBox(height: Spacing.md),
        _ContactItem(
          icon: Icons.code,
          label: 'GitHub',
          value: 'github.com/username',
          color: AppTheme.textPrimary,
        ),
        const SizedBox(height: Spacing.md),
        _ContactItem(
          icon: Icons.work_outline,
          label: 'LinkedIn',
          value: 'linkedin.com/in/username',
          color: AppTheme.electronics,
        ),
        
        const SizedBox(height: Spacing.xxl),
        
        // Müsaitlik durumu göstergesi
        Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: AppTheme.accentGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.accentGreen.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              // Yeşil durum noktası
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  'Yeni projelere açığım',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.accentGreen,
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
  
  /// Tema rengi
  final Color color;
  
  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
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
  /// Form validasyonu için key
  final _formKey = GlobalKey<FormState>();
  
  /// Form alanları için controller'lar
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  @override
  void dispose() {
    // Controller'ları temizle
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form başlığı
            Text(
              'Mesaj Gönder',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: Spacing.lg),
            
            // İsim ve Email yan yana
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            
            // Konu alanı
            _FormField(
              controller: _subjectController,
              label: 'Konu',
              hint: 'Mesajınızın konusu',
            ),
            const SizedBox(height: Spacing.md),
            
            // Mesaj alanı (çok satırlı)
            _FormField(
              controller: _messageController,
              label: 'Mesaj',
              hint: 'Mesajınızı buraya yazın...',
              maxLines: 5,
            ),
            const SizedBox(height: Spacing.lg),
            
            // Gönder butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Form gönderimi başarılı
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Mesajınız gönderildi!'),
                        backgroundColor: AppTheme.accentGreen,
                      ),
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: Spacing.sm),
                  child: Text('Gönder'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Form alanı widget'ı - etiketli TextFormField.
/// 
/// Özelleştirilebilir özellikler:
/// - [maxLines]: Çok satırlı giriş için
/// - [keyboardType]: Email, telefon vb. için özel klavye
class _FormField extends StatelessWidget {
  /// Metin controller'ı
  final TextEditingController controller;
  
  /// Alan üstündeki etiket
  final String label;
  
  /// Placeholder metni
  final String hint;
  
  /// Satır sayısı (varsayılan: 1)
  final int maxLines;
  
  /// Klavye tipi (opsiyonel)
  final TextInputType? keyboardType;
  
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiket
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        
        // Giriş alanı
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
          // Basit validasyon
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Bu alan gerekli';
            }
            return null;
          },
        ),
      ],
    );
  }
}
