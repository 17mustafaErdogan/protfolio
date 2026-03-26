/// Paylaşılan form doğrulama yardımcıları (iletişim formu, ayarlar vb.).
class FormValidators {
  FormValidators._();

  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  static bool isValidEmail(String value) => emailRegex.hasMatch(value.trim());

  /// Boş geçerlidir; doluysa e-posta formatı kontrol edilir.
  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!isValidEmail(value)) return 'Geçerli bir e-posta adresi girin';
    return null;
  }

  /// Boş geçerlidir; doluysa http/https URL kontrolü.
  static String? optionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty) {
      return null;
    }
    return 'Geçerli bir URL girin (https://...)';
  }

  static String? requiredTrim(String? value, [String message = 'Bu alan gerekli']) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }
}
