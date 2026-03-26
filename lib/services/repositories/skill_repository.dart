import 'package:supabase_flutter/supabase_flutter.dart';

/// Beceriler (skills) tablosu için veri erişim katmanı.
class SkillRepository {
  final SupabaseClient _supabase;

  const SkillRepository(this._supabase);

  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _supabase
        .from('skills')
        .select()
        .order('order_index');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _supabase.from('skills').insert(data);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _supabase.from('skills').update(data).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _supabase.from('skills').delete().eq('id', id);
  }
}
