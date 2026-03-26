import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// İletişim mesajları (contact_messages) için veri erişim katmanı.
class ContactRepository {
  final SupabaseClient _supabase;

  const ContactRepository(this._supabase);

  Future<void> sendMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    await _supabase.from('contact_messages').insert({
      'name': name.trim(),
      'email': email.trim(),
      'subject': subject.trim(),
      'message': message.trim(),
      'is_read': false,
    });
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _supabase
        .from('contact_messages')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<void> markAsRead(String id) async {
    await _supabase
        .from('contact_messages')
        .update({'is_read': true})
        .eq('id', id);
  }

  Future<void> delete(String id) async {
    await _supabase.from('contact_messages').delete().eq('id', id);
  }

  /// Dashboard için tablo satır sayılarını ve okunmamış mesaj sayısını döndürür.
  ///
  /// Her tablo bağımsız try/catch ile sayılır: bir tablo hata verse bile
  /// diğer sayaçlar doğru görünmeye devam eder.
  Future<Map<String, int>> getDashboardStats() async {
    Future<int> countTable(String table) async {
      try {
        final res = await _supabase
            .from(table)
            .select('id')
            .count(CountOption.exact);
        return res.count;
      } catch (e) {
        debugPrint('Error counting $table: $e');
        return 0;
      }
    }

    Future<int> countUnread() async {
      try {
        final res = await _supabase
            .from('contact_messages')
            .select('id')
            .eq('is_read', false)
            .count(CountOption.exact);
        return res.count;
      } catch (e) {
        debugPrint('Error counting unread contact_messages: $e');
        return 0;
      }
    }

    final results = await Future.wait([
      countTable('projects'),
      countTable('skills'),
      countTable('education'),
      countTable('certificates'),
      countTable('work_experience'),
      countUnread(),
    ]);

    return {
      'projects': results[0],
      'skills': results[1],
      'education': results[2],
      'certificates': results[3],
      'workExperience': results[4],
      'unreadMessages': results[5],
    };
  }
}
