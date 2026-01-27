import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          .from('stats')
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
