# Servis Katmanı

Uygulama iki `ChangeNotifier` servis ve altı stateless repository içerir.
Widget'lar yalnızca servislere erişir; repository'lere doğrudan bağımlılık yoktur.

---

## `AuthService` — `lib/services/auth_service.dart`

Supabase kimlik doğrulama işlemlerini yönetir.

| Alan / Metot | Açıklama |
|---|---|
| `isLoggedIn` | Oturum açık mı? |
| `errorMessage` | Son giriş hata mesajı |
| `signIn(email, password)` | Supabase e-posta/şifre girişi |
| `signOut()` | Oturumu kapatır |
| `clearError()` | Hata mesajını temizler |

`AuthService`, `GoRouter`'a `refreshListenable` olarak verilir; giriş/çıkış
anında router otomatik yeniden değerlendirme yapar ve `_adminRedirect` tetiklenir.

---

## `DataService` — `lib/services/data_service.dart`

Uygulama genelinde tek `ChangeNotifier` veri servisidir.
Tüm public metot isimleri sabit kalır; iç implementasyon repository'lere delege edilir.

### Durum (State)

| Alan | Tür | Açıklama |
|------|-----|----------|
| `isLoading` | `bool` | Yazma işlemi devam ediyor mu? |
| `errorMessage` | `String?` | Son hata mesajı (read/write) |

### Yardımcı Metotlar

| Metot | Açıklama |
|-------|----------|
| `clearError()` | `errorMessage`'ı sıfırlar, dinleyicilere bildirir |
| `_runMutation(fn, errorPrefix)` | Yazma işlemi sarmalayıcı — loading flag'ini yönetir, hata yakalar |
| `_notifyReadFailure(op, e)` | Okuma hatasını loglar; prod'da genel mesaj, debug'da ayrıntılı |

### Metot → Tablo Eşlemesi

| Metot Grubu | Supabase Tablosu | Repository |
|---|---|---|
| `getPersonalInfo`, `updatePersonalInfo` | `personal_info` | `PersonalInfoRepository` |
| `getProjects`, `getProject`, `createProject`, `updateProject`, `deleteProject` | `projects` | `ProjectRepository` |
| `getSkills`, `createSkill`, `updateSkill`, `deleteSkill` | `skills` | `SkillRepository` |
| `getEducation`, `getEducationItems`, `createEducation`, `updateEducation`, `deleteEducation` | `education` | `CvRepository` |
| `getCertificates`, `getCertificateItems`, `createCertificate`, `updateCertificate`, `deleteCertificate` | `certificates` | `CvRepository` |
| `getWorkExperience`, `getWorkExperienceItems`, `createWorkExperience`, `updateWorkExperience`, `deleteWorkExperience` | `work_experience` | `CvRepository` |
| `getLanguages`, `getLanguageItems`, `createLanguage`, `updateLanguage`, `deleteLanguage` | `languages` | `CvRepository` |
| `getAchievements`, `getAchievementItems`, `createAchievement`, `updateAchievement`, `deleteAchievement` | `achievements` | `CvRepository` |
| `getPublications`, `getPublicationItems`, `createPublication`, `updatePublication`, `deletePublication` | `publications` | `CvRepository` |
| `getReferences`, `getReferenceItems`, `createReference`, `updateReference`, `deleteReference` | `user_references` | `CvRepository` |
| `getExpertiseAreas`, `createExpertiseArea`, `updateExpertiseArea`, `deleteExpertiseArea` | `expertise_areas` | `ExpertiseRepository` |
| `getAutoStats()` | `projects` + `expertise_areas` + `work_experience` | `ExpertiseRepository` (yıl hesabı) |
| `sendContactMessage`, `getContactMessages`, `markMessageAsRead`, `deleteContactMessage` | `contact_messages` | `ContactRepository` |
| `getDashboardStats()` | tüm sayım + okunmamış mesaj | `ContactRepository` |

---

## Repository'ler — `lib/services/repositories/`

Her repository `const` constructor alır; `DataService` tarafından bir kez somutlaştırılır.
Hata yönetimi yoktur — exception fırlatırlar, `DataService` yakalar.

### `ProjectRepository`

```
getAll({bool? featured})  →  featured filtresi, date desc sırası
getById(id)
create(data)
update(id, data)
delete(id)
```

### `SkillRepository`

```
getAll()  →  order_index sırası
create(data)
update(id, data)
delete(id)
```

### `CvRepository`

7 CV bölümünü tek sınıfta toplar. Her bölüm için şu metotlar bulunur:

| Bölüm | Raw (Map) | Typed (Model) | Tablo |
|-------|-----------|---------------|-------|
| Eğitim | `getEducation()` | `getEducationItems() → List<Education>` | `education` |
| Sertifika | `getCertificates()` | `getCertificateItems() → List<Certificate>` | `certificates` |
| İş Deneyimi | `getWorkExperience()` | `getWorkExperienceItems() → List<WorkExperience>` | `work_experience` |
| Dil | `getLanguages()` | `getLanguageItems() → List<LanguageSkill>` | `languages` |
| Başarı | `getAchievements()` | `getAchievementItems() → List<Achievement>` | `achievements` |
| Yayın | `getPublications()` | `getPublicationItems() → List<Publication>` | `publications` |
| Referans | `getReferences()` | `getReferenceItems() → List<Reference>` | `user_references` |

Modeller `lib/models/cv_models.dart` içinde tanımlıdır.

### `ExpertiseRepository`

```
getAll()                                      →  order_index sırası
create(data) / update(id, data) / delete(id)
calculateYears(area, allAreas, workExps)      →  deneyim yılı (int)
```

`calculateYears` öncelik sırası:
1. `linked_work_exp_ids` → bağlı iş deneyimlerinin toplam ay toplamı (örtüşmeler birleştirilir)
2. Kendi `start_date` → `end_date` (null = bugün)
3. `parent_ids` → en erken parent `start_date`'ten bugüne

### `ContactRepository`

```
sendMessage({name, email, subject, message})
getAll()          →  created_at desc sırası
markAsRead(id)
delete(id)
getDashboardStats()  →  {projects, skills, education, certificates, workExperience, unreadMessages}
```

`getDashboardStats()` her tabloyu bağımsız `try/catch` ile sayar;
bir tablo hatası diğer sayaçları sıfırlamaz.

### `PersonalInfoRepository`

```
get()         →  en son güncellenen tek satır
upsert(data)  →  kayıt varsa update, yoksa insert
```
