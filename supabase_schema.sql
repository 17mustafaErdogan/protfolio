-- ============================================================
-- PORTFOLYO SUPABASE VERITABANI SEMASI
-- ============================================================
-- Bu SQL scriptini Supabase Dashboard > SQL Editor'da calistirin.
-- Tum tablolari ve RLS (Row Level Security) politikalarini olusturur.
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
  category TEXT NOT NULL CHECK (category IN ('electronics', 'mechanical', 'software')),
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
-- 3. SKILLS - Beceriler
-- ============================================================
CREATE TABLE IF NOT EXISTS skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK (category IN ('electronics', 'mechanical', 'software')),
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
-- 11. STATS - Istatistikler
-- ============================================================
CREATE TABLE IF NOT EXISTS stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_count TEXT DEFAULT '0',
  years_experience TEXT DEFAULT '0',
  expertise_areas TEXT DEFAULT '0',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS) POLITIKALARI
-- ============================================================

-- Tum tablolar icin RLS'i etkinlestir
ALTER TABLE personal_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE education ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE work_experience ENABLE ROW LEVEL SECURITY;
ALTER TABLE languages ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE publications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_references ENABLE ROW LEVEL SECURITY;
ALTER TABLE stats ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PUBLIC READ POLITIKALARI (Herkes okuyabilir)
-- ============================================================

CREATE POLICY "Public read access" ON personal_info FOR SELECT USING (true);
CREATE POLICY "Public read access" ON projects FOR SELECT USING (true);
CREATE POLICY "Public read access" ON skills FOR SELECT USING (true);
CREATE POLICY "Public read access" ON education FOR SELECT USING (true);
CREATE POLICY "Public read access" ON certificates FOR SELECT USING (true);
CREATE POLICY "Public read access" ON work_experience FOR SELECT USING (true);
CREATE POLICY "Public read access" ON languages FOR SELECT USING (true);
CREATE POLICY "Public read access" ON achievements FOR SELECT USING (true);
CREATE POLICY "Public read access" ON publications FOR SELECT USING (true);
CREATE POLICY "Public read access" ON user_references FOR SELECT USING (true);
CREATE POLICY "Public read access" ON stats FOR SELECT USING (true);

-- ============================================================
-- ADMIN WRITE POLITIKALARI (Sadece giris yapmis kullanicilar)
-- ============================================================

-- Personal Info
CREATE POLICY "Admin insert access" ON personal_info FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admin update access" ON personal_info FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admin delete access" ON personal_info FOR DELETE USING (auth.role() = 'authenticated');

-- Projects
CREATE POLICY "Admin insert access" ON projects FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admin update access" ON projects FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admin delete access" ON projects FOR DELETE USING (auth.role() = 'authenticated');

-- Skills
CREATE POLICY "Admin insert access" ON skills FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admin update access" ON skills FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admin delete access" ON skills FOR DELETE USING (auth.role() = 'authenticated');

-- Education
CREATE POLICY "Admin insert access" ON education FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admin update access" ON education FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admin delete access" ON education FOR DELETE USING (auth.role() = 'authenticated');

-- Certificates
CREATE POLICY "Admin insert access" ON certificates FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admin update access" ON certificates FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admin delete access" ON certificates FOR DELETE USING (auth.role() = 'authenticated');

-- Work Experience
CREATE POLICY "Admin insert access" ON work_experience FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admin update access" ON work_experience FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admin delete access" ON work_experience FOR DELETE USING (auth.role() = 'authenticated');

-- Languages
CREATE POLICY "Admin insert access" ON languages FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admin update access" ON languages FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admin delete access" ON languages FOR DELETE USING (auth.role() = 'authenticated');

-- Achievements
CREATE POLICY "Admin insert access" ON achievements FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admin update access" ON achievements FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admin delete access" ON achievements FOR DELETE USING (auth.role() = 'authenticated');

-- Publications
CREATE POLICY "Admin insert access" ON publications FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admin update access" ON publications FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admin delete access" ON publications FOR DELETE USING (auth.role() = 'authenticated');

-- User References
CREATE POLICY "Admin insert access" ON user_references FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admin update access" ON user_references FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admin delete access" ON user_references FOR DELETE USING (auth.role() = 'authenticated');

-- Stats
CREATE POLICY "Admin insert access" ON stats FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Admin update access" ON stats FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Admin delete access" ON stats FOR DELETE USING (auth.role() = 'authenticated');

-- ============================================================
-- UPDATED_AT TRIGGER FONKSIYONU
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Tum tablolar icin updated_at trigger'i
CREATE TRIGGER update_personal_info_updated_at BEFORE UPDATE ON personal_info FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_skills_updated_at BEFORE UPDATE ON skills FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_education_updated_at BEFORE UPDATE ON education FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_certificates_updated_at BEFORE UPDATE ON certificates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_work_experience_updated_at BEFORE UPDATE ON work_experience FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_languages_updated_at BEFORE UPDATE ON languages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_achievements_updated_at BEFORE UPDATE ON achievements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_publications_updated_at BEFORE UPDATE ON publications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_references_updated_at BEFORE UPDATE ON user_references FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_stats_updated_at BEFORE UPDATE ON stats FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- VARSAYILAN VERI - Personal Info (tek satir)
-- ============================================================
INSERT INTO personal_info (full_name, title, bio)
VALUES ('Mühendis İsmi', 'Multidisipliner Mühendis', 'Elektronik, mekanik ve yazılım alanlarında deneyimli mühendis.')
ON CONFLICT DO NOTHING;

-- Stats icin varsayilan satir
INSERT INTO stats (project_count, years_experience, expertise_areas)
VALUES ('0', '0', '3')
ON CONFLICT DO NOTHING;

-- ============================================================
-- TAMAMLANDI!
-- ============================================================
-- Bu scripti Supabase SQL Editor'da calistirdiktan sonra
-- tablolar ve guvenlik politikalari hazir olacaktir.
-- ============================================================
