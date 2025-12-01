# Scraper Configuration Guide

This guide explains how to configure and run the KTU content scraper.

## Overview

The scraper automatically collects study materials (notes and question papers) from KTU resource websites and uploads them to Supabase for manual review before publishing.

## Prerequisites

- Python 3.9+
- Supabase project with schema deployed
- GitHub repository (for automated runs)

## Local Setup

### 1. Install Python Dependencies

```bash
cd scripts
pip install -r requirements.txt
```

### 2. Set Environment Variables

Create a `.env` file in the `scripts/` directory or set system environment variables:

```bash
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_SERVICE_KEY="your-service-role-key"  # NOT anon key!
```

⚠️ **Important:** Use the `service_role` key, not the `anon` key. The service key bypasses Row Level Security and is required for inserting content.

### 3. Run Locally

```bash
python scraper.py
```

## Configuring Source URLs

### Step 1: Identify KTU Resource Sites

Find websites that host KTU study materials. Examples:
- University official resources
- Student-run study portals
- Open educational repositories

⚠️ **Legal Note:** Only scrape sites that:
- Allow automated access (check robots.txt)
- Have content that can be freely distributed
- You have permission to use

### Step 2: Add URLs to Scraper

Edit `scripts/scraper.py` and find the `KTUStudyMaterialsScraper` class:

```python
class KTUStudyMaterialsScraper(KTUScraper):
    """Scraper for KTU study materials websites"""
    
    BASE_URLS = [
        # Add your source URLs here
        "https://example-ktu-notes.com/materials",
        "https://another-resource.edu/ktu",
    ]
```

### Step 3: Customize Site-Specific Scraping

Different sites have different HTML structures. Customize the `scrape_site()` method:

```python
def scrape_site(self, base_url: str) -> tuple[int, int]:
    """Scrape a specific site"""
    found = 0
    added = 0
    
    soup = self.fetch_page(base_url)
    if not soup:
        return found, added
    
    # Example: Site has notes in a table
    if "example-site.com" in base_url:
        rows = soup.select('table.notes-table tr')
        for row in rows:
            link = row.select_one('a[href$=".pdf"]')
            if link:
                # Extract data...
                pass
    
    # Example: Site has notes in cards
    elif "another-site.com" in base_url:
        cards = soup.select('.note-card')
        for card in cards:
            title = card.select_one('.title').text
            pdf_url = card.select_one('a.download')['href']
            # Extract data...
            pass
    
    return found, added
```

### Step 4: Test Your Configuration

Run in dry-run mode (without Supabase credentials):

```bash
# Unset credentials for dry run
unset SUPABASE_URL
unset SUPABASE_SERVICE_KEY

python scraper.py
```

This will log what would be scraped without actually saving to the database.

## GitHub Actions Setup

### 1. Add Repository Secrets

Go to your GitHub repo → Settings → Secrets and variables → Actions

Add these secrets:
| Secret Name | Value |
|-------------|-------|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_SERVICE_KEY` | Your service_role key |

### 2. Workflow Configuration

The scraper runs automatically via `.github/workflows/scraper.yml`:

```yaml
name: Daily KTU Content Scraper

on:
  schedule:
    # Runs at 2 AM UTC (7:30 AM IST) every day
    - cron: '0 2 * * *'
  workflow_dispatch:
    # Allows manual triggering

jobs:
  scrape:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: pip install -r scripts/requirements.txt
      - run: python scripts/scraper.py
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_SERVICE_KEY: ${{ secrets.SUPABASE_SERVICE_KEY }}
```

### 3. Manual Trigger

To run the scraper manually:
1. Go to Actions tab in GitHub
2. Select "Daily KTU Content Scraper"
3. Click "Run workflow"

## Content Review Workflow

After scraping, content needs manual review:

### View Pending Content

In Supabase SQL Editor:

```sql
SELECT 
    rq.id as queue_id,
    rq.content_type,
    CASE 
        WHEN rq.content_type = 'note' THEN n.title
        ELSE CONCAT(qp.subject_id, ' - ', qp.year)
    END as content_title,
    rq.created_at
FROM review_queue rq
LEFT JOIN notes n ON rq.content_type = 'note' AND rq.content_id = n.id
LEFT JOIN question_papers qp ON rq.content_type = 'paper' AND rq.content_id = qp.id
WHERE rq.status = 'pending'
ORDER BY rq.created_at DESC;
```

### Approve Content

```sql
-- Approve a single item
SELECT approve_content('queue-id-here');

-- Or approve multiple
SELECT approve_content(id) 
FROM review_queue 
WHERE status = 'pending' 
AND created_at > NOW() - INTERVAL '1 day';
```

### Reject Content

```sql
UPDATE review_queue 
SET status = 'rejected', reviewed_at = NOW()
WHERE id = 'queue-id-here';
```

## Troubleshooting

### Scraper Returns 0 Items

1. Check if BASE_URLS are correctly set
2. Verify the site is accessible
3. Check if HTML selectors match the site structure
4. Look at the logs for error messages

### Permission Denied on Supabase

- Ensure you're using the `service_role` key, not `anon` key
- Check that the key hasn't expired

### Rate Limiting

If a site blocks requests:
1. Increase `REQUEST_DELAY` (default: 2 seconds)
2. Add random delays between requests
3. Rotate User-Agent strings

### Duplicate Content

The scraper checks `source_url` for duplicates. If you're getting duplicates:
- Ensure URLs are normalized (no trailing slashes, consistent protocol)
- Check the deduplication logic in `save_note()` and `save_paper()`

## Adding New Content Types

To scrape other content types (e.g., video lectures):

1. Create a new dataclass:
```python
@dataclass
class ScrapedVideo:
    title: str
    subject_code: str
    video_url: str
    duration_minutes: int
```

2. Add a new table in Supabase schema

3. Implement `save_video()` method

4. Update `scrape_site()` to detect videos

## Monitoring

### Check Scraping Logs

```sql
SELECT * FROM scraping_logs 
ORDER BY started_at DESC 
LIMIT 10;
```

### Daily Summary

```sql
SELECT 
    DATE(started_at) as date,
    SUM(items_found) as total_found,
    SUM(items_added) as total_added,
    COUNT(*) FILTER (WHERE status = 'failed') as failures
FROM scraping_logs
GROUP BY DATE(started_at)
ORDER BY date DESC;
```
