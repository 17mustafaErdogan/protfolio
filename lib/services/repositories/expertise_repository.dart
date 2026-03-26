import 'package:supabase_flutter/supabase_flutter.dart';

/// Uzmanlık alanları (expertise_areas) için veri erişim katmanı.
///
/// CRUD işlemlerine ek olarak deneyim yılı hesaplama mantığını barındırır:
/// - Bağlı iş deneyimlerinden toplam ay hesaplama
/// - Örtüşen tarih aralıklarını birleştirme
class ExpertiseRepository {
  final SupabaseClient _supabase;

  const ExpertiseRepository(this._supabase);

  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _supabase
        .from('expertise_areas')
        .select()
        .order('order_index');
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _supabase.from('expertise_areas').insert(data);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _supabase.from('expertise_areas').update(data).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _supabase.from('expertise_areas').delete().eq('id', id);
  }

  // ----------------------------------------------------------
  // Deneyim yılı hesaplama
  // ----------------------------------------------------------

  /// Her uzmanlık alanı için deneyim yılını hesaplar.
  ///
  /// Hesap öncelik sırası:
  /// 1. `linked_work_exp_ids` doluysa: bağlı iş deneyimlerinin
  ///    tarih aralıklarından toplam ay (örtüşmeler tek sayılır)
  /// 2. Uzmanlık alanının kendi `start_date` → `end_date` (null = bugün)
  /// 3. `parent_ids` doluysa: parent alanların en erken `start_date`'i
  int calculateYears(
    Map<String, dynamic> area,
    List<Map<String, dynamic>> allAreas, {
    List<Map<String, dynamic>> workExps = const [],
  }) {
    final now = DateTime.now();

    final linkedWeIds =
        (area['linked_work_exp_ids'] as List?)?.cast<String>() ?? [];
    if (linkedWeIds.isNotEmpty && workExps.isNotEmpty) {
      final linkedExps =
          workExps.where((w) => linkedWeIds.contains(w['id'])).toList();
      final totalMonths = _sumDateRangeMonths(linkedExps, now);
      if (totalMonths > 0) return (totalMonths / 12).round().clamp(1, 99);
    }

    final startDate = DateTime.tryParse(area['start_date'] ?? '');
    if (startDate != null) {
      final endDate = DateTime.tryParse(area['end_date'] ?? '') ?? now;
      final months = _monthsBetween(startDate, endDate);
      if (months > 0) return (months / 12).round().clamp(1, 99);
    }

    final parentIds = (area['parent_ids'] as List?)?.cast<String>() ?? [];
    if (parentIds.isNotEmpty) {
      final parents =
          allAreas.where((a) => parentIds.contains(a['id'])).toList();
      DateTime? earliest;
      for (final p in parents) {
        final d = DateTime.tryParse(p['start_date'] ?? '');
        if (d != null && (earliest == null || d.isBefore(earliest))) {
          earliest = d;
        }
      }
      if (earliest != null) {
        final months = _monthsBetween(earliest, now);
        return (months / 12).round().clamp(1, 99);
      }
    }

    return 0;
  }

  /// İki tarih arasındaki ay sayısını döndürür.
  int _monthsBetween(DateTime start, DateTime end) {
    final months = (end.year - start.year) * 12 + (end.month - start.month);
    return months.clamp(0, 999);
  }

  /// Birden fazla iş deneyimi aralığını birleştirip toplam ay sayısını döndürür.
  /// Örtüşen aralıklar tek sayılır.
  int _sumDateRangeMonths(List<Map<String, dynamic>> exps, DateTime now) {
    final ranges = <(DateTime, DateTime)>[];
    for (final exp in exps) {
      final start = DateTime.tryParse(exp['start_date'] ?? '');
      if (start == null) continue;
      final end = DateTime.tryParse(exp['end_date'] ?? '') ?? now;
      ranges.add((start, end));
    }
    if (ranges.isEmpty) return 0;

    ranges.sort((a, b) => a.$1.compareTo(b.$1));

    int totalMonths = 0;
    DateTime? mergedStart;
    DateTime? mergedEnd;

    for (final r in ranges) {
      if (mergedStart == null) {
        mergedStart = r.$1;
        mergedEnd = r.$2;
      } else if (r.$1.isBefore(mergedEnd!) || r.$1 == mergedEnd) {
        if (r.$2.isAfter(mergedEnd)) mergedEnd = r.$2;
      } else {
        totalMonths += _monthsBetween(mergedStart, mergedEnd);
        mergedStart = r.$1;
        mergedEnd = r.$2;
      }
    }
    if (mergedStart != null && mergedEnd != null) {
      totalMonths += _monthsBetween(mergedStart, mergedEnd);
    }
    return totalMonths;
  }
}
