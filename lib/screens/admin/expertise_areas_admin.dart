import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/data_service.dart';

/// Uzmanlık alanları yönetim ekranı.
///
/// - CRUD işlemleri
/// - Her alan: ad, renk, tarih aralığı (başlangıç → bitiş / devam ediyor)
/// - İş deneyimlerinden seçim → tarih aralığı otomatik doldurulur
/// - Kesişim alanları için üst alanlar (parent_ids)
class ExpertiseAreasAdminScreen extends StatefulWidget {
  const ExpertiseAreasAdminScreen({super.key});

  @override
  State<ExpertiseAreasAdminScreen> createState() =>
      _ExpertiseAreasAdminScreenState();
}

class _ExpertiseAreasAdminScreenState
    extends State<ExpertiseAreasAdminScreen> {
  List<Map<String, dynamic>> _areas = [];
  List<Map<String, dynamic>> _workExps = [];
  bool _isLoading = true;

  static const _colorPresets = [
    '#58A6FF', '#3FB950', '#D29922', '#F85149',
    '#BC8CFF', '#79C0FF', '#56D364', '#E3B341',
    '#FF7B72', '#A5D6FF',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ds = context.read<DataService>();
    final results = await Future.wait([
      ds.getExpertiseAreas(),
      ds.getWorkExperience(),
    ]);
    if (!mounted) return;
    setState(() {
      _areas = (results[0] as List).cast<Map<String, dynamic>>();
      _workExps = (results[1] as List).cast<Map<String, dynamic>>();
      _isLoading = false;
    });
  }

  // ──────────────────────────────────────────────────────────
  // Dialog
  // ──────────────────────────────────────────────────────────

  Future<void> _showDialog([Map<String, dynamic>? existing]) async {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    String selectedColor = existing?['color'] ?? _colorPresets.first;
    DateTime startDate = existing != null
        ? DateTime.tryParse(existing['start_date'] ?? '') ?? DateTime.now()
        : DateTime.now();
    DateTime? endDate = existing != null
        ? DateTime.tryParse(existing['end_date'] ?? '')
        : null;
    bool isOngoing = endDate == null;
    Set<String> linkedWeIds = ((existing?['linked_work_exp_ids'] as List?)
            ?.cast<String>() ??
        []).toSet();
    Set<String> selectedParentIds =
        ((existing?['parent_ids'] as List?)?.cast<String>() ?? []).toSet();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDs) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(isEdit ? 'Alanı Düzenle' : 'Yeni Uzmanlık Alanı'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alan adı
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Alan Adı *',
                      hintText: 'Mobil Geliştirme',
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),

                  // Renk seçimi
                  _sectionLabel(ctx, 'Renk'),
                  const SizedBox(height: Spacing.sm),
                  Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.sm,
                    children: _colorPresets.map((hex) {
                      final color = _hexColor(hex);
                      final sel = selectedColor == hex;
                      return GestureDetector(
                        onTap: () => setDs(() => selectedColor = hex),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: sel
                                  ? AppTheme.textPrimary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: sel
                              ? const Icon(Icons.check,
                                  size: 16, color: Colors.black)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: Spacing.lg),

                  // İş deneyimlerinden seç
                  if (_workExps.isNotEmpty) ...[
                    _sectionLabel(ctx, 'İş Deneyimlerinden Seç'),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'Seçilen deneyimlerin tarihleri tarih aralığını otomatik doldurur.',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    ..._workExps.map((we) {
                      final id = we['id'] as String;
                      final title = we['title'] as String? ?? '';
                      final company = we['company'] as String? ?? '';
                      final hasDates = we['start_date'] != null;
                      final checked = linkedWeIds.contains(id);
                      return CheckboxListTile(
                        dense: true,
                        title: Text('$title — $company'),
                        subtitle: hasDates
                            ? Text(
                                '${we['start_date']} → ${we['end_date'] ?? 'devam ediyor'}',
                                style: Theme.of(ctx)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppTheme.textMuted),
                              )
                            : Text(
                                we['period'] ?? '',
                                style: Theme.of(ctx)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppTheme.textMuted),
                              ),
                        value: checked,
                        activeColor: AppTheme.accent,
                        onChanged: (val) {
                          setDs(() {
                            if (val == true) {
                              linkedWeIds.add(id);
                            } else {
                              linkedWeIds.remove(id);
                            }
                            // Seçili deneyimlerin tarihlerinden otomatik doldur
                            _autoFillDatesFromWorkExp(
                              linkedWeIds,
                              (s, e, o) {
                                startDate = s;
                                endDate = e;
                                isOngoing = o;
                              },
                            );
                          });
                        },
                      );
                    }),
                    const SizedBox(height: Spacing.md),
                    const Divider(),
                    const SizedBox(height: Spacing.md),
                  ],

                  // Tarih aralığı — manuel
                  _sectionLabel(ctx, 'Tarih Aralığı'),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _dateTile(
                          ctx,
                          label: 'Başlangıç',
                          date: startDate,
                          onPick: () async {
                            final p = await showDatePicker(
                              context: ctx,
                              initialDate: startDate,
                              firstDate: DateTime(1990),
                              lastDate: DateTime.now(),
                            );
                            if (p != null) setDs(() => startDate = p);
                          },
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: isOngoing
                            ? Container(
                                padding: const EdgeInsets.all(Spacing.md),
                                decoration: BoxDecoration(
                                  color: AppTheme.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: AppTheme.border),
                                ),
                                child: Text(
                                  'Devam Ediyor',
                                  style: TextStyle(
                                      color: AppTheme.accentGreen,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            : _dateTile(
                                ctx,
                                label: 'Bitiş',
                                date: endDate!,
                                onPick: () async {
                                  final p = await showDatePicker(
                                    context: ctx,
                                    initialDate: endDate ?? DateTime.now(),
                                    firstDate: startDate,
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365 * 5)),
                                  );
                                  if (p != null) setDs(() => endDate = p);
                                },
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  CheckboxListTile(
                    dense: true,
                    title: const Text('Devam Ediyor'),
                    value: isOngoing,
                    activeColor: AppTheme.accent,
                    onChanged: (v) => setDs(() {
                      isOngoing = v ?? true;
                      if (isOngoing) endDate = null;
                    }),
                  ),
                  const SizedBox(height: Spacing.lg),

                  // Üst alanlar (kesişim)
                  if (_areas.isNotEmpty) ...[
                    _sectionLabel(ctx, 'Üst Alanlar (Kesişim — Opsiyonel)'),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'Bu alan birden fazla uzmanlığın kesişimiyse seçin.',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    ..._areas
                        .where((a) =>
                            !isEdit || a['id'] != existing['id'])
                        .map((a) {
                      final id = a['id'] as String;
                      return CheckboxListTile(
                        dense: true,
                        title: Text(a['name'] as String? ?? ''),
                        value: selectedParentIds.contains(id),
                        activeColor: AppTheme.accent,
                        onChanged: (v) => setDs(() => v == true
                            ? selectedParentIds.add(id)
                            : selectedParentIds.remove(id)),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final data = {
                  'name': nameCtrl.text.trim(),
                  'color': selectedColor,
                  'start_date':
                      startDate.toIso8601String().substring(0, 10),
                  'end_date': isOngoing
                      ? null
                      : endDate?.toIso8601String().substring(0, 10),
                  'linked_work_exp_ids': linkedWeIds.toList(),
                  'parent_ids': selectedParentIds.toList(),
                };
                final ds = context.read<DataService>();
                final ok = isEdit
                    ? await ds.updateExpertiseArea(
                        existing['id'] as String, data)
                    : await ds.createExpertiseArea(data);
                if (!mounted) return;
                Navigator.pop(ctx);
                if (ok) _load();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.background,
              ),
              child: Text(isEdit ? 'Kaydet' : 'Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  /// Seçili iş deneyimlerinin tarih aralıklarından start/end otomatik doldur.
  void _autoFillDatesFromWorkExp(
    Set<String> ids,
    void Function(DateTime start, DateTime? end, bool isOngoing) onResult,
  ) {
    final selected = _workExps.where((w) => ids.contains(w['id'])).toList();
    if (selected.isEmpty) return;

    DateTime? earliest;
    DateTime? latest;
    bool anyOngoing = false;

    for (final we in selected) {
      final s = DateTime.tryParse(we['start_date'] ?? '');
      final e = DateTime.tryParse(we['end_date'] ?? '');
      if (s == null) continue;
      if (earliest == null || s.isBefore(earliest)) earliest = s;
      if (e == null) {
        anyOngoing = true;
      } else {
        if (latest == null || e.isAfter(latest)) latest = e;
      }
    }

    if (earliest == null) return;
    onResult(earliest, anyOngoing ? null : latest, anyOngoing);
  }

  Future<void> _delete(Map<String, dynamic> area) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Silmek istediğinize emin misiniz?'),
        content: Text(
            '"${area['name']}" alanını silmek bu alana bağlı becerilerin kategorisini kaldırır.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final ok =
        await context.read<DataService>().deleteExpertiseArea(area['id'] as String);
    if (ok && mounted) _load();
  }

  Color _hexColor(String hex) {
    try {
      return Color(0xFF000000 | int.parse(hex.replaceFirst('#', ''), radix: 16));
    } catch (_) {
      return AppTheme.accent;
    }
  }

  int _calculateYears(Map<String, dynamic> area) {
    final now = DateTime.now();
    // linked_work_exp_ids üzerinden hesapla
    final linkedIds =
        (area['linked_work_exp_ids'] as List?)?.cast<String>() ?? [];
    if (linkedIds.isNotEmpty) {
      final linked = _workExps.where((w) => linkedIds.contains(w['id']));
      final ranges = <(DateTime, DateTime)>[];
      for (final we in linked) {
        final s = DateTime.tryParse(we['start_date'] ?? '');
        if (s == null) continue;
        final e = DateTime.tryParse(we['end_date'] ?? '') ?? now;
        ranges.add((s, e));
      }
      if (ranges.isNotEmpty) {
        ranges.sort((a, b) => a.$1.compareTo(b.$1));
        int months = 0;
        DateTime? ms, me;
        for (final r in ranges) {
          if (ms == null) {
            ms = r.$1;
            me = r.$2;
          } else if (!r.$1.isAfter(me!)) {
            if (r.$2.isAfter(me)) me = r.$2;
          } else {
            months += _months(ms, me);
            ms = r.$1;
            me = r.$2;
          }
        }
        if (ms != null && me != null) months += _months(ms, me);
        if (months > 0) return (months / 12).round().clamp(1, 99);
      }
    }
    final start = DateTime.tryParse(area['start_date'] ?? '');
    if (start == null) return 0;
    final end = DateTime.tryParse(area['end_date'] ?? '') ?? now;
    final months = _months(start, end);
    return (months / 12).round().clamp(1, 99);
  }

  int _months(DateTime a, DateTime b) =>
      ((b.year - a.year) * 12 + (b.month - a.month)).clamp(0, 9999);

  // ──────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uzmanlık Alanları',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'Deneyim süresi iş deneyimlerinden veya tarih aralığından hesaplanır.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.lg),
              ElevatedButton.icon(
                onPressed: () => _showDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Yeni Alan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: AppTheme.background,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xxl),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_areas.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xxl),
                child: Column(
                  children: [
                    Icon(Icons.star_border,
                        size: 48, color: AppTheme.textMuted),
                    const SizedBox(height: Spacing.md),
                    Text(
                      'Henüz uzmanlık alanı yok',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      '"Yeni Alan" butonundan ilk alanı ekleyin.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _areas.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: Spacing.md),
              itemBuilder: (_, i) => _AreaCard(
                area: _areas[i],
                allAreas: _areas,
                workExps: _workExps,
                years: _calculateYears(_areas[i]),
                onEdit: () => _showDialog(_areas[i]),
                onDelete: () => _delete(_areas[i]),
                hexColor: _hexColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext ctx, String text) => Text(
        text,
        style: Theme.of(ctx)
            .textTheme
            .labelMedium
            ?.copyWith(color: AppTheme.textSecondary),
      );

  Widget _dateTile(
    BuildContext ctx, {
    required String label,
    required DateTime date,
    required VoidCallback onPick,
  }) {
    return InkWell(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(ctx)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            Text(
              '${date.year}/${date.month.toString().padLeft(2, '0')}',
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Alan Kartı
// ──────────────────────────────────────────────────────────────────

class _AreaCard extends StatelessWidget {
  final Map<String, dynamic> area;
  final List<Map<String, dynamic>> allAreas;
  final List<Map<String, dynamic>> workExps;
  final int years;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color Function(String) hexColor;

  const _AreaCard({
    required this.area,
    required this.allAreas,
    required this.workExps,
    required this.years,
    required this.onEdit,
    required this.onDelete,
    required this.hexColor,
  });

  Color get _color => hexColor(area['color'] as String? ?? '#58A6FF');

  @override
  Widget build(BuildContext context) {
    final parentIds =
        (area['parent_ids'] as List?)?.cast<String>() ?? [];
    final parentNames = allAreas
        .where((a) => parentIds.contains(a['id']))
        .map((a) => a['name'] as String)
        .join(', ');

    final linkedIds =
        (area['linked_work_exp_ids'] as List?)?.cast<String>() ?? [];
    final linkedNames = workExps
        .where((w) => linkedIds.contains(w['id']))
        .map((w) => '${w['title']} (${w['company']})')
        .join(', ');

    final isOngoing = area['end_date'] == null;
    final dateRange = isOngoing
        ? '${area['start_date']} → devam ediyor'
        : '${area['start_date']} → ${area['end_date']}';

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _color.withOpacity(0.4)),
            ),
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area['name'] as String? ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: Spacing.xs),
                Row(
                  children: [
                    Icon(Icons.date_range, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      dateRange,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.textMuted),
                    ),
                    const SizedBox(width: Spacing.md),
                    Icon(Icons.trending_up, size: 14, color: _color),
                    const SizedBox(width: 4),
                    Text(
                      '$years yıl deneyim',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _color,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                if (linkedNames.isNotEmpty) ...[
                  const SizedBox(height: Spacing.xs),
                  Row(
                    children: [
                      Icon(Icons.work_outline,
                          size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Deneyimler: $linkedNames',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (parentNames.isNotEmpty) ...[
                  const SizedBox(height: Spacing.xs),
                  Row(
                    children: [
                      Icon(Icons.account_tree,
                          size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'Kesişim: $parentNames',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined,
                size: 18, color: AppTheme.textSecondary),
            tooltip: 'Düzenle',
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 18, color: AppTheme.accentRed),
            tooltip: 'Sil',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
