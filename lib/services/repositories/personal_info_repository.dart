import 'package:supabase_flutter/supabase_flutter.dart';

/// Kişisel bilgiler (personal_info) tablosu için veri erişim katmanı.
///
/// Tablo tek satır tutar; güncelleme mevcut kaydı bulup update,
/// kayıt yoksa insert yapar.
class PersonalInfoRepository {
  final SupabaseClient _supabase;

  const PersonalInfoRepository(this._supabase);

  Future<Map<String, dynamic>?> get() async {
    return await _supabase
        .from('personal_info')
        .select()
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  Future<void> upsert(Map<String, dynamic> data) async {
    final existing = await get();
    if (existing != null) {
      await _supabase
          .from('personal_info')
          .update(data)
          .eq('id', existing['id']);
    } else {
      await _supabase.from('personal_info').insert(data);
    }
  }
}
