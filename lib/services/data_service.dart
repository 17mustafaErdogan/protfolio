import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cv_models.dart';
import 'repositories/project_repository.dart';
import 'repositories/skill_repository.dart';
import 'repositories/cv_repository.dart';
import 'repositories/expertise_repository.dart';
import 'repositories/contact_repository.dart';
import 'repositories/personal_info_repository.dart';

/// Uygulama genelinde kullanılan veri servisi (ChangeNotifier facade).
///
/// Sorumlulukları:
/// - [isLoading] ve [errorMessage] state'ini yönetir
/// - Tüm public metotların API'sini (isimleri) sabit tutar
/// - Gerçek Supabase işlemlerini domain repository'lere delege eder
///
/// Repository'ler `lib/services/repositories/` altında bulunur:
/// - [ProjectRepository]      → projeler
/// - [SkillRepository]        → beceriler
/// - [CvRepository]           → eğitim, sertifika, iş deneyimi, dil, başarı, yayın, referans
/// - [ExpertiseRepository]    → uzmanlık alanları + deneyim yılı hesaplama
/// - [ContactRepository]      → iletişim mesajları + dashboard istatistikleri
/// - [PersonalInfoRepository] → kişisel bilgiler
class DataService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  late final ProjectRepository _projects;
  late final SkillRepository _skills;
  late final CvRepository _cv;
  late final ExpertiseRepository _expertise;
  late final ContactRepository _contact;
  late final PersonalInfoRepository _personalInfo;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DataService() {
    _projects = ProjectRepository(_supabase);
    _skills = SkillRepository(_supabase);
    _cv = CvRepository(_supabase);
    _expertise = ExpertiseRepository(_supabase);
    _contact = ContactRepository(_supabase);
    _personalInfo = PersonalInfoRepository(_supabase);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  static const String _readErrorUserMessage =
      'Veriler yüklenemedi. Lütfen bağlantınızı kontrol edip tekrar deneyin.';

  /// Okuma hatalarını kullanıcıya ve debug log'una bildirir.
  void _notifyReadFailure(String operation, Object e) {
    _errorMessage =
        kDebugMode ? '$operation: $e' : _readErrorUserMessage;
    notifyListeners();
    debugPrint('DataService read failure ($operation): $e');
  }

  /// Yazma (mutasyon) işlemlerini saran yardımcı.
  ///
  /// Loading state'i yönetir ve hata durumunda [errorMessage]'ı doldurur.
  Future<bool> _runMutation(
    Future<void> Function() fn,
    String errorPrefix,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await fn();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '$errorPrefix: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================
  // PERSONAL INFO
  // ============================================================

  Future<Map<String, dynamic>?> getPersonalInfo() async {
    try {
      return await _personalInfo.get();
    } catch (e) {
      _notifyReadFailure('getPersonalInfo', e);
      return null;
    }
  }

  Future<bool> updatePersonalInfo(Map<String, dynamic> data) =>
      _runMutation(() => _personalInfo.upsert(data), 'Kişisel bilgiler güncellenemedi');

  // ============================================================
  // PROJECTS
  // ============================================================

  Future<List<Map<String, dynamic>>> getProjects({bool? featured}) async {
    try {
      return await _projects.getAll(featured: featured);
    } catch (e) {
      _notifyReadFailure('getProjects', e);
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProject(String id) async {
    try {
      return await _projects.getById(id);
    } catch (e) {
      _notifyReadFailure('getProject', e);
      return null;
    }
  }

  Future<bool> createProject(Map<String, dynamic> data) =>
      _runMutation(() => _projects.create(data), 'Proje oluşturulamadı');

  Future<bool> updateProject(String id, Map<String, dynamic> data) =>
      _runMutation(() => _projects.update(id, data), 'Proje güncellenemedi');

  Future<bool> deleteProject(String id) =>
      _runMutation(() => _projects.delete(id), 'Proje silinemedi');

  // ============================================================
  // SKILLS
  // ============================================================

  Future<List<Map<String, dynamic>>> getSkills() async {
    try {
      return await _skills.getAll();
    } catch (e) {
      _notifyReadFailure('getSkills', e);
      return [];
    }
  }

  Future<bool> createSkill(Map<String, dynamic> data) =>
      _runMutation(() => _skills.create(data), 'Beceri oluşturulamadı');

  Future<bool> updateSkill(String id, Map<String, dynamic> data) =>
      _runMutation(() => _skills.update(id, data), 'Beceri güncellenemedi');

  Future<bool> deleteSkill(String id) =>
      _runMutation(() => _skills.delete(id), 'Beceri silinemedi');

  // ============================================================
  // EDUCATION
  // ============================================================

  Future<List<Map<String, dynamic>>> getEducation() async {
    try {
      return await _cv.getEducation();
    } catch (e) {
      _notifyReadFailure('getEducation', e);
      return [];
    }
  }

  Future<List<Education>> getEducationItems() async {
    try {
      return await _cv.getEducationItems();
    } catch (e) {
      _notifyReadFailure('getEducationItems', e);
      return [];
    }
  }

  Future<bool> createEducation(Map<String, dynamic> data) =>
      _runMutation(() => _cv.createEducation(data), 'Eğitim oluşturulamadı');

  Future<bool> updateEducation(String id, Map<String, dynamic> data) =>
      _runMutation(() => _cv.updateEducation(id, data), 'Eğitim güncellenemedi');

  Future<bool> deleteEducation(String id) =>
      _runMutation(() => _cv.deleteEducation(id), 'Eğitim silinemedi');

  // ============================================================
  // CERTIFICATES
  // ============================================================

  Future<List<Map<String, dynamic>>> getCertificates() async {
    try {
      return await _cv.getCertificates();
    } catch (e) {
      _notifyReadFailure('getCertificates', e);
      return [];
    }
  }

  Future<List<Certificate>> getCertificateItems() async {
    try {
      return await _cv.getCertificateItems();
    } catch (e) {
      _notifyReadFailure('getCertificateItems', e);
      return [];
    }
  }

  Future<bool> createCertificate(Map<String, dynamic> data) =>
      _runMutation(() => _cv.createCertificate(data), 'Sertifika oluşturulamadı');

  Future<bool> updateCertificate(String id, Map<String, dynamic> data) =>
      _runMutation(() => _cv.updateCertificate(id, data), 'Sertifika güncellenemedi');

  Future<bool> deleteCertificate(String id) =>
      _runMutation(() => _cv.deleteCertificate(id), 'Sertifika silinemedi');

  // ============================================================
  // WORK EXPERIENCE
  // ============================================================

  Future<List<Map<String, dynamic>>> getWorkExperience() async {
    try {
      return await _cv.getWorkExperience();
    } catch (e) {
      _notifyReadFailure('getWorkExperience', e);
      return [];
    }
  }

  Future<List<WorkExperience>> getWorkExperienceItems() async {
    try {
      return await _cv.getWorkExperienceItems();
    } catch (e) {
      _notifyReadFailure('getWorkExperienceItems', e);
      return [];
    }
  }

  Future<bool> createWorkExperience(Map<String, dynamic> data) =>
      _runMutation(() => _cv.createWorkExperience(data), 'İş deneyimi oluşturulamadı');

  Future<bool> updateWorkExperience(String id, Map<String, dynamic> data) =>
      _runMutation(() => _cv.updateWorkExperience(id, data), 'İş deneyimi güncellenemedi');

  Future<bool> deleteWorkExperience(String id) =>
      _runMutation(() => _cv.deleteWorkExperience(id), 'İş deneyimi silinemedi');

  // ============================================================
  // LANGUAGES
  // ============================================================

  Future<List<Map<String, dynamic>>> getLanguages() async {
    try {
      return await _cv.getLanguages();
    } catch (e) {
      _notifyReadFailure('getLanguages', e);
      return [];
    }
  }

  Future<List<LanguageSkill>> getLanguageItems() async {
    try {
      return await _cv.getLanguageItems();
    } catch (e) {
      _notifyReadFailure('getLanguageItems', e);
      return [];
    }
  }

  Future<bool> createLanguage(Map<String, dynamic> data) =>
      _runMutation(() => _cv.createLanguage(data), 'Dil oluşturulamadı');

  Future<bool> updateLanguage(String id, Map<String, dynamic> data) =>
      _runMutation(() => _cv.updateLanguage(id, data), 'Dil güncellenemedi');

  Future<bool> deleteLanguage(String id) =>
      _runMutation(() => _cv.deleteLanguage(id), 'Dil silinemedi');

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      return await _cv.getAchievements();
    } catch (e) {
      _notifyReadFailure('getAchievements', e);
      return [];
    }
  }

  Future<List<Achievement>> getAchievementItems() async {
    try {
      return await _cv.getAchievementItems();
    } catch (e) {
      _notifyReadFailure('getAchievementItems', e);
      return [];
    }
  }

  Future<bool> createAchievement(Map<String, dynamic> data) =>
      _runMutation(() => _cv.createAchievement(data), 'Başarı oluşturulamadı');

  Future<bool> updateAchievement(String id, Map<String, dynamic> data) =>
      _runMutation(() => _cv.updateAchievement(id, data), 'Başarı güncellenemedi');

  Future<bool> deleteAchievement(String id) =>
      _runMutation(() => _cv.deleteAchievement(id), 'Başarı silinemedi');

  // ============================================================
  // REFERENCES
  // ============================================================

  Future<List<Map<String, dynamic>>> getReferences() async {
    try {
      return await _cv.getReferences();
    } catch (e) {
      _notifyReadFailure('getReferences', e);
      return [];
    }
  }

  Future<List<Reference>> getReferenceItems() async {
    try {
      return await _cv.getReferenceItems();
    } catch (e) {
      _notifyReadFailure('getReferenceItems', e);
      return [];
    }
  }

  Future<bool> createReference(Map<String, dynamic> data) =>
      _runMutation(() => _cv.createReference(data), 'Referans oluşturulamadı');

  Future<bool> updateReference(String id, Map<String, dynamic> data) =>
      _runMutation(() => _cv.updateReference(id, data), 'Referans güncellenemedi');

  Future<bool> deleteReference(String id) =>
      _runMutation(() => _cv.deleteReference(id), 'Referans silinemedi');

  // ============================================================
  // PUBLICATIONS
  // ============================================================

  Future<List<Map<String, dynamic>>> getPublications() async {
    try {
      return await _cv.getPublications();
    } catch (e) {
      _notifyReadFailure('getPublications', e);
      return [];
    }
  }

  Future<List<Publication>> getPublicationItems() async {
    try {
      return await _cv.getPublicationItems();
    } catch (e) {
      _notifyReadFailure('getPublicationItems', e);
      return [];
    }
  }

  Future<bool> createPublication(Map<String, dynamic> data) =>
      _runMutation(() => _cv.createPublication(data), 'Yayın oluşturulamadı');

  Future<bool> updatePublication(String id, Map<String, dynamic> data) =>
      _runMutation(() => _cv.updatePublication(id, data), 'Yayın güncellenemedi');

  Future<bool> deletePublication(String id) =>
      _runMutation(() => _cv.deletePublication(id), 'Yayın silinemedi');

  // ============================================================
  // EXPERTISE AREAS
  // ============================================================

  Future<List<Map<String, dynamic>>> getExpertiseAreas() async {
    try {
      return await _expertise.getAll();
    } catch (e) {
      _notifyReadFailure('getExpertiseAreas', e);
      return [];
    }
  }

  Future<bool> createExpertiseArea(Map<String, dynamic> data) =>
      _runMutation(() => _expertise.create(data), 'Uzmanlık alanı eklenemedi');

  Future<bool> updateExpertiseArea(String id, Map<String, dynamic> data) =>
      _runMutation(() => _expertise.update(id, data), 'Uzmanlık alanı güncellenemedi');

  Future<bool> deleteExpertiseArea(String id) =>
      _runMutation(() => _expertise.delete(id), 'Uzmanlık alanı silinemedi');

  /// Hero bölümü için otomatik hesaplanan istatistikler döndürür.
  ///
  /// Dönüş: `{ 'project_count': int, 'expertise_areas': [{name, color, years}] }`
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
          'years': _expertise.calculateYears(area, areas, workExps: workExps),
          'order_index': area['order_index'] ?? 0,
        };
      }).toList();

      return {
        'project_count': projects.length,
        'expertise_areas': expertiseWithYears,
      };
    } catch (e) {
      _notifyReadFailure('getAutoStats', e);
      return {
        'project_count': 0,
        'expertise_areas': <Map<String, dynamic>>[],
      };
    }
  }

  // ============================================================
  // CONTACT MESSAGES
  // ============================================================

  Future<bool> sendContactMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      await _contact.sendMessage(
        name: name,
        email: email,
        subject: subject,
        message: message,
      );
      return true;
    } catch (e) {
      _errorMessage = kDebugMode
          ? 'Mesaj gönderilemedi: $e'
          : 'Mesaj gönderilemedi. Lütfen tekrar deneyin.';
      notifyListeners();
      debugPrint('Error sending contact message: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getContactMessages() async {
    try {
      return await _contact.getAll();
    } catch (e) {
      _notifyReadFailure('getContactMessages', e);
      return [];
    }
  }

  Future<bool> markMessageAsRead(String id) async {
    try {
      await _contact.markAsRead(id);
      return true;
    } catch (e) {
      _errorMessage = 'Mesaj güncellenemedi: $e';
      notifyListeners();
      debugPrint('Error marking message as read: $e');
      return false;
    }
  }

  Future<bool> deleteContactMessage(String id) async {
    try {
      await _contact.delete(id);
      return true;
    } catch (e) {
      _errorMessage = 'Mesaj silinemedi: $e';
      notifyListeners();
      debugPrint('Error deleting contact message: $e');
      return false;
    }
  }

  // ============================================================
  // DASHBOARD STATS
  // ============================================================

  Future<Map<String, int>> getDashboardStats() => _contact.getDashboardStats();
}
