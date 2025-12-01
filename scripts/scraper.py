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
from typing import Optional
from dataclasses import dataclass
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup
from supabase import create_client, Client

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
    
    def generate_file_hash(self, url: str) -> str:
        """Generate a hash for deduplication"""
        return hashlib.md5(url.encode()).hexdigest()[:16]
    
    def upload_to_storage(self, file_url: str, filename: str) -> Optional[str]:
        """Download file and upload to Supabase storage"""
        if not self.supabase:
            return file_url  # In dry-run mode, return original URL
        
        try:
            # Download file
            response = self.session.get(file_url, timeout=60)
            response.raise_for_status()
            
            # Upload to Supabase storage
            path = f"notes/{filename}"
            self.supabase.storage.from_('pdfs').upload(
                path,
                response.content,
                {'content-type': 'application/pdf'}
            )
            
            # Get public URL
            return self.supabase.storage.from_('pdfs').get_public_url(path)
        except Exception as e:
            logger.error(f"Failed to upload {file_url}: {e}")
            return file_url  # Fallback to original URL
    
    def save_note(self, note: ScrapedNote, subject_id: str) -> bool:
        """Save a scraped note to database"""
        if not self.supabase:
            logger.info(f"[DRY-RUN] Would save note: {note.title}")
            return True
        
        try:
            # Check for duplicates
            existing = self.supabase.table('notes').select('id').eq(
                'source_url', note.source_url
            ).execute()
            
            if existing.data:
                logger.info(f"Note already exists: {note.title}")
                return False
            
            # Upload file to storage
            filename = f"{subject_id}_{note.module_number}_{self.generate_file_hash(note.file_url)}.pdf"
            stored_url = self.upload_to_storage(note.file_url, filename)
            
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
            # Check for duplicates
            existing = self.supabase.table('question_papers').select('id').eq(
                'source_url', paper.source_url
            ).execute()
            
            if existing.data:
                logger.info(f"Paper already exists: {paper.subject_code} {paper.year}")
                return False
            
            # Upload file to storage
            filename = f"paper_{subject_id}_{paper.year}_{paper.exam_type}.pdf"
            stored_url = self.upload_to_storage(paper.file_url, filename)
            
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
    """Scraper for KTU study materials websites"""
    
    # Add URLs of KTU resource sites here
    # Note: Ensure you have permission to scrape these sites
    BASE_URLS = [
        # Example URLs - replace with actual permitted sources
        # "https://example-ktu-resources.com/notes",
    ]
    
    def extract_subject_code(self, text: str) -> Optional[str]:
        """Extract subject code from text (e.g., CST201, MAT101)"""
        match = re.search(r'([A-Z]{2,4}\d{3})', text)
        return match.group(1) if match else None
    
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
                # Implement site-specific scraping logic here
                # This is a template - customize per source site
                found, added = self.scrape_site(base_url)
                total_found += found
                total_added += added
            except Exception as e:
                logger.error(f"Error scraping {base_url}: {e}")
                self.log_scraping_run(base_url, 0, 0, 'failed', str(e))
        
        self.log_scraping_run('all_sources', total_found, total_added)
        logger.info(f"Scraping complete. Found: {total_found}, Added: {total_added}")
    
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
