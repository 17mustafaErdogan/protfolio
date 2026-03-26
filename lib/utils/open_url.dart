import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Harici tarayıcı veya e-posta istemcisinde bağlantı açar.
///
/// [urlString]: `https://...`, `mailto:...`, şemasız `github.com/user` veya yalnızca e-posta.
/// [context] gereklidir (hata SnackBar'ı için).
Future<void> openExternalUrl(BuildContext context, String urlString) async {
  final trimmed = urlString.trim();
  if (trimmed.isEmpty) return;

  String href = trimmed;

  if (href.toLowerCase().startsWith('mailto:')) {
    final uri = Uri.tryParse(href);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geçersiz e-posta bağlantısı')),
        );
      }
      return;
    }
    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta uygulaması açılamadı')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta uygulaması açılamadı')),
        );
      }
    }
    return;
  }

  if (href.contains('@') &&
      !href.contains('://') &&
      !href.contains('/') &&
      !href.contains(' ')) {
    final uri = Uri.parse('mailto:$href');
    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta uygulaması açılamadı')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta uygulaması açılamadı')),
        );
      }
    }
    return;
  }

  if (!href.contains('://')) {
    href = 'https://$href';
  }

  final uri = Uri.tryParse(href);
  if (uri == null || !uri.hasScheme) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçersiz bağlantı')),
      );
    }
    return;
  }

  try {
    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağlantı açılamadı')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağlantı açılamadı')),
      );
    }
  }
}

/// Context gerektirmeyen URL açma yardımcısı.
///
/// [raw]: `https://...`, `mailto:...`, şemasız URL veya yalnızca e-posta adresi.
/// Hata durumunda isteğe bağlı [context] ile SnackBar gösterir.
Future<void> tryLaunchUrlString(String? raw, {BuildContext? context}) async {
  if (raw == null) return;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return;

  String href = trimmed;

  if (href.toLowerCase().startsWith('mailto:')) {
    final uri = Uri.tryParse(href);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    return;
  }

  if (href.contains('@') &&
      !href.contains('://') &&
      !href.contains('/') &&
      !href.contains(' ')) {
    final uri = Uri.parse('mailto:$href');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    return;
  }

  if (!href.contains('://')) {
    href = 'https://$href';
  }

  final uri = Uri.tryParse(href);
  if (uri == null || !uri.hasScheme) {
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçersiz bağlantı')),
      );
    }
    return;
  }

  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağlantı açılamadı')),
      );
    }
  } catch (_) {
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bağlantı açılamadı')),
      );
    }
  }
}
