"""
KTU Notes Scraper
Scrapes study materials from various KTU resources
Run daily via GitHub Actions
"""

import os
import re
import json
import time
import hashlib
import logging
from datetime import datetime
from pathlib import Path
from typing import Optional
from dataclasses import dataclass
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup
from supabase import create_client, Client

# Load .env from project root (parent of scripts folder)
_env_loaded = False
try:
    from dotenv import load_dotenv
    env_path = Path(__file__).parent.parent / '.env'
    if env_path.exists():
        load_dotenv(env_path)
        _env_loaded = True
except ImportError:
    pass  # python-dotenv not installed, rely on environment variables

# Configuration
SUPABASE_URL = os.environ.get("SUPABASE_URL", "")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_KEY", "")
USER_AGENT = "KTU-Notte-Scraper/1.0 (Educational Purpose)"

# Logging setup
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

if _env_loaded:
    logger.info(f"Loaded .env from project root")
if SUPABASE_URL:
    logger.info(f"Supabase URL configured: {SUPABASE_URL[:30]}...")

# Rate limiting
REQUEST_DELAY = 2  # seconds between requests


@dataclass
class ScrapedNote:
    """Represents a scraped note document"""
    title: str
    description: Optional[str]
    subject_code: str
    module_number: int
    file_url: str
    file_size_bytes: Optional[int]
    source_url: str
    source_name: str


@dataclass
class ScrapedPaper:
    """Represents a scraped question paper"""
    subject_code: str
    year: int
    exam_type: str
    month: Optional[str]
    file_url: str
    file_size_bytes: Optional[int]
    source_url: str


class KTUScraper:
    """Base scraper class with common functionality"""
    
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': USER_AGENT,
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        })
        
        if SUPABASE_URL and SUPABASE_KEY:
            self.supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        else:
            self.supabase = None
            logger.warning("Supabase credentials not found. Running in dry-run mode.")
        
        # Cache for subjects we've already ensured exist
        self._subjects_cache = set()
    
    def fetch_page(self, url: str) -> Optional[BeautifulSoup]:
        """Fetch and parse a webpage with rate limiting"""
        try:
            time.sleep(REQUEST_DELAY)
            response = self.session.get(url, timeout=30)
            response.raise_for_status()
            return BeautifulSoup(response.content, 'html.parser')
        except requests.RequestException as e:
            logger.error(f"Failed to fetch {url}: {e}")
            return None
    
    def get_file_size(self, url: str) -> Optional[int]:
        """Get file size from HEAD request"""
        try:
            response = self.session.head(url, timeout=10, allow_redirects=True)
            return int(response.headers.get('content-length', 0))
        except:
            return None
    
    def convert_google_drive_url(self, url: str) -> Optional[str]:
        """Convert Google Drive viewer URL to direct download URL"""
        # Extract file ID from various Google Drive URL formats
        # Format 1: https://drive.google.com/file/d/FILE_ID/view?...
        # Format 2: https://drive.google.com/open?id=FILE_ID
        # Format 3: https://drive.google.com/uc?id=FILE_ID
        
        file_id = None
        
        if '/file/d/' in url:
            # Extract ID from /file/d/ID/
            match = re.search(r'/file/d/([a-zA-Z0-9_-]+)', url)
            if match:
                file_id = match.group(1)
        elif 'id=' in url:
            # Extract from query param
            match = re.search(r'id=([a-zA-Z0-9_-]+)', url)
            if match:
                file_id = match.group(1)
        
        if file_id:
            # Return direct download URL
            return f"https://drive.google.com/uc?export=download&id={file_id}"
        
        return None
    
    def generate_file_hash(self, url: str) -> str:
        """Generate a hash for deduplication"""
        return hashlib.md5(url.encode()).hexdigest()[:16]
    
    def ensure_subject_exists(self, subject_code: str, subject_name: str = None) -> bool:
        """Ensure a subject exists in the database, create if not"""
        if not self.supabase:
            return True  # Dry-run mode
        
        subject_id = subject_code.lower()
        
        # Check cache first
        if subject_id in self._subjects_cache:
            return True
        
        try:
            # Check if subject exists
            existing = self.supabase.table('subjects').select('id').eq('id', subject_id).execute()
            
            if existing.data:
                self._subjects_cache.add(subject_id)
                return True
            
            # Create the subject with minimal required fields
            name = subject_name or self._format_subject_name(subject_code)
            self.supabase.table('subjects').insert({
                'id': subject_id,
                'code': subject_code.upper(),
                'name': name,
                'semester': self._guess_semester(subject_code),
                'credits': 3,  # Default
            }).execute()
            
            self._subjects_cache.add(subject_id)
            logger.info(f"Created subject: {subject_code}")
            return True
        except Exception as e:
            logger.error(f"Failed to ensure subject {subject_code}: {e}")
            return False
    
    def _format_subject_name(self, code: str) -> str:
        """Format subject code into a readable name"""
        # Extract department prefix (CST, MAT, EST, etc.)
        prefix = ''.join(c for c in code if c.isalpha())
        return f"{prefix.upper()} Subject {code.upper()}"
    
    def _guess_semester(self, code: str) -> int:
        """Guess semester from subject code"""
        # KTU codes often have semester in the number part
        # CST201 = Sem 2, CST301 = Sem 3, etc.
        nums = ''.join(c for c in code if c.isdigit())
        if len(nums) >= 1:
            first_digit = int(nums[0])
            if 1 <= first_digit <= 8:
                return first_digit
        return 1  # Default
    
    def upload_to_storage(self, file_url: str, filename: str) -> Optional[str]:
        """Download file and upload to Supabase storage"""
        if not self.supabase:
            return file_url  # In dry-run mode, return original URL
        
        try:
            # Convert Google Drive URLs to direct download URLs
            download_url = file_url
            if 'drive.google.com' in file_url:
                converted = self.convert_google_drive_url(file_url)
                if converted:
                    download_url = converted
                    logger.debug(f"Converted Google Drive URL: {file_url} -> {download_url}")
                else:
                    logger.warning(f"Could not convert Google Drive URL: {file_url}")
                    return None
            
            # Check if file already exists
            path = f"notes/{filename}"
            try:
                existing = self.supabase.storage.from_('pdfs').list('notes')
                if any(f['name'] == filename for f in existing):
                    logger.debug(f"File already exists in storage: {filename}")
                    return self.supabase.storage.from_('pdfs').get_public_url(path)
            except:
                pass  # Continue to upload if check fails
            
            # Download file
            response = self.session.get(download_url, timeout=60, allow_redirects=True)
            response.raise_for_status()
            
            # Check if it's actually a PDF
            content_type = response.headers.get('content-type', '')
            content_bytes = response.content[:10]  # Check PDF magic bytes
            is_pdf = (
                'pdf' in content_type.lower() or 
                file_url.endswith('.pdf') or
                content_bytes.startswith(b'%PDF')  # PDF magic bytes
            )
            
            if not is_pdf:
                # For Google Drive, sometimes we get HTML with virus scan warning for large files
                if 'drive.google.com' in file_url and b'Google Drive - Virus scan warning' in response.content[:5000]:
                    logger.warning(f"Google Drive virus scan page for large file: {file_url}")
                    # Try to extract confirm link and retry
                    # This happens for files > 100MB
                    return None
                    
                logger.warning(f"Skipping non-PDF file: {file_url} (content-type: {content_type})")
                return None
            
            # Upload to Supabase storage
            self.supabase.storage.from_('pdfs').upload(
                path,
                response.content,
                {'content-type': 'application/pdf'}
            )
            
            # Get public URL
            return self.supabase.storage.from_('pdfs').get_public_url(path)
        except Exception as e:
            error_str = str(e)
            if 'Duplicate' in error_str or '409' in error_str:
                # File already exists, return URL
                path = f"notes/{filename}"
                return self.supabase.storage.from_('pdfs').get_public_url(path)
            logger.error(f"Failed to upload {file_url}: {e}")
            return None  # Return None to indicate failure
    
    def save_note(self, note: ScrapedNote, subject_id: str) -> bool:
        """Save a scraped note to database"""
        if not self.supabase:
            logger.info(f"[DRY-RUN] Would save note: {note.title}")
            return True
        
        try:
            # Ensure subject exists first
            if not self.ensure_subject_exists(note.subject_code):
                logger.error(f"Could not ensure subject exists: {note.subject_code}")
                return False
            
            # Check for duplicates by file URL hash
            file_hash = self.generate_file_hash(note.file_url)
            existing = self.supabase.table('notes').select('id').eq(
                'source_url', note.source_url
            ).execute()
            
            if existing.data:
                logger.debug(f"Note already exists: {note.title}")
                return False
            
            # Upload file to storage
            filename = f"{subject_id}_{note.module_number}_{file_hash}.pdf"
            stored_url = self.upload_to_storage(note.file_url, filename)
            
            if not stored_url:
                logger.warning(f"Failed to upload note file: {note.file_url}")
                return False
            
            # Insert into database
            self.supabase.table('notes').insert({
                'title': note.title,
                'description': note.description,
                'subject_id': subject_id,
                'module_number': note.module_number,
                'file_url': stored_url,
                'file_size_bytes': note.file_size_bytes,
                'source_url': note.source_url,
                'source_name': note.source_name,
                'is_verified': False,
                'is_published': False,  # Needs manual review
            }).execute()
            
            logger.info(f"Saved note: {note.title}")
            return True
        except Exception as e:
            logger.error(f"Failed to save note {note.title}: {e}")
            return False
    
    def save_paper(self, paper: ScrapedPaper, subject_id: str) -> bool:
        """Save a scraped question paper to database"""
        if not self.supabase:
            logger.info(f"[DRY-RUN] Would save paper: {paper.subject_code} {paper.year}")
            return True
        
        try:
            # Ensure subject exists first
            if not self.ensure_subject_exists(paper.subject_code):
                logger.error(f"Could not ensure subject exists: {paper.subject_code}")
                return False
            
            # Check for duplicates by file URL to avoid repeated uploads
            file_hash = self.generate_file_hash(paper.file_url)
            existing = self.supabase.table('question_papers').select('id').eq(
                'source_url', paper.source_url
            ).execute()
            
            if existing.data:
                logger.debug(f"Paper already exists: {paper.subject_code} {paper.year}")
                return False
            
            # Upload file to storage with unique filename
            filename = f"paper_{subject_id}_{paper.year}_{paper.exam_type}_{file_hash}.pdf"
            stored_url = self.upload_to_storage(paper.file_url, filename)
            
            if not stored_url:
                logger.warning(f"Failed to upload paper file: {paper.file_url}")
                return False
            
            # Insert into database
            self.supabase.table('question_papers').insert({
                'subject_id': subject_id,
                'year': paper.year,
                'exam_type': paper.exam_type,
                'month': paper.month,
                'file_url': stored_url,
                'file_size_bytes': paper.file_size_bytes,
                'source_url': paper.source_url,
                'is_verified': False,
                'is_published': False,  # Needs manual review
            }).execute()
            
            logger.info(f"Saved paper: {paper.subject_code} {paper.year}")
            return True
        except Exception as e:
            logger.error(f"Failed to save paper: {e}")
            return False
    
    def log_scraping_run(self, source: str, items_found: int, items_added: int, 
                         status: str = 'completed', error: Optional[str] = None):
        """Log a scraping run to database"""
        if not self.supabase:
            logger.info(f"[DRY-RUN] Scraping log - Source: {source}, Found: {items_found}, Added: {items_added}")
            return
        
        try:
            self.supabase.table('scraping_logs').insert({
                'source': source,
                'status': status,
                'items_found': items_found,
                'items_added': items_added,
                'error_message': error,
                'completed_at': datetime.now().isoformat() if status != 'running' else None
            }).execute()
        except Exception as e:
            logger.error(f"Failed to log scraping run: {e}")


class KTUStudyMaterialsScraper(KTUScraper):
    """Scraper for KTU study materials websites
    
    HOW TO CONFIGURE:
    1. Add source URLs to BASE_URLS list below
    2. Implement site-specific scraping logic in scrape_site()
    3. Test locally: python scraper.py
    4. Set GitHub Secrets for automated runs
    
    LEGAL NOTE:
    Only add URLs for sites that:
    - Allow automated access (check robots.txt)
    - Have freely distributable educational content
    - You have permission to use
    """
    
    # =========================================================================
    # CONFIGURE YOUR SOURCE URLs HERE
    # =========================================================================
    BASE_URLS = [
        # Example format - uncomment and modify as needed:
        "https://ktunotes.in/notes/",
        "https://www.ktustudents.in/",
        "https://www.keralanotes.com/p/ktu-study-materials.html?m=1",
        "https://ktuspecial.in/",
        "https://ktu2024.web.app/",
        
        # Add your verified KTU resource URLs here
        # Make sure you have permission to scrape these sites
    ]
    
    # =========================================================================
    # Subject code patterns for different regulations
    # =========================================================================
    SUBJECT_PATTERNS = [
        r'([A-Z]{2,3}\d{3})',      # Standard: CST201, MAT101
        r'([A-Z]{2,4}\d{4})',      # Extended: CSST2001
        r'(\d{2}[A-Z]{2,3}\d{3})', # Year prefix: 21CST201
    ]
    
    def extract_subject_code(self, text: str) -> Optional[str]:
        """Extract subject code from text (e.g., CST201, MAT101)
        
        Supports multiple KTU subject code formats:
        - CST201 (standard)
        - MAT101 (common subjects)
        - EST110 (engineering sciences)
        - HUT200 (humanities)
        """
        for pattern in self.SUBJECT_PATTERNS:
            match = re.search(pattern, text.upper())
            if match:
                return match.group(1)
        return None
    
    def extract_module_number(self, text: str) -> int:
        """Extract module number from text"""
        match = re.search(r'module\s*[-:]?\s*(\d+)', text, re.IGNORECASE)
        return int(match.group(1)) if match else 1
    
    def extract_year(self, text: str) -> Optional[int]:
        """Extract year from text (2019-2025)"""
        match = re.search(r'(20[1-2]\d)', text)
        return int(match.group(1)) if match else None
    
    def scrape_all(self):
        """Main scraping entry point"""
        total_found = 0
        total_added = 0
        
        for base_url in self.BASE_URLS:
            logger.info(f"Scraping: {base_url}")
            
            try:
                # Use site-specific scraping based on domain
                domain = urlparse(base_url).netloc
                
                if 'ktunotes.in' in domain:
                    found, added = self.scrape_ktunotes(base_url)
                else:
                    # Generic scraping for other sites
                    found, added = self.scrape_site(base_url)
                    
                total_found += found
                total_added += added
            except Exception as e:
                logger.error(f"Error scraping {base_url}: {e}")
                self.log_scraping_run(base_url, 0, 0, 'failed', str(e))
        
        self.log_scraping_run('all_sources', total_found, total_added)
        logger.info(f"Scraping complete. Found: {total_found}, Added: {total_added}")
    
    def scrape_ktunotes(self, base_url: str) -> tuple[int, int]:
        """Scrape ktunotes.in using their sitemap"""
        found = 0
        added = 0
        
        # Fetch sitemap to get all content URLs
        sitemap_url = "https://www.ktunotes.in/post-sitemap.xml"
        logger.info(f"Fetching sitemap: {sitemap_url}")
        
        try:
            response = self.session.get(sitemap_url, timeout=30)
            response.raise_for_status()
            sitemap_soup = BeautifulSoup(response.content, 'xml')
        except Exception as e:
            logger.error(f"Failed to fetch sitemap: {e}")
            return self.scrape_site(base_url)  # Fallback to generic scraping
        
        # Find all URLs in sitemap
        urls = sitemap_soup.find_all('loc')
        logger.info(f"Found {len(urls)} URLs in sitemap")
        
        # Filter for notes and question papers URLs
        notes_urls = []
        papers_urls = []
        
        for url_tag in urls:
            url = url_tag.text
            if '-notes' in url and 'notes/' not in url:
                notes_urls.append(url)
            elif 'question-paper' in url:
                papers_urls.append(url)
        
        logger.info(f"Found {len(notes_urls)} notes pages, {len(papers_urls)} question paper pages")
        
        # Limit for testing (remove in production)
        max_pages = 50  # Process max 50 pages per run to avoid rate limiting
        
        # Scrape notes pages
        for url in notes_urls[:max_pages]:
            try:
                note_found, note_added = self.scrape_ktunotes_page(url, 'notes')
                found += note_found
                added += note_added
            except Exception as e:
                logger.error(f"Error scraping {url}: {e}")
        
        # Scrape question paper pages
        for url in papers_urls[:max_pages]:
            try:
                paper_found, paper_added = self.scrape_ktunotes_page(url, 'papers')
                found += paper_found
                added += paper_added
            except Exception as e:
                logger.error(f"Error scraping {url}: {e}")
        
        return found, added
    
    def scrape_ktunotes_page(self, url: str, content_type: str) -> tuple[int, int]:
        """Scrape an individual ktunotes.in page for PDF links"""
        found = 0
        added = 0
        
        soup = self.fetch_page(url)
        if not soup:
            return found, added
        
        # Extract subject code from URL
        # Example: ktu-data-structures-cst201-notes -> CST201
        subject_code = self.extract_subject_code(url)
        if not subject_code:
            logger.warning(f"Could not extract subject code from {url}")
            return found, added
        
        # Get page title for better metadata
        title_tag = soup.find('h1', class_='entry-title') or soup.find('h1')
        page_title = title_tag.get_text(strip=True) if title_tag else ''
        
        # Find all download links
        # ktunotes.in uses various link patterns:
        # 1. Direct PDF links (upload.ktunotes.in)
        # 2. Google Drive links (drive.google.com/file/d/)
        
        download_links = []
        seen_urls = set()  # Deduplicate links
        
        # Domains to skip
        skip_domains = [
            'ktunotes.in/category',
            'ktunotes.in/upload-notes',
            'facebook.com', 'twitter.com', 'instagram.com',
            'linkedin.com', 'youtube.com', 'whatsapp.com',
            't.me', 'telegram',
        ]
        
        # Find PDF links
        for link in soup.find_all('a', href=True):
            href = link.get('href', '').strip()
            text = link.get_text(strip=True)
            
            # Skip invalid links
            if not href or href.startswith('#') or href == '/':
                continue
            
            # Skip if we've already seen this URL
            if href in seen_urls:
                continue
            
            # Skip navigation/social/category links
            if any(skip in href for skip in skip_domains):
                continue
            
            # Skip dead domains
            if 'upload.ktunotes.in' in href:
                continue  # This domain is no longer active
            
            # Only accept actual downloadable content
            is_pdf_link = (
                href.endswith('.pdf') or
                (
                    'drive.google.com/file/d/' in href and
                    '/view' in href
                )
            )
            
            if is_pdf_link:
                seen_urls.add(href)
                download_links.append({
                    'url': href,
                    'text': text,
                    'module': self.extract_module_number(text or href),
                })
        
        if download_links:
            logger.info(f"Found {len(download_links)} PDF links on {url}")
        
        for link in download_links:
            found += 1
            file_url = link['url']
            link_text = link['text']
            
            # Use file URL as source_url for deduplication (each PDF is unique)
            source_url_for_db = file_url
            
            # Determine title
            if link_text and len(link_text) > 5:
                title = link_text
            else:
                title = f"{page_title} - Module {link['module']}"
            
            if content_type == 'papers':
                year = self.extract_year(link_text + url) or 2024
                paper = ScrapedPaper(
                    subject_code=subject_code,
                    year=year,
                    exam_type=self._extract_exam_type(link_text),
                    month=self._extract_month(link_text),
                    file_url=file_url,
                    file_size_bytes=None,  # Skip HEAD request to save time
                    source_url=source_url_for_db
                )
                if self.save_paper(paper, subject_code.lower()):
                    added += 1
            else:
                note = ScrapedNote(
                    title=title[:200],  # Limit title length
                    description=f"Notes from {page_title}",
                    subject_code=subject_code,
                    module_number=link['module'],
                    file_url=file_url,
                    file_size_bytes=None,
                    source_url=source_url_for_db,
                    source_name='ktunotes.in'
                )
                if self.save_note(note, subject_code.lower()):
                    added += 1
        
        return found, added
    
    def _extract_exam_type(self, text: str) -> str:
        """Extract exam type from text"""
        text_lower = text.lower()
        if 'supply' in text_lower or 'supplementary' in text_lower:
            return 'supplementary'
        elif 'model' in text_lower:
            return 'model'
        elif 'solved' in text_lower:
            return 'solved'
        return 'regular'
    
    def _extract_month(self, text: str) -> Optional[str]:
        """Extract month from text"""
        months = ['january', 'february', 'march', 'april', 'may', 'june',
                  'july', 'august', 'september', 'october', 'november', 'december']
        text_lower = text.lower()
        for month in months:
            if month in text_lower:
                return month.capitalize()
        return None

    def scrape_site(self, base_url: str) -> tuple[int, int]:
        """Scrape a specific site - customize per source"""
        found = 0
        added = 0
        
        soup = self.fetch_page(base_url)
        if not soup:
            return found, added
        
        # Example: Find all PDF links
        # Customize selectors based on the actual site structure
        pdf_links = soup.find_all('a', href=re.compile(r'\.pdf$', re.IGNORECASE))
        
        for link in pdf_links:
            href = link.get('href', '')
            if not href:
                continue
            
            found += 1
            file_url = urljoin(base_url, href)
            title = link.get_text(strip=True) or href.split('/')[-1]
            
            # Extract metadata from title/URL
            subject_code = self.extract_subject_code(title + href)
            module_num = self.extract_module_number(title)
            year = self.extract_year(title + href)
            
            if subject_code:
                # Determine if it's a note or question paper
                if year and any(kw in title.lower() for kw in ['question', 'paper', 'exam']):
                    paper = ScrapedPaper(
                        subject_code=subject_code,
                        year=year,
                        exam_type='regular',
                        month=None,
                        file_url=file_url,
                        file_size_bytes=self.get_file_size(file_url),
                        source_url=base_url
                    )
                    if self.save_paper(paper, subject_code.lower()):
                        added += 1
                else:
                    note = ScrapedNote(
                        title=title,
                        description=None,
                        subject_code=subject_code,
                        module_number=module_num,
                        file_url=file_url,
                        file_size_bytes=self.get_file_size(file_url),
                        source_url=base_url,
                        source_name=urlparse(base_url).netloc
                    )
                    if self.save_note(note, subject_code.lower()):
                        added += 1
        
        return found, added


def main():
    """Main entry point"""
    logger.info("=" * 50)
    logger.info("KTU Notes Scraper - Starting")
    logger.info("=" * 50)
    
    scraper = KTUStudyMaterialsScraper()
    
    if not scraper.BASE_URLS:
        logger.warning("No source URLs configured. Please add URLs to BASE_URLS list.")
        logger.info("Scraper is ready but needs source URLs to be configured.")
        return
    
    scraper.scrape_all()
    
    logger.info("=" * 50)
    logger.info("Scraping completed")
    logger.info("=" * 50)


if __name__ == "__main__":
    main()
