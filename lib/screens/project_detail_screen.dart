import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../services/data_service.dart';
import '../utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tek bir projenin detaylı dokümantasyonunu gösteren sayfa.
/// Veriyi Supabase'den dinamik olarak yükler.
class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  Map<String, dynamic>? _project;
  List<Map<String, dynamic>> _expertiseAreas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = context.read<DataService>();
    final results = await Future.wait([
      ds.getProject(widget.projectId),
      ds.getExpertiseAreas(),
    ]);
    if (mounted) {
      final project = results[0] as Map<String, dynamic>?;
      setState(() {
        _project = project;
        _expertiseAreas =
            (results[1] as List).cast<Map<String, dynamic>>();
        _error = project == null ? 'Proje bulunamadı.' : null;
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? get _area {
    final areaId = _project?['expertise_area_id'] as String?;
    if (areaId == null) return null;
    return _expertiseAreas.firstWhere(
      (a) => a['id'] == areaId,
      orElse: () => {},
    );
  }

  Color get _areaColor {
    final hex =
        (_area?['color'] as String?)?.replaceFirst('#', '') ?? '';
    try {
      return Color(0xFF000000 | int.parse(hex, radix: 16));
    } catch (_) {
      return AppTheme.accent;
    }
  }

  String get _areaName => (_area?['name'] as String?) ?? '';

  String _formatDateRange() {
    final p = _project!;
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];

    DateTime? parseDate(String? s) =>
        s != null ? DateTime.tryParse(s) : null;

    final start =
        parseDate(p['start_date'] as String?) ?? parseDate(p['date'] as String?);
    final end = parseDate(p['end_date'] as String?);

    if (start == null) return '';
    final startStr = '${months[start.month - 1]} ${start.year}';
    if (end == null) return '$startStr – Devam Ediyor';
    if (start.year == end.year && start.month == end.month) return startStr;
    return '$startStr – ${months[end.month - 1]} ${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: Spacing.md),
            Text(_error!,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppTheme.textMuted)),
            const SizedBox(height: Spacing.lg),
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.projects),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Projelere Dön'),
            ),
          ],
        ),
      );
    }

    final project = _project!;
    final isDesktop = Responsive.isDesktop(context);
    final sectionPadding = Responsive.sectionPadding(context);
    final color = _areaColor;
    final techs = (project['technologies'] as List?)?.cast<String>() ?? [];
    final tags = (project['tags'] as List?)?.cast<String>() ?? [];
    final dateStr = _formatDateRange();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.xl),
      child: ContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Geri butonu
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.projects),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Projelere Dön'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: Spacing.lg),

            // Kategori etiketi + tarih satırı
            Wrap(
              spacing: Spacing.md,
              runSpacing: Spacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (_areaName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm, vertical: Spacing.xs),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      _areaName,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: color),
                    ),
                  ),
                if (dateStr.isNotEmpty)
                  Text(
                    dateStr,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: AppTheme.textMuted),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.md),

            // Başlık
            Text(
              project['title'] ?? '',
              style: isDesktop
                  ? Theme.of(context).textTheme.displayMedium
                  : Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: Spacing.sm),

            // Alt başlık
            if ((project['subtitle'] as String?)?.isNotEmpty == true)
              Text(
                project['subtitle'],
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: Spacing.lg),

            // Teknolojiler
            if (techs.isNotEmpty)
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: techs
                    .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm, vertical: Spacing.xs),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(t,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      color: AppTheme.textSecondary)),
                        ))
                    .toList(),
              ),

            // Etiketler
            if (tags.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.xs,
                runSpacing: Spacing.xs,
                children: tags
                    .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.xs, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(t,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppTheme.textMuted)),
                        ))
                    .toList(),
              ),
            ],

            // GitHub / Demo linkleri
            if (project['github_url'] != null || project['demo_url'] != null) ...[
              const SizedBox(height: Spacing.lg),
              Wrap(
                spacing: Spacing.md,
                children: [
                  if (project['github_url'] != null)
                    OutlinedButton.icon(
                      onPressed: () {
                        launchUrl(Uri.parse(project['github_url']));
                      },
                      icon: const Icon(Icons.code, size: 18),
                      label: const Text('Kaynak Kod'),
                    ),
                  if (project['demo_url'] != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        launchUrl(Uri.parse(project['demo_url']));
                      },
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Demo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: AppTheme.background,
                      ),
                    ),
                ],
              ),
            ],

            const SizedBox(height: Spacing.xxl),
            const Divider(),
            const SizedBox(height: Spacing.xxl),

            // Dokümantasyon bölümleri
            _DocSection(
              number: '01',
              title: 'Problem / Amaç',
              content: project['problem'],
              color: color,
            ),
            _DocSection(
              number: '02',
              title: 'Yaklaşım',
              content: project['approach'],
              color: color,
            ),
            _DocSection(
              number: '03',
              title: 'Uygulama',
              content: project['implementation'],
              color: color,
            ),
            _DocSection(
              number: '04',
              title: 'Sonuçlar',
              content: project['results'],
              color: color,
            ),
            _DocSection(
              number: '05',
              title: 'Öğrenilenler',
              content: project['lessons_learned'],
              color: color,
              isLast: true,
            ),

            SizedBox(height: sectionPadding),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Dokümantasyon bölümü widget'ı
// ──────────────────────────────────────────────
class _DocSection extends StatelessWidget {
  final String number;
  final String title;
  final String? content;
  final Color color;
  final bool isLast;

  const _DocSection({
    required this.number,
    required this.title,
    required this.content,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    if (content == null || content!.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : Spacing.xxl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol: numara + bağlantı çizgisi
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: color, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    margin: const EdgeInsets.only(top: Spacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withOpacity(0.3),
                          color.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.lg),

          // Sağ: başlık + içerik
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: color),
                ),
                const SizedBox(height: Spacing.md),
                Container(
                  padding: const EdgeInsets.all(Spacing.lg),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: _MarkdownContent(content: content!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Basit markdown render widget'ı
// ──────────────────────────────────────────────
class _MarkdownContent extends StatelessWidget {
  final String content;

  const _MarkdownContent({required this.content});

  @override
  Widget build(BuildContext context) {
    final lines = content.trim().split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: Spacing.md));
      } else if (line.contains('**')) {
        widgets.add(_parseBold(context, line));
      } else if (line.trim().startsWith('-')) {
        widgets.add(Padding(
          padding:
              const EdgeInsets.only(left: Spacing.md, bottom: Spacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 8, right: Spacing.sm),
                decoration: BoxDecoration(
                  color: AppTheme.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Text(line.trim().substring(1).trim(),
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
        ));
      } else if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
        final m = RegExp(r'^(\d+)\.\s*(.*)').firstMatch(line.trim());
        if (m != null) {
          widgets.add(Padding(
            padding:
                const EdgeInsets.only(left: Spacing.md, bottom: Spacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text('${m.group(1)}.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w600,
                          )),
                ),
                Expanded(child: _parseBold(context, m.group(2) ?? '')),
              ],
            ),
          ));
        }
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: Spacing.xs),
          child: Text(line, style: Theme.of(context).textTheme.bodyMedium),
        ));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }

  Widget _parseBold(BuildContext context, String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final m in regex.allMatches(text)) {
      if (m.start > lastEnd) {
        spans.add(TextSpan(
            text: text.substring(lastEnd, m.start),
            style: Theme.of(context).textTheme.bodyMedium));
      }
      spans.add(TextSpan(
          text: m.group(1),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              )));
      lastEnd = m.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(
          text: text.substring(lastEnd),
          style: Theme.of(context).textTheme.bodyMedium));
    }
    return RichText(text: TextSpan(children: spans));
  }
}
