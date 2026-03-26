# Ana Sayfa — `HomeScreen`

`HomeScreen` (`lib/screens/home_screen.dart`) üç bölümü dikey olarak sıralar:

```
HomeScreen (Column)
 ├── HeroSection        ← tanıtım + istatistikler
 ├── FeaturedProjects   ← öne çıkan projeler
 └── SkillsSection      ← teknik beceriler
```

---

## Widget Ağacı

### 1. `HeroSection` (`lib/widgets/home/hero_section.dart`)

`initState`'te iki paralel veri çekimi yapar:
- `DataService.getPersonalInfo()` → isim, ünvan, bio, sosyal medya
- `DataService.getAutoStats()` → proje sayısı + uzmanlık alanları/yıllar

```
HeroSection (StatefulWidget)
 ├── [loading] CircularProgressIndicator
 └── [loaded] Responsive layout
      ├── desktop: Row (sol metin + sağ pencere)
      └── mobile: Column
           ├── HeroWindowChrome     ← dekoratif kod editörü çerçevesi
           ├── HeroGreeting         ← "Merhaba, ben [isim]"
           ├── HeroBioText          ← ünvan ve kısa açıklama
           ├── HeroSpecialtiesRow   ← uzmanlık alanları etiketleri
           ├── HeroStatsRow         ← proje sayısı + deneyim yılları
           └── HeroCtaButtons       ← "Projelerimi Gör" / "İletişime Geç"
```

**Veri akışı:**

```
DataService.getPersonalInfo()  ──▶  PersonalInfoRepository.get()  ──▶  Supabase personal_info
DataService.getAutoStats()     ──┬▶  ProjectRepository.getAll()   ──▶  Supabase projects
                                 ├▶  ExpertiseRepository.getAll() ──▶  Supabase expertise_areas
                                 └▶  CvRepository.getWorkExperience() ──▶  Supabase work_experience
                                       └── ExpertiseRepository.calculateYears() (lokal hesaplama)
```

### 2. `FeaturedProjects` (`lib/widgets/home/featured_projects.dart`)

`initState`'te `DataService.getProjects(featured: true)` çağırır.
En fazla 3 proje `ProjectCard` bileşeniyle gösterilir.

```
FeaturedProjects (StatefulWidget)
 ├── SectionTitle ("Öne Çıkan Projeler")
 └── Wrap / Row
      └── ProjectCard × n  (lib/widgets/projects/project_card.dart)
```

### 3. `SkillsSection` (`lib/widgets/home/skills_section.dart`)

`DataService.getSkills()` çağırır; sonuçları `category` alanına göre gruplar
ve her kategori için yeterlilik çubuğu listesi oluşturur.

```
SkillsSection (StatefulWidget)
 ├── SectionTitle ("Teknik Beceriler")
 └── GridView (kategori başlıkları + skill satırları)
```

---

## Veri Bağımlılıkları

| Widget | DataService Metodu | Supabase Tablo(ları) |
|--------|--------------------|---------------------|
| `HeroSection` | `getPersonalInfo()` | `personal_info` |
| `HeroSection` | `getAutoStats()` | `projects`, `expertise_areas`, `work_experience` |
| `FeaturedProjects` | `getProjects(featured: true)` | `projects` |
| `SkillsSection` | `getSkills()` | `skills` |

---

## Responsive Davranış

`Responsive.isDesktop(context)` değerine göre iki düzen uygulanır:

- **Masaüstü**: `HeroSection` içeriği `Row` olarak gösterilir — sol sütun metin, sağ sütun `HeroWindowChrome`.
- **Mobil / tablet**: İçerik `Column` olarak akar; `HeroWindowChrome` üste, metin alta gelir.

Breakpoint'ler `lib/utils/responsive.dart` içinde tanımlıdır.
