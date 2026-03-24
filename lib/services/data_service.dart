import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cv_models.dart';

/// Supabase veritabani islemleri servisi.
/// 
/// Tum CRUD islemlerini yonetir:
/// - Projeler
/// - Beceriler
/// - Egitim, Sertifika, Is Deneyimi
/// - Diller, Basarilar, Yayinlar
/// - Kisisel Bilgiler
class DataService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // PERSONAL INFO
  // ============================================================

  Future<Map<String, dynamic>?> getPersonalInfo() async {
    try {
      final response = await _supabase
          .from('personal_info')
          .select()
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error getting personal info: $e');
      return null;
    }
  }

  Future<bool> updatePersonalInfo(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final existing = await getPersonalInfo();
      if (existing != null) {
        await _supabase
            .from('personal_info')
            .update(data)
            .eq('id', existing['id']);
      } else {
        await _supabase.from('personal_info').insert(data);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Kişisel bilgiler güncellenemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // PROJECTS
  // ============================================================

  Future<List<Map<String, dynamic>>> getProjects({bool? featured}) async {
    try {
      var query = _supabase.from('projects').select();
      if (featured != null) {
        query = query.eq('featured', featured);
      }
      final response = await query.order('date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting projects: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProject(String id) async {
    try {
      final response = await _supabase
          .from('projects')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error getting project: $e');
      return null;
    }
  }

  Future<bool> createProject(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _supabase.from('projects').insert(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Proje oluşturulamadı: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProject(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _supabase.from('projects').update(data).eq('id', id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Proje güncellenemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProject(String id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _supabase.from('projects').delete().eq('id', id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Proje silinemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // SKILLS
  // ============================================================

  Future<List<Map<String, dynamic>>> getSkills() async {
    try {
      final response = await _supabase
          .from('skills')
          .select()
          .order('order_index');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting skills: $e');
      return [];
    }
  }

  Future<bool> createSkill(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _supabase.from('skills').insert(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Beceri oluşturulamadı: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSkill(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _supabase.from('skills').update(data).eq('id', id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Beceri güncellenemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSkill(String id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _supabase.from('skills').delete().eq('id', id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Beceri silinemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // EDUCATION
  // ============================================================

  Future<List<Map<String, dynamic>>> getEducation() async {
    try {
      final response = await _supabase
          .from('education')
          .select()
          .order('order_index');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting education: $e');
      return [];
    }
  }

  Future<List<Education>> getEducationItems() async {
    final rows = await getEducation();
    return rows.map(Education.fromMap).toList(growable: false);
  }

  Future<bool> createEducation(Map<String, dynamic> data) async {
    try {
      await _supabase.from('education').insert(data);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Eğitim oluşturulamadı: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEducation(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('education').update(data).eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Eğitim güncellenemedi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEducation(String id) async {
    try {
      await _supabase.from('education').delete().eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Eğitim silinemedi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // CERTIFICATES
  // ============================================================

  Future<List<Map<String, dynamic>>> getCertificates() async {
    try {
      final response = await _supabase
          .from('certificates')
          .select()
          .order('date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting certificates: $e');
      return [];
    }
  }

  Future<List<Certificate>> getCertificateItems() async {
    final rows = await getCertificates();
    return rows.map(Certificate.fromMap).toList(growable: false);
  }

  Future<bool> createCertificate(Map<String, dynamic> data) async {
    try {
      await _supabase.from('certificates').insert(data);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Sertifika oluşturulamadı: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCertificate(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('certificates').update(data).eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Sertifika güncellenemedi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCertificate(String id) async {
    try {
      await _supabase.from('certificates').delete().eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Sertifika silinemedi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // WORK EXPERIENCE
  // ============================================================

  Future<List<Map<String, dynamic>>> getWorkExperience() async {
    try {
      final response = await _supabase
          .from('work_experience')
          .select()
          .order('order_index');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting work experience: $e');
      return [];
    }
  }

  Future<List<WorkExperience>> getWorkExperienceItems() async {
    final rows = await getWorkExperience();
    return rows.map(WorkExperience.fromMap).toList(growable: false);
  }

  Future<bool> createWorkExperience(Map<String, dynamic> data) async {
    try {
      await _supabase.from('work_experience').insert(data);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'İş deneyimi oluşturulamadı: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateWorkExperience(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('work_experience').update(data).eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'İş deneyimi güncellenemedi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWorkExperience(String id) async {
    try {
      await _supabase.from('work_experience').delete().eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'İş deneyimi silinemedi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // LANGUAGES
  // ============================================================

  Future<List<Map<String, dynamic>>> getLanguages() async {
    try {
      final response = await _supabase
          .from('languages')
          .select()
          .order('order_index');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting languages: $e');
      return [];
    }
  }

  Future<List<LanguageSkill>> getLanguageItems() async {
    final rows = await getLanguages();
    return rows.map(LanguageSkill.fromMap).toList(growable: false);
  }

  Future<bool> createLanguage(Map<String, dynamic> data) async {
    try {
      await _supabase.from('languages').insert(data);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Dil oluşturulamadı: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLanguage(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('languages').update(data).eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Dil güncellenemedi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLanguage(String id) async {
    try {
      await _supabase.from('languages').delete().eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Dil silinemedi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      final response = await _supabase
          .from('achievements')
          .select()
          .order('date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting achievements: $e');
      return [];
    }
  }

  Future<List<Achievement>> getAchievementItems() async {
    final rows = await getAchievements();
    return rows.map(Achievement.fromMap).toList(growable: false);
  }

  Future<bool> createAchievement(Map<String, dynamic> data) async {
    try {
      await _supabase.from('achievements').insert(data);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Başarı oluşturulamadı: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAchievement(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('achievements').update(data).eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Başarı güncellenemedi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAchievement(String id) async {
    try {
      await _supabase.from('achievements').delete().eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Başarı silinemedi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // REFERENCES (user_references)
  // ============================================================

  Future<List<Map<String, dynamic>>> getReferences() async {
    try {
      final response = await _supabase
          .from('user_references')
          .select()
          .order('order_index');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting references: $e');
      return [];
    }
  }

  Future<List<Reference>> getReferenceItems() async {
    final rows = await getReferences();
    return rows.map(Reference.fromMap).toList(growable: false);
  }

  Future<bool> createReference(Map<String, dynamic> data) async {
    try {
      await _supabase.from('user_references').insert(data);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Referans oluşturulamadı: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateReference(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('user_references').update(data).eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Referans güncellenemedi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReference(String id) async {
    try {
      await _supabase.from('user_references').delete().eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Referans silinemedi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // PUBLICATIONS
  // ============================================================

  Future<List<Map<String, dynamic>>> getPublications() async {
    try {
      final response = await _supabase
          .from('publications')
          .select()
          .order('date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting publications: $e');
      return [];
    }
  }

  Future<List<Publication>> getPublicationItems() async {
    final rows = await getPublications();
    return rows.map(Publication.fromMap).toList(growable: false);
  }

  Future<bool> createPublication(Map<String, dynamic> data) async {
    try {
      await _supabase.from('publications').insert(data);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Yayın oluşturulamadı: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePublication(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('publications').update(data).eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Yayın güncellenemedi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePublication(String id) async {
    try {
      await _supabase.from('publications').delete().eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Yayın silinemedi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // STATS
  // ============================================================

  Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await _supabase
          .from('stats') // stats tablosu görevi: proje sayısı, deneyim yılı, uzmanlık alanları
          .select()
          .limit(1)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error getting stats: $e');
      return null;
    }
  }

  Future<bool> updateStats(Map<String, dynamic> data) async {
    try {
      final existing = await getStats();
      if (existing != null) {
        await _supabase.from('stats').update(data).eq('id', existing['id']);
      } else {
        await _supabase.from('stats').insert(data);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'İstatistikler güncellenemedi: $e';
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // EXPERTISE AREAS
  // ============================================================

  Future<List<Map<String, dynamic>>> getExpertiseAreas() async {
    try {
      final response = await _supabase
          .from('expertise_areas')
          .select()
          .order('order_index');
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Error getting expertise areas: $e');
      return [];
    }
  }

  Future<bool> createExpertiseArea(Map<String, dynamic> data) async {
    try {
      await _supabase.from('expertise_areas').insert(data);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Uzmanlık alanı eklenemedi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExpertiseArea(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('expertise_areas').update(data).eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Uzmanlık alanı güncellenemedi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpertiseArea(String id) async {
    try {
      await _supabase.from('expertise_areas').delete().eq('id', id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Uzmanlık alanı silinemedi: $e';
      notifyListeners();
      return false;
    }
  }

  /// Her uzmanlık alanı için deneyim yılını hesaplar.
  ///
  /// Hesap öncelik sırası:
  /// 1. `linked_work_exp_ids` doluysa: bağlı iş deneyimlerinin (start→end) aralıklarından toplam ay hesaplanır
  /// 2. Aksi halde: expertise_area'nın kendi start_date → end_date (null = bugün) aralığı kullanılır
  /// 3. `parent_ids` doluysa: parent alanların en erken start_date'i baz alınır
  int _calculateYears(
    Map<String, dynamic> area,
    List<Map<String, dynamic>> allAreas, {
    List<Map<String, dynamic>> workExps = const [],
  }) {
    final now = DateTime.now();

    // 1. İş deneyimlerinden toplam ay hesapla
    final linkedWeIds =
        (area['linked_work_exp_ids'] as List?)?.cast<String>() ?? [];
    if (linkedWeIds.isNotEmpty && workExps.isNotEmpty) {
      final linkedExps =
          workExps.where((w) => linkedWeIds.contains(w['id'])).toList();
      final totalMonths = _sumDateRangeMonths(linkedExps, now);
      if (totalMonths > 0) return (totalMonths / 12).round().clamp(1, 99);
    }

    // 2. Expertise area kendi tarih aralığı
    final startDate = DateTime.tryParse(area['start_date'] ?? '');
    if (startDate != null) {
      final endDate = DateTime.tryParse(area['end_date'] ?? '') ?? now;
      final months = _monthsBetween(startDate, endDate);
      if (months > 0) return (months / 12).round().clamp(1, 99);
    }

    // 3. Parent alanları varsa en erken tarihi kullan
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

  /// Ay sayısı hesaplayıcı
  int _monthsBetween(DateTime start, DateTime end) {
    final months = (end.year - start.year) * 12 + (end.month - start.month);
    return months.clamp(0, 999);
  }

  /// Birden fazla iş deneyimi aralığını birleştirip toplam ay sayısını döndürür.
  /// Örtüşen aralıklar tek sayılır.
  int _sumDateRangeMonths(
      List<Map<String, dynamic>> exps, DateTime now) {
    final ranges = <(DateTime, DateTime)>[];
    for (final exp in exps) {
      final start = DateTime.tryParse(exp['start_date'] ?? '');
      if (start == null) continue;
      final end = DateTime.tryParse(exp['end_date'] ?? '') ?? now;
      ranges.add((start, end));
    }
    if (ranges.isEmpty) return 0;

    // Başlangıca göre sırala
    ranges.sort((a, b) => a.$1.compareTo(b.$1));

    int totalMonths = 0;
    DateTime? mergedStart;
    DateTime? mergedEnd;

    for (final r in ranges) {
      if (mergedStart == null) {
        mergedStart = r.$1;
        mergedEnd = r.$2;
      } else if (r.$1.isBefore(mergedEnd!) || r.$1 == mergedEnd) {
        // Örtüşme: mevcut aralığı genişlet
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

  /// Hero bölümü için otomatik hesaplanan istatistikler döndürür.
  ///
  /// Dönüş: { 'project_count': int, 'expertise_areas': [{name, color, years}] }
  Future<Map<String, dynamic>> getAutoStats() async {
    try {
      final results = await Future.wait([
        getProjects(),
        getExpertiseAreas(),
        getWorkExperience(),
      ]);

      final projects = results[0] as List<dynamic>;
      final areas = (results[1] as List).cast<Map<String, dynamic>>();
      final workExps = (results[2] as List).cast<Map<String, dynamic>>();

      final expertiseWithYears = areas.map((area) {
        return {
          'id': area['id'],
          'name': area['name'],
          'color': area['color'] ?? '#58A6FF',
          'years': _calculateYears(area, areas, workExps: workExps),
          'order_index': area['order_index'] ?? 0,
        };
      }).toList();

      return {
        'project_count': projects.length,
        'expertise_areas': expertiseWithYears,
      };
    } catch (e) {
      debugPrint('Error getting auto stats: $e');
      return {
        'project_count': 0,
        'expertise_areas': <Map<String, dynamic>>[],
      };
    }
  }

  // ============================================================
  // DASHBOARD STATS
  // ============================================================

  Future<Map<String, int>> getDashboardStats() async {
    try {
      final projects = await _supabase.from('projects').select('id');
      final skills = await _supabase.from('skills').select('id');
      final education = await _supabase.from('education').select('id');
      final certificates = await _supabase.from('certificates').select('id');
      final workExperience = await _supabase.from('work_experience').select('id');
      
      return {
        'projects': (projects as List).length,
        'skills': (skills as List).length,
        'education': (education as List).length,
        'certificates': (certificates as List).length,
        'workExperience': (workExperience as List).length,
      };
    } catch (e) {
      debugPrint('Error getting dashboard stats: $e');
      return {
        'projects': 0,
        'skills': 0,
        'education': 0,
        'certificates': 0,
        'workExperience': 0,
      };
    }
  }
}
