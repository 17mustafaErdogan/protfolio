import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Harici tarayıcı veya e-posta istemcisinde bağlantı açar.
///
/// `https://...`, `mailto:...`, şemasız `github.com/user` veya yalnızca e-posta kabul eder.
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
