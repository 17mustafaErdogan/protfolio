# Ekranlar (Screens)

Tüm ekranlar `lib/screens/` altındadır. Public ekranlar `ShellScaffold` (NavBar + Footer) ile,
admin ekranlar `AdminShell` (sol kenar çubuğu + içerik) ile sarılır.

---

## Public Ekranlar

| Dosya | Sınıf | Rota | Açıklama |
|-------|-------|------|----------|
| `home_screen.dart` | `HomeScreen` | `/` | Hero bölümü, öne çıkan projeler, teknik beceriler |
| `projects_screen.dart` | `ProjectsScreen` | `/projects` | Tüm projeler, kategori filtresi |
| `project_detail_screen.dart` | `ProjectDetailScreen` | `/projects/:id` | Tek proje detayı (problem → yaklaşım → sonuç) |
| `about_screen.dart` | `AboutScreen` | `/about` | Hakkımda içeriği |
| `profile_screen.dart` | `ProfileScreen` | `/profile` | CV özeti: eğitim, deneyim, sertifika vb. |
| `contact_screen.dart` | `ContactScreen` | `/contact` | İletişim formu + müsaitlik durumu |
| `login_screen.dart` | `LoginScreen` | `/login` | Admin giriş formu |

### Routing Notu

- Tüm public ekranlar `ShellRoute` içindedir; `ShellScaffold` otomatik eklenir.
- `LoginScreen` bağımsız `GoRoute`'ta bulunur — NavBar/Footer yoktur.
- Oturum açık kullanıcı `/login`'e gitmeye çalışırsa `/admin`'e yönlendirilir.

---

## Admin Ekranları (`lib/screens/admin/`)

Tüm admin rotaları `_adminRedirect` ile korunur; oturum yoksa `/login`'e yönlendirir.

| Dosya | Sınıf | Rota | Açıklama |
|-------|-------|------|----------|
| `admin_shell.dart` | `AdminShell` | — | Sol kenar çubuğu + içerik alanı (layout sarmalayıcı) |
| `dashboard_screen.dart` | `DashboardScreen` | `/admin` | Proje, beceri, eğitim, deneyim sayaçları; hızlı erişim butonları |
| `projects_admin.dart` | `ProjectsAdminScreen` | `/admin/projects` | Proje listesi, silme; yeni proje / düzenleme linkleri |
| `project_edit_screen.dart` | `ProjectEditScreen` | `/admin/projects/new` ve `/admin/projects/:id/edit` | Proje oluşturma ve düzenleme formu |
| `skills_admin.dart` | `SkillsAdminScreen` | `/admin/skills` | Beceri CRUD, yeterlilik yüzdesi ayarı |
| `expertise_areas_admin.dart` | `ExpertiseAreasAdminScreen` | `/admin/expertise-areas` | Uzmanlık alanları CRUD |
| `cv_admin.dart` | `CVAdminScreen` | `/admin/cv` | CV yönetimi — 7 sekmeli tab yapısı |
| `contact_messages_admin.dart` | `ContactMessagesAdminScreen` | `/admin/messages` | Mesaj listesi, okundu işaretleme, silme |
| `settings_admin.dart` | `SettingsAdminScreen` | `/admin/settings` | Kişisel bilgiler, müsaitlik, CV PDF linki |

### `CVAdminScreen` Sekmeleri

| Sekme | İçerik |
|-------|--------|
| Eğitim | `education` tablosu |
| Sertifikalar | `certificates` tablosu |
| İş Deneyimi | `work_experience` tablosu |
| Diller | `languages` tablosu |
| Başarılar | `achievements` tablosu |
| Yayınlar | `publications` tablosu |
| Referanslar | `user_references` tablosu |

---

## Rota Sabitleri (`lib/config/routes.dart` → `AppRoutes`)

```dart
AppRoutes.home              // '/'
AppRoutes.projects          // '/projects'
AppRoutes.projectDetail     // '/projects/:id'
AppRoutes.about             // '/about'
AppRoutes.profile           // '/profile'
AppRoutes.contact           // '/contact'
AppRoutes.login             // '/login'
AppRoutes.admin             // '/admin'
AppRoutes.adminProjects     // '/admin/projects'
AppRoutes.adminProjectNew   // '/admin/projects/new'
AppRoutes.adminProjectEdit  // '/admin/projects/:id/edit'
AppRoutes.adminSkills       // '/admin/skills'
AppRoutes.adminExpertiseAreas  // '/admin/expertise-areas'
AppRoutes.adminCV           // '/admin/cv'
AppRoutes.adminSettings     // '/admin/settings'
AppRoutes.adminMessages     // '/admin/messages'
```

Dinamik yollar için yardımcı metotlar:

```dart
AppRoutes.projectDetailPath(id)      // '/projects/$id'
AppRoutes.adminProjectEditPath(id)   // '/admin/projects/$id/edit'
```
