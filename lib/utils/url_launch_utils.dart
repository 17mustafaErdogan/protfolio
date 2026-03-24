import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Harici bağlantı açar (tarayıcı, e-posta istemcisi).
///
/// [raw] `https://...`, `mailto:...`, veya şemasız `github.com/user` olabilir.
Future<void> tryLaunchUrlString(
  String? raw, {
  BuildContext? context,
}) async {
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

  // Sadece e-posta adresi
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
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
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
