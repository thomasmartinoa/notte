-- KTU Notte Database Schema
-- Run this in Supabase SQL Editor

-- =============================================================================
-- BRANCHES TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS branches (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    short_name TEXT NOT NULL,
    icon TEXT DEFAULT 'engineering',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert all KTU branches
INSERT INTO branches (id, name, short_name, icon) VALUES
    ('cse', 'Computer Science and Engineering', 'CSE', 'computer'),
    ('ece', 'Electronics and Communication Engineering', 'ECE', 'memory'),
    ('eee', 'Electrical and Electronics Engineering', 'EEE', 'bolt'),
    ('me', 'Mechanical Engineering', 'ME', 'precision_manufacturing'),
    ('ce', 'Civil Engineering', 'CE', 'construction'),
    ('che', 'Chemical Engineering', 'CHE', 'science'),
    ('it', 'Information Technology', 'IT', 'language'),
    ('ae', 'Automobile Engineering', 'AE', 'directions_car'),
    ('aero', 'Aeronautical Engineering', 'AERO', 'flight'),
    ('bio', 'Biotechnology', 'BIO', 'biotech'),
    ('arch', 'Architecture', 'ARCH', 'architecture'),
    ('food', 'Food Technology', 'FOOD', 'restaurant'),
    ('pe', 'Production Engineering', 'PE', 'factory'),
    ('iem', 'Industrial Engineering and Management', 'IEM', 'business'),
    ('ai', 'Artificial Intelligence and Data Science', 'AI', 'psychology'),
    ('mca', 'Master of Computer Applications', 'MCA', 'computer'),
    ('mba', 'Master of Business Administration', 'MBA', 'business_center'),
    ('cys', 'Cyber Security', 'CYS', 'security'),
    ('agri', 'Agricultural Engineering', 'AGRI', 'agriculture'),
    ('textile', 'Textile Engineering', 'TEXT', 'checkroom'),
    ('polymer', 'Polymer Engineering', 'POLY', 'science'),
    ('marine', 'Marine Engineering', 'MARINE', 'sailing'),
    ('naval', 'Naval Architecture', 'NAVAL', 'anchor'),
    ('safety', 'Safety and Fire Engineering', 'SAFE', 'fire_extinguisher')
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- SUBJECTS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS subjects (
    id TEXT PRIMARY KEY,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    branch_id TEXT REFERENCES branches(id),
    semester INTEGER NOT NULL CHECK (semester >= 1 AND semester <= 8),
    credits INTEGER DEFAULT 3,
    modules INTEGER DEFAULT 5,
    is_common BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_subjects_branch_semester ON subjects(branch_id, semester);

-- =============================================================================
-- NOTES TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS notes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    subject_id TEXT REFERENCES subjects(id),
    module_number INTEGER NOT NULL CHECK (module_number >= 1 AND module_number <= 6),
    file_url TEXT NOT NULL,
    file_size_bytes BIGINT,
    file_type TEXT DEFAULT 'pdf',
    page_count INTEGER,
    source_url TEXT,
    source_name TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    is_published BOOLEAN DEFAULT FALSE,
    download_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notes_subject_module ON notes(subject_id, module_number);
CREATE INDEX IF NOT EXISTS idx_notes_published ON notes(is_published) WHERE is_published = TRUE;

-- =============================================================================
-- QUESTION PAPERS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS question_papers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    subject_id TEXT REFERENCES subjects(id),
    year INTEGER NOT NULL,
    exam_type TEXT DEFAULT 'regular' CHECK (exam_type IN ('regular', 'supplementary', 'internal', 'series')),
    month TEXT,
    file_url TEXT NOT NULL,
    file_size_bytes BIGINT,
    source_url TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    is_published BOOLEAN DEFAULT FALSE,
    download_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_papers_subject ON question_papers(subject_id);
CREATE INDEX IF NOT EXISTS idx_papers_year ON question_papers(year);
CREATE INDEX IF NOT EXISTS idx_papers_published ON question_papers(is_published) WHERE is_published = TRUE;

-- =============================================================================
-- SYLLABUS TABLE
-- =============================================================================
CREATE TABLE IF NOT EXISTS syllabus (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    subject_id TEXT REFERENCES subjects(id),
    module_number INTEGER NOT NULL,
    module_title TEXT NOT NULL,
    topics TEXT[] DEFAULT '{}',
    hours INTEGER DEFAULT 9,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_syllabus_subject ON syllabus(subject_id);

-- =============================================================================
-- SCRAPING LOGS TABLE (for tracking scraping jobs)
-- =============================================================================
CREATE TABLE IF NOT EXISTS scraping_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    source TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'running', 'completed', 'failed')),
    items_found INTEGER DEFAULT 0,
    items_added INTEGER DEFAULT 0,
    error_message TEXT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- =============================================================================
-- CONTENT REVIEW QUEUE (for manual review before publishing)
-- =============================================================================
CREATE TABLE IF NOT EXISTS review_queue (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    content_type TEXT NOT NULL CHECK (content_type IN ('note', 'paper')),
    content_id UUID NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    reviewer_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_review_queue_pending ON review_queue(status) WHERE status = 'pending';

-- =============================================================================
-- STORAGE BUCKET POLICIES
-- =============================================================================

-- Create storage bucket for PDFs
INSERT INTO storage.buckets (id, name, public)
VALUES ('pdfs', 'pdfs', true)
ON CONFLICT (id) DO NOTHING;

-- Allow public read access to PDFs
DROP POLICY IF EXISTS "Public PDF Access" ON storage.objects;
CREATE POLICY "Public PDF Access" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'pdfs');

-- =============================================================================
-- ROW LEVEL SECURITY POLICIES
-- =============================================================================

-- Enable RLS on all tables
ALTER TABLE branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_papers ENABLE ROW LEVEL SECURITY;
ALTER TABLE syllabus ENABLE ROW LEVEL SECURITY;

-- Public read access for published content
DROP POLICY IF EXISTS "Public read access for branches" ON branches;
DROP POLICY IF EXISTS "Public read access for subjects" ON subjects;
DROP POLICY IF EXISTS "Public read access for published notes" ON notes;
DROP POLICY IF EXISTS "Public read access for published papers" ON question_papers;
DROP POLICY IF EXISTS "Public read access for syllabus" ON syllabus;

CREATE POLICY "Public read access for branches" ON branches FOR SELECT USING (true);
CREATE POLICY "Public read access for subjects" ON subjects FOR SELECT USING (true);
CREATE POLICY "Public read access for published notes" ON notes FOR SELECT USING (is_published = true);
CREATE POLICY "Public read access for published papers" ON question_papers FOR SELECT USING (is_published = true);
CREATE POLICY "Public read access for syllabus" ON syllabus FOR SELECT USING (true);

-- =============================================================================
-- FUNCTIONS
-- =============================================================================

-- Function to increment download count
CREATE OR REPLACE FUNCTION increment_download_count(
    table_name TEXT,
    record_id UUID
)
RETURNS VOID AS $$
BEGIN
    IF table_name = 'notes' THEN
        UPDATE notes SET download_count = download_count + 1 WHERE id = record_id;
    ELSIF table_name = 'question_papers' THEN
        UPDATE question_papers SET download_count = download_count + 1 WHERE id = record_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to approve content from review queue
CREATE OR REPLACE FUNCTION approve_content(
    queue_id UUID
)
RETURNS VOID AS $$
DECLARE
    content_type_val TEXT;
    content_id_val UUID;
BEGIN
    SELECT content_type, content_id INTO content_type_val, content_id_val
    FROM review_queue WHERE id = queue_id;
    
    IF content_type_val = 'note' THEN
        UPDATE notes SET is_published = TRUE, is_verified = TRUE WHERE id = content_id_val;
    ELSIF content_type_val = 'paper' THEN
        UPDATE question_papers SET is_published = TRUE, is_verified = TRUE WHERE id = content_id_val;
    END IF;
    
    UPDATE review_queue SET status = 'approved', reviewed_at = NOW() WHERE id = queue_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- TRIGGERS
-- =============================================================================

-- Update timestamps trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers first
DROP TRIGGER IF EXISTS update_branches_updated_at ON branches;
DROP TRIGGER IF EXISTS update_subjects_updated_at ON subjects;
DROP TRIGGER IF EXISTS update_notes_updated_at ON notes;
DROP TRIGGER IF EXISTS update_papers_updated_at ON question_papers;
DROP TRIGGER IF EXISTS notes_review_queue ON notes;
DROP TRIGGER IF EXISTS papers_review_queue ON question_papers;

CREATE TRIGGER update_branches_updated_at BEFORE UPDATE ON branches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_subjects_updated_at BEFORE UPDATE ON subjects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_notes_updated_at BEFORE UPDATE ON notes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_papers_updated_at BEFORE UPDATE ON question_papers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-add to review queue when new content is added
CREATE OR REPLACE FUNCTION add_to_review_queue()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO review_queue (content_type, content_id)
    VALUES (TG_ARGV[0], NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notes_review_queue AFTER INSERT ON notes
    FOR EACH ROW EXECUTE FUNCTION add_to_review_queue('note');

CREATE TRIGGER papers_review_queue AFTER INSERT ON question_papers
    FOR EACH ROW EXECUTE FUNCTION add_to_review_queue('paper');
