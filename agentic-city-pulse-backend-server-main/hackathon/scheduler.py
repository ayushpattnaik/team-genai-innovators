import asyncio
import logging
from datetime import datetime
from typing import Dict, List, Any
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.interval import IntervalTrigger
import threading
from concurrent.futures import ThreadPoolExecutor
from city_pulse_agent import city_pulse_agent

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

def log_info(message):
    print(f"--- Tool called: {message} ---")
    logger.info(message)

def log_error(message):
    print(f"--- Tool error: {message} ---")
    logger.error(message)

def log_warning(message):
    print(f"--- Tool called: {message} ---")
    logger.warning(message)

class DataScraperScheduler:
    """
    Scheduler to run Reddit and Twitter scrapers every 2 minutes in parallel
    """
    
    def __init__(self):
        self.scheduler = BackgroundScheduler()
        self.executor = ThreadPoolExecutor(max_workers=4)
        self.scraped_data = {
            'reddit': [],
            'twitter': [],
            'last_update': None
        }
        self.is_running = False
        
    def start(self):
        """Start the scheduler"""
        if not self.is_running:
            try:
                # Schedule Reddit scraper to run every 2 minutes
                self.scheduler.add_job(
                    func=self._run_reddit_scraper,
                    trigger=IntervalTrigger(minutes=2),
                    id='reddit_scraper',
                    name='Reddit Scraper',
                    replace_existing=True
                )
                
                # Schedule Twitter scraper to run every 2 minutes
                self.scheduler.add_job(
                    func=self._run_twitter_scraper,
                    trigger=IntervalTrigger(minutes=2),
                    id='twitter_scraper',
                    name='Twitter Scraper',
                    replace_existing=True
                )
                
                self.scheduler.start()
                self.is_running = True
                log_info("Data scraper scheduler started successfully")
                
                # Run initial scraping immediately
                self._run_initial_scraping()
                
            except Exception as e:
                log_error(f"Failed to start scheduler: {str(e)}")
                import traceback
                traceback.print_exc()
                raise
    
    def stop(self):
        """Stop the scheduler"""
        if self.is_running:
            try:
                self.scheduler.shutdown(wait=True)
                self.executor.shutdown(wait=True)
                self.is_running = False
                log_info("Data scraper scheduler stopped successfully")
            except Exception as e:
                log_error(f"Failed to stop scheduler: {str(e)}")
    
    def _run_initial_scraping(self):
        """Run initial scraping when scheduler starts"""
        print("--- Tool called: Running initial data scraping... ---")
        # Run both scrapers in parallel using ThreadPoolExecutor
        import concurrent.futures
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
            future_reddit = executor.submit(self._run_reddit_scraper)
            future_twitter = executor.submit(self._run_twitter_scraper)
            
            # Wait for both to complete
            future_reddit.result()
            future_twitter.result()
    
    def _run_reddit_scraper(self):
        """Run Reddit scraper in parallel"""
        try:
            print("--- Tool called: Starting Reddit scraper... ---")
            
            # Define relevant subreddits for city issues
            subreddits = ['citydata', 'weather', 'emergency', 'traffic', 'flood']
            
            # Run scraping for each subreddit in parallel using ThreadPoolExecutor
            import concurrent.futures
            with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
                future_to_subreddit = {
                    executor.submit(self._scrape_reddit_subreddit, subreddit): subreddit 
                    for subreddit in subreddits
                }
                
                reddit_data = []
                for future in concurrent.futures.as_completed(future_to_subreddit):
                    subreddit = future_to_subreddit[future]
                    try:
                        result = future.result()
                        reddit_data.append({
                            'subreddit': subreddit,
                            'data': result,
                            'timestamp': datetime.now().isoformat()
                        })
                    except Exception as e:
                        print(f"--- Tool error: Error scraping r/{subreddit}: {str(e)} ---")
            
            # Update scraped data
            self.scraped_data['reddit'] = reddit_data
            self.scraped_data['last_update'] = datetime.now().isoformat()
            
            print(f"--- Tool called: Reddit scraper completed. Scraped {len(reddit_data)} subreddits ---")
            
        except Exception as e:
            print(f"--- Tool error: Reddit scraper failed: {str(e)} ---")
    
    def _run_twitter_scraper(self):
        """Run Twitter scraper in parallel"""
        try:
            print("--- Tool called: Starting Twitter scraper... ---")
            
            # Run Twitter scraping
            twitter_data = self._scrape_twitter_data()
            
            # Update scraped data
            self.scraped_data['twitter'] = twitter_data
            self.scraped_data['last_update'] = datetime.now().isoformat()
            
            print(f"--- Tool called: Twitter scraper completed. Scraped {len(twitter_data)} tweets ---")
            
        except Exception as e:
            print(f"--- Tool error: Twitter scraper failed: {str(e)} ---")
    
    def _scrape_reddit_subreddit(self, subreddit: str) -> Dict[str, Any]:
        """Scrape data from a specific subreddit"""
        try:
            result = city_pulse_agent.get_reddit_news(subreddit, limit=5)
            return result
        except Exception as e:
            print(f"--- Tool error: Error scraping subreddit {subreddit}: {str(e)} ---")
            return {subreddit: [f"Error: {str(e)}"]}
    
    def _scrape_twitter_data(self) -> List[Dict[str, Any]]:
        """Scrape Twitter data"""
        try:
            result = city_pulse_agent.get_twitter_data(max_results=20)
            return result
        except Exception as e:
            print(f"--- Tool error: Error scraping Twitter data: {str(e)} ---")
            return []
    
    def get_scraped_data(self) -> Dict[str, Any]:
        """Get the latest scraped data"""
        return self.scraped_data.copy()
    
    def get_status(self) -> Dict[str, Any]:
        """Get scheduler status"""
        return {
            'is_running': self.is_running,
            'jobs': [job.id for job in self.scheduler.get_jobs()],
            'last_update': self.scraped_data['last_update'],
            'reddit_count': len(self.scraped_data['reddit']),
            'twitter_count': len(self.scraped_data['twitter'])
        }

# Global scheduler instance
data_scheduler = DataScraperScheduler()

def start_scheduler():
    """Start the global scheduler"""
    data_scheduler.start()

def stop_scheduler():
    """Stop the global scheduler"""
    data_scheduler.stop()

def get_scheduler_data():
    """Get data from the global scheduler"""
    return data_scheduler.get_scraped_data()

def get_scheduler_status():
    """Get status from the global scheduler"""
    return data_scheduler.get_status()

if __name__ == "__main__":
    # Run the scheduler continuously
    try:
        start_scheduler()
        print("Data scraper scheduler started successfully")
        print("Running every 2 minutes in background...")
        
        # Keep the script running
        try:
            import time
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("\nStopping scheduler...")
            stop_scheduler()
            print("Scheduler stopped.")
            
    except Exception as e:
        print(f"Failed to start scheduler: {e}")
        import traceback
        traceback.print_exc() 