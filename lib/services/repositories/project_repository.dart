import 'package:supabase_flutter/supabase_flutter.dart';

/// Projeler tablosu için veri erişim katmanı.
///
/// Yalnızca Supabase çağrılarını sarar; hata yönetimi ve
/// loading state [DataService] tarafından üstlenilir.
class ProjectRepository {
  final SupabaseClient _supabase;

  const ProjectRepository(this._supabase);

  Future<List<Map<String, dynamic>>> getAll({bool? featured}) async {
    var query = _supabase.from('projects').select();
    if (featured != null) query = query.eq('featured', featured);
    final response = await query.order('date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    return await _supabase
        .from('projects')
        .select()
        .eq('id', id)
        .maybeSingle();
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _supabase.from('projects').insert(data);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _supabase.from('projects').update(data).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _supabase.from('projects').delete().eq('id', id);
  }
}
