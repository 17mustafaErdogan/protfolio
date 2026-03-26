import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/cv_models.dart';

/// CV ile ilgili tüm tablolar için veri erişim katmanı.
///
/// Kapsam: education, certificates, work_experience, languages,
/// achievements, publications, user_references.
class CvRepository {
  final SupabaseClient _supabase;

  const CvRepository(this._supabase);

  // ----------------------------------------------------------
  // EĞİTİM (education)
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> getEducation() async {
    final response = await _supabase
        .from('education')
        .select()
        .order('order_index');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Education>> getEducationItems() async {
    final rows = await getEducation();
    return rows.map(Education.fromMap).toList(growable: false);
  }

  Future<void> createEducation(Map<String, dynamic> data) async {
    await _supabase.from('education').insert(data);
  }

  Future<void> updateEducation(String id, Map<String, dynamic> data) async {
    await _supabase.from('education').update(data).eq('id', id);
  }

  Future<void> deleteEducation(String id) async {
    await _supabase.from('education').delete().eq('id', id);
  }

  // ----------------------------------------------------------
  // SERTİFİKALAR (certificates)
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> getCertificates() async {
    final response = await _supabase
        .from('certificates')
        .select()
        .order('date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Certificate>> getCertificateItems() async {
    final rows = await getCertificates();
    return rows.map(Certificate.fromMap).toList(growable: false);
  }

  Future<void> createCertificate(Map<String, dynamic> data) async {
    await _supabase.from('certificates').insert(data);
  }

  Future<void> updateCertificate(String id, Map<String, dynamic> data) async {
    await _supabase.from('certificates').update(data).eq('id', id);
  }

  Future<void> deleteCertificate(String id) async {
    await _supabase.from('certificates').delete().eq('id', id);
  }

  // ----------------------------------------------------------
  // İŞ DENEYİMİ (work_experience)
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> getWorkExperience() async {
    final response = await _supabase
        .from('work_experience')
        .select()
        .order('order_index');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<WorkExperience>> getWorkExperienceItems() async {
    final rows = await getWorkExperience();
    return rows.map(WorkExperience.fromMap).toList(growable: false);
  }

  Future<void> createWorkExperience(Map<String, dynamic> data) async {
    await _supabase.from('work_experience').insert(data);
  }

  Future<void> updateWorkExperience(String id, Map<String, dynamic> data) async {
    await _supabase.from('work_experience').update(data).eq('id', id);
  }

  Future<void> deleteWorkExperience(String id) async {
    await _supabase.from('work_experience').delete().eq('id', id);
  }

  // ----------------------------------------------------------
  // DİLLER (languages)
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> getLanguages() async {
    final response = await _supabase
        .from('languages')
        .select()
        .order('order_index');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<LanguageSkill>> getLanguageItems() async {
    final rows = await getLanguages();
    return rows.map(LanguageSkill.fromMap).toList(growable: false);
  }

  Future<void> createLanguage(Map<String, dynamic> data) async {
    await _supabase.from('languages').insert(data);
  }

  Future<void> updateLanguage(String id, Map<String, dynamic> data) async {
    await _supabase.from('languages').update(data).eq('id', id);
  }

  Future<void> deleteLanguage(String id) async {
    await _supabase.from('languages').delete().eq('id', id);
  }

  // ----------------------------------------------------------
  // BAŞARILAR (achievements)
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> getAchievements() async {
    final response = await _supabase
        .from('achievements')
        .select()
        .order('date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Achievement>> getAchievementItems() async {
    final rows = await getAchievements();
    return rows.map(Achievement.fromMap).toList(growable: false);
  }

  Future<void> createAchievement(Map<String, dynamic> data) async {
    await _supabase.from('achievements').insert(data);
  }

  Future<void> updateAchievement(String id, Map<String, dynamic> data) async {
    await _supabase.from('achievements').update(data).eq('id', id);
  }

  Future<void> deleteAchievement(String id) async {
    await _supabase.from('achievements').delete().eq('id', id);
  }

  // ----------------------------------------------------------
  // YAYINLAR (publications)
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> getPublications() async {
    final response = await _supabase
        .from('publications')
        .select()
        .order('date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Publication>> getPublicationItems() async {
    final rows = await getPublications();
    return rows.map(Publication.fromMap).toList(growable: false);
  }

  Future<void> createPublication(Map<String, dynamic> data) async {
    await _supabase.from('publications').insert(data);
  }

  Future<void> updatePublication(String id, Map<String, dynamic> data) async {
    await _supabase.from('publications').update(data).eq('id', id);
  }

  Future<void> deletePublication(String id) async {
    await _supabase.from('publications').delete().eq('id', id);
  }

  // ----------------------------------------------------------
  // REFERANSLAR (user_references)
  // ----------------------------------------------------------

  Future<List<Map<String, dynamic>>> getReferences() async {
    final response = await _supabase
        .from('user_references')
        .select()
        .order('order_index');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Reference>> getReferenceItems() async {
    final rows = await getReferences();
    return rows.map(Reference.fromMap).toList(growable: false);
  }

  Future<void> createReference(Map<String, dynamic> data) async {
    await _supabase.from('user_references').insert(data);
  }

  Future<void> updateReference(String id, Map<String, dynamic> data) async {
    await _supabase.from('user_references').update(data).eq('id', id);
  }

  Future<void> deleteReference(String id) async {
    await _supabase.from('user_references').delete().eq('id', id);
  }
}
