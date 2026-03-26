-- ============================================================
-- PORTFOLYO SUPABASE VERITABANI SEMASI
-- ============================================================
-- Bu SQL scriptini Supabase Dashboard > SQL Editor'da calistirin.
-- Tum tablolari ve RLS (Row Level Security) politikalarini olusturur.
--
-- RLS TEK ADMIN: Asagidaki sabit UUID varsayilan olarak YOKTUR (kimse yazamaz).
-- Calistirmadan once tum dosyada "00000000-0000-4000-8000-000000000001" ifadesini
-- arayip admin hesabinizin UID'si ile degistirin:
--   Supabase Dashboard > Authentication > Users > kullanici > User UID
-- Ayrica public signup kapali tutmaniz onerilir (coklu hesap riski).
-- ============================================================

-- ============================================================
-- 1. PERSONAL_INFO - Kisisel Bilgiler
-- ============================================================
CREATE TABLE IF NOT EXISTS personal_info (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name TEXT NOT NULL,
  title TEXT NOT NULL,
  bio TEXT,
  detailed_bio TEXT,
  email TEXT,
  location TEXT,
  github_url TEXT,
  linkedin_url TEXT,
  twitter_url TEXT,
  website_url TEXT,
  profile_image_url TEXT,
  -- Hakkımda sayfası içerikleri
  story TEXT,
  vision TEXT,
  approach TEXT,
  why_me TEXT,
  military_status TEXT,
  driver_license TEXT,
  availability_status BOOLEAN DEFAULT TRUE,
  availability_text TEXT DEFAULT 'Yeni projelere açığım',
  cv_pdf_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 2. PROJECTS - Projeler
-- ============================================================
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  subtitle TEXT,
  category TEXT,                  -- Eski alan, geriye dönük uyumluluk için
  expertise_area_id UUID,         -- expertise_areas(id) FK — tablo henüz oluşmadı, sonra eklenecek
  tags TEXT[] DEFAULT '{}',
  thumbnail_url TEXT,
  date DATE,
  featured BOOLEAN DEFAULT FALSE,
  problem TEXT,
  approach TEXT,
  implementation TEXT,
  results TEXT,
  lessons_learned TEXT,
  technologies TEXT[] DEFAULT '{}',
  github_url TEXT,
  demo_url TEXT,
  video_url TEXT,
  image_urls TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 3. EXPERTISE_AREAS - Dinamik Uzmanlik Alanlari
-- ============================================================
CREATE TABLE IF NOT EXISTS expertise_areas (
  id                    UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  name                  TEXT    NOT NULL,
  color                 TEXT    NOT NULL DEFAULT '#58A6FF',
  start_date            DATE    NOT NULL,
  end_date              DATE,                        -- NULL = devam ediyor
  linked_work_exp_ids   UUID[]  DEFAULT '{}',        -- İlişkili iş deneyimleri
  parent_ids            UUID[]  DEFAULT '{}',        -- Kesişim alanları için üst alanlar
  order_index           INTEGER DEFAULT 0,
  created_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at            TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 4. SKILLS - Beceriler
-- ============================================================
-- ============================================================
-- 4b. PROJECTS expertise_area migration helper (projects tablosu daha sonra geliyor)
-- ============================================================

CREATE TABLE IF NOT EXISTS skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  expertise_area_id UUID REFERENCES expertise_areas(id) ON DELETE SET NULL,
  proficiency_percent INTEGER DEFAULT 50 CHECK (proficiency_percent >= 0 AND proficiency_percent <= 100),
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 4. EDUCATION - Egitim Bilgileri
-- ============================================================
CREATE TABLE IF NOT EXISTS education (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  degree TEXT NOT NULL,
  field TEXT NOT NULL,
  institution TEXT NOT NULL,
  period TEXT NOT NULL,
  description TEXT,
  gpa TEXT,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 5. CERTIFICATES - Sertifikalar
-- ============================================================
CREATE TABLE IF NOT EXISTS certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  issuer TEXT NOT NULL,
  date DATE NOT NULL,
  credential_url TEXT,
  credential_id TEXT,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 6. WORK_EXPERIENCE - Is Deneyimi
-- ============================================================
CREATE TABLE IF NOT EXISTS work_experience (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  company TEXT NOT NULL,
  period TEXT NOT NULL,
  start_date DATE,                -- Yapısal başlangıç tarihi (hesaplama için)
  end_date DATE,                  -- NULL = devam ediyor
  description TEXT,
  highlights TEXT[] DEFAULT '{}',
  location TEXT,
  employment_type TEXT,
  logo_url TEXT,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 7. LANGUAGES - Yabanci Diller
-- ============================================================
CREATE TABLE IF NOT EXISTS languages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  language TEXT NOT NULL,
  level TEXT NOT NULL,
  proficiency_percent INTEGER CHECK (proficiency_percent >= 0 AND proficiency_percent <= 100),
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 8. ACHIEVEMENTS - Basarilar ve Oduller
-- ============================================================
CREATE TABLE IF NOT EXISTS achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  date DATE,
  organization TEXT,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 9. PUBLICATIONS - Yayinlar
-- ============================================================
CREATE TABLE IF NOT EXISTS publications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  venue TEXT NOT NULL,
  date DATE NOT NULL,
  url TEXT,
  co_authors TEXT[] DEFAULT '{}',
  abstract TEXT,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 10. USER_REFERENCES - Referanslar
-- ============================================================
CREATE TABLE IF NOT EXISTS user_references (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  title TEXT NOT NULL,
  company TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  relationship TEXT,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- 11. CONTACT_MESSAGES - İletişim formu mesajları
-- ============================================================
CREATE TABLE IF NOT EXISTS contact_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  subject TEXT NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS) POLITIKALARI
-- ============================================================

-- Tum tablolar icin RLS'i etkinlestir
-- "ALTER TABLE" komutu, mevcut bir tabloyu değiştirmek (özellik eklemek, değiştirmek vs.) için kullanılır.
-- "ENABLE ROW LEVEL SECURITY" ise, Row Level Security (RLS - satır düzeyinde güvenlik) özelliğini açar.
-- Burada "ALTER TABLE personal_info ENABLE ROW LEVEL SECURITY;" ile "personal_info" tablosunda RLS etkinleşmiş olur.
-- RLS etkin olunca, tabloya erişim varsayılan olarak kapanır: Kullanıcıların tabloya satır eklemesi, okuması, güncellemesi veya silmesi için ayrı ayrı açıkça politika (policy) tanımlaman gerekir.
-- Böylece kullanıcılar, örneğin sadece kendi verisini görebilir, başkasının verisine erişemez.
-- Bu, çok kullanıcıların bulunduğu uygulamalarda hassas veya kişiye özel verilerin güvende tutulmasını sağlar.
-- Eğer politika tanımlanmazsa, RLS aktifken genellikle kimse veriye erişemez.
-- Yani bu komut sadece güvenliğin temelini kurar, asıl detaylı erişim izinleri ise ayrı "policy" komutlarıyla belirlenir.
-- "policy" (politika), tabloya hangi kullanıcıların hangi işlemleri (SELECT, INSERT, UPDATE, DELETE) yapabileceğini belirler.
-- Örnek: Aşağıda sadece okuma (SELECT) işlemlerini herkese açan bir policy nasıl yazılır:
-- CREATE POLICY "Public read access" ON tablo_adi FOR SELECT USING (true);
-- Açıklama: Bu policy ile ilgili tabloda, herkes (giriş yapmadan bile) satırları okuyabilir.
-- Eğer sadece giriş yapmış kullanıcıların veri eklemesini istersen şu şekilde bir policy eklenebilir:
-- CREATE POLICY "Authenticated insert" ON tablo_adi FOR INSERT TO authenticated USING (true);
-- Böylece sadece oturumu açık (auth ile giriş yapmış) kullanıcılar tabloya veri ekleyebilir.
-- Policy'ler ihtiyaca göre farklı yetki kontrolleri ve filtrelerle daha kapsamlı da yazılabilir.
ALTER TABLE personal_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE expertise_areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE education ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE work_experience ENABLE ROW LEVEL SECURITY;
ALTER TABLE languages ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE publications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_references ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PUBLIC READ POLITIKALARI (Herkes okuyabilir)
-- ============================================================

-- Önce mevcut politikaları sil (varsa)
DROP POLICY IF EXISTS "Public read access" ON personal_info;
DROP POLICY IF EXISTS "Public read access" ON projects;
DROP POLICY IF EXISTS "Public read access" ON expertise_areas;
DROP POLICY IF EXISTS "Public read access" ON skills;
DROP POLICY IF EXISTS "Public read access" ON education;
DROP POLICY IF EXISTS "Public read access" ON certificates;
DROP POLICY IF EXISTS "Public read access" ON work_experience;
DROP POLICY IF EXISTS "Public read access" ON languages;
DROP POLICY IF EXISTS "Public read access" ON achievements;
DROP POLICY IF EXISTS "Public read access" ON publications;
DROP POLICY IF EXISTS "Public read access" ON user_references;

-- Yeni politikaları oluştur
-- Bu politikalar, herkes (giriş yapmadan bile) tabloya erişebilir.
CREATE POLICY "Public read access" ON personal_info FOR SELECT USING (true);
CREATE POLICY "Public read access" ON projects FOR SELECT USING (true);
CREATE POLICY "Public read access" ON expertise_areas FOR SELECT USING (true);
CREATE POLICY "Public read access" ON skills FOR SELECT USING (true);
CREATE POLICY "Public read access" ON education FOR SELECT USING (true);
CREATE POLICY "Public read access" ON certificates FOR SELECT USING (true);
CREATE POLICY "Public read access" ON work_experience FOR SELECT USING (true);
CREATE POLICY "Public read access" ON languages FOR SELECT USING (true);
CREATE POLICY "Public read access" ON achievements FOR SELECT USING (true);
CREATE POLICY "Public read access" ON publications FOR SELECT USING (true);
CREATE POLICY "Public read access" ON user_references FOR SELECT USING (true);

-- contact_messages: herkes INSERT (form), yalnızca authenticated SELECT/UPDATE/DELETE
DROP POLICY IF EXISTS "Anyone can send contact message" ON contact_messages;
DROP POLICY IF EXISTS "Authenticated can read contact messages" ON contact_messages;
DROP POLICY IF EXISTS "Authenticated can update contact messages" ON contact_messages;
DROP POLICY IF EXISTS "Authenticated can delete contact messages" ON contact_messages;

CREATE POLICY "Anyone can send contact message" ON contact_messages
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Authenticated can read contact messages" ON contact_messages
  FOR SELECT TO authenticated
  USING (auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid);

CREATE POLICY "Authenticated can update contact messages" ON contact_messages
  FOR UPDATE TO authenticated
  USING (auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid);

CREATE POLICY "Authenticated can delete contact messages" ON contact_messages
  FOR DELETE TO authenticated
  USING (auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid);

-- ============================================================
-- ADMIN WRITE POLITIKALARI (Sadece giris yapmis kullanicilar)
-- ============================================================

-- Önce mevcut admin politikalarını sil (varsa)
DROP POLICY IF EXISTS "Admin insert access" ON personal_info;
DROP POLICY IF EXISTS "Admin update access" ON personal_info;
DROP POLICY IF EXISTS "Admin delete access" ON personal_info;
DROP POLICY IF EXISTS "Admin insert access" ON projects;
DROP POLICY IF EXISTS "Admin update access" ON projects;
DROP POLICY IF EXISTS "Admin delete access" ON projects;
DROP POLICY IF EXISTS "Admin insert access" ON expertise_areas;
DROP POLICY IF EXISTS "Admin update access" ON expertise_areas;
DROP POLICY IF EXISTS "Admin delete access" ON expertise_areas;
DROP POLICY IF EXISTS "Admin insert access" ON skills;
DROP POLICY IF EXISTS "Admin update access" ON skills;
DROP POLICY IF EXISTS "Admin delete access" ON skills;
DROP POLICY IF EXISTS "Admin insert access" ON education;
DROP POLICY IF EXISTS "Admin update access" ON education;
DROP POLICY IF EXISTS "Admin delete access" ON education;
DROP POLICY IF EXISTS "Admin insert access" ON certificates;
DROP POLICY IF EXISTS "Admin update access" ON certificates;
DROP POLICY IF EXISTS "Admin delete access" ON certificates;
DROP POLICY IF EXISTS "Admin insert access" ON work_experience;
DROP POLICY IF EXISTS "Admin update access" ON work_experience;
DROP POLICY IF EXISTS "Admin delete access" ON work_experience;
DROP POLICY IF EXISTS "Admin insert access" ON languages;
DROP POLICY IF EXISTS "Admin update access" ON languages;
DROP POLICY IF EXISTS "Admin delete access" ON languages;
DROP POLICY IF EXISTS "Admin insert access" ON achievements;
DROP POLICY IF EXISTS "Admin update access" ON achievements;
DROP POLICY IF EXISTS "Admin delete access" ON achievements;
DROP POLICY IF EXISTS "Admin insert access" ON publications;
DROP POLICY IF EXISTS "Admin update access" ON publications;
DROP POLICY IF EXISTS "Admin delete access" ON publications;
DROP POLICY IF EXISTS "Admin insert access" ON user_references;
DROP POLICY IF EXISTS "Admin update access" ON user_references;
DROP POLICY IF EXISTS "Admin delete access" ON user_references;

-- Personal Info (tek admin UID — dosya basi yorumuna bakin)
CREATE POLICY "Admin insert access" ON personal_info FOR INSERT WITH CHECK (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin update access" ON personal_info FOR UPDATE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin delete access" ON personal_info FOR DELETE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);

-- Projects
CREATE POLICY "Admin insert access" ON projects FOR INSERT WITH CHECK (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin update access" ON projects FOR UPDATE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin delete access" ON projects FOR DELETE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);

-- Expertise Areas
CREATE POLICY "Admin insert access" ON expertise_areas FOR INSERT WITH CHECK (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin update access" ON expertise_areas FOR UPDATE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin delete access" ON expertise_areas FOR DELETE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);

-- Skills
CREATE POLICY "Admin insert access" ON skills FOR INSERT WITH CHECK (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin update access" ON skills FOR UPDATE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin delete access" ON skills FOR DELETE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);

-- Education
CREATE POLICY "Admin insert access" ON education FOR INSERT WITH CHECK (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin update access" ON education FOR UPDATE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin delete access" ON education FOR DELETE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);

-- Certificates
CREATE POLICY "Admin insert access" ON certificates FOR INSERT WITH CHECK (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin update access" ON certificates FOR UPDATE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin delete access" ON certificates FOR DELETE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);

-- Work Experience
CREATE POLICY "Admin insert access" ON work_experience FOR INSERT WITH CHECK (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin update access" ON work_experience FOR UPDATE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin delete access" ON work_experience FOR DELETE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);

-- Languages
CREATE POLICY "Admin insert access" ON languages FOR INSERT WITH CHECK (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin update access" ON languages FOR UPDATE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin delete access" ON languages FOR DELETE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);

-- Achievements
CREATE POLICY "Admin insert access" ON achievements FOR INSERT WITH CHECK (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin update access" ON achievements FOR UPDATE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin delete access" ON achievements FOR DELETE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);

-- Publications
CREATE POLICY "Admin insert access" ON publications FOR INSERT WITH CHECK (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin update access" ON publications FOR UPDATE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin delete access" ON publications FOR DELETE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);

-- User References
CREATE POLICY "Admin insert access" ON user_references FOR INSERT WITH CHECK (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin update access" ON user_references FOR UPDATE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);
CREATE POLICY "Admin delete access" ON user_references FOR DELETE USING (
  auth.role() = 'authenticated'
  AND auth.uid() = '00000000-0000-4000-8000-000000000001'::uuid
);

-- ============================================================
-- UPDATED_AT TRIGGER FONKSIYONU
-- Bu fonksiyon, tabloya her güncelleme yapıldığında "updated_at" alanını otomatik olarak günceller.
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Önce mevcut trigger'ları sil (varsa)

DROP TRIGGER IF EXISTS update_personal_info_updated_at ON personal_info;
DROP TRIGGER IF EXISTS update_projects_updated_at ON projects;
DROP TRIGGER IF EXISTS update_expertise_areas_updated_at ON expertise_areas;
DROP TRIGGER IF EXISTS update_skills_updated_at ON skills;
DROP TRIGGER IF EXISTS update_education_updated_at ON education;
DROP TRIGGER IF EXISTS update_certificates_updated_at ON certificates;
DROP TRIGGER IF EXISTS update_work_experience_updated_at ON work_experience;
DROP TRIGGER IF EXISTS update_languages_updated_at ON languages;
DROP TRIGGER IF EXISTS update_achievements_updated_at ON achievements;
DROP TRIGGER IF EXISTS update_publications_updated_at ON publications;
DROP TRIGGER IF EXISTS update_user_references_updated_at ON user_references;

-- Tum tablolar icin updated_at trigger'i
CREATE TRIGGER update_personal_info_updated_at BEFORE UPDATE ON personal_info FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_expertise_areas_updated_at BEFORE UPDATE ON expertise_areas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_skills_updated_at BEFORE UPDATE ON skills FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_education_updated_at BEFORE UPDATE ON education FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_certificates_updated_at BEFORE UPDATE ON certificates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_work_experience_updated_at BEFORE UPDATE ON work_experience FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_languages_updated_at BEFORE UPDATE ON languages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_achievements_updated_at BEFORE UPDATE ON achievements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_publications_updated_at BEFORE UPDATE ON publications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_references_updated_at BEFORE UPDATE ON user_references FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- contact_messages: created_at yalnızca insert; gerekirse güncelleme tetikleyicisi eklenebilir

-- ============================================================
-- VARSAYILAN VERI - Personal Info (tek satır mantığı)
-- ============================================================
INSERT INTO personal_info (full_name, title, bio)
SELECT 'Mühendis İsmi', 'Multidisipliner Mühendis',
       'Elektronik, mekanik ve yazılım alanlarında deneyimli mühendis.'
WHERE NOT EXISTS (SELECT 1 FROM personal_info LIMIT 1);

-- ============================================================
-- MEVCUT VERITABANI ICIN GUNCELLEME (Opsiyonel)
-- ============================================================
-- Eger tablolar zaten mevcutsa, yeni alanlari eklemek icin:

ALTER TABLE personal_info ADD COLUMN IF NOT EXISTS story TEXT;
ALTER TABLE personal_info ADD COLUMN IF NOT EXISTS vision TEXT;
ALTER TABLE personal_info ADD COLUMN IF NOT EXISTS approach TEXT;
ALTER TABLE personal_info ADD COLUMN IF NOT EXISTS why_me TEXT;
ALTER TABLE personal_info ADD COLUMN IF NOT EXISTS military_status TEXT;
ALTER TABLE personal_info ADD COLUMN IF NOT EXISTS driver_license TEXT;

-- expertise_areas tablosu yeni oldugu icin mevcut DB'ye ekle:
-- (Yukaridaki CREATE TABLE IF NOT EXISTS zaten hallediyor)

-- skills tablosundaki category CHECK kisitini kaldir, expertise_area_id ekle:
ALTER TABLE skills DROP CONSTRAINT IF EXISTS skills_category_check;
ALTER TABLE skills ADD COLUMN IF NOT EXISTS expertise_area_id UUID REFERENCES expertise_areas(id) ON DELETE SET NULL;

-- expertise_areas: end_date ve linked_work_exp_ids ekle
ALTER TABLE expertise_areas ADD COLUMN IF NOT EXISTS end_date DATE;
ALTER TABLE expertise_areas ADD COLUMN IF NOT EXISTS linked_work_exp_ids UUID[] DEFAULT '{}';

-- work_experience: start_date ve end_date ekle
ALTER TABLE work_experience ADD COLUMN IF NOT EXISTS start_date DATE;
ALTER TABLE work_experience ADD COLUMN IF NOT EXISTS end_date DATE;

-- projects: start_date ve end_date ekle (date alanı geriye dönük korunur)
ALTER TABLE projects ADD COLUMN IF NOT EXISTS start_date DATE;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS end_date DATE;

-- projects: category CHECK kisitini kaldir, expertise_area_id ekle
ALTER TABLE projects DROP CONSTRAINT IF EXISTS projects_category_check;
-- category kolonunun NOT NULL kısıtını kaldır (artık expertise_area_id kullanılıyor)
ALTER TABLE projects ALTER COLUMN category DROP NOT NULL;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS expertise_area_id UUID REFERENCES expertise_areas(id) ON DELETE SET NULL;

-- personal_info — uygulama ile hizalı ek kolonlar ve singleton
ALTER TABLE personal_info ADD COLUMN IF NOT EXISTS availability_status BOOLEAN DEFAULT TRUE;
ALTER TABLE personal_info ADD COLUMN IF NOT EXISTS availability_text TEXT DEFAULT 'Yeni projelere açığım';
ALTER TABLE personal_info ADD COLUMN IF NOT EXISTS cv_pdf_url TEXT;

-- Çoklu satır varsa en güncel satırı tut (unique ifade indeksi öncesi)
DELETE FROM personal_info a USING personal_info b
WHERE a.updated_at < b.updated_at;
DELETE FROM personal_info a
WHERE a.id NOT IN (SELECT id FROM personal_info ORDER BY updated_at DESC NULLS LAST LIMIT 1);

-- Uygulama tek satır personal_info varsayar
CREATE UNIQUE INDEX IF NOT EXISTS personal_info_one_row ON personal_info ((true));

-- ============================================================
-- TAMAMLANDI!
-- ============================================================
-- Bu scripti Supabase SQL Editor'da calistirdiktan sonra
-- tablolar ve guvenlik politikalari hazir olacaktir.
-- ============================================================
