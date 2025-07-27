# Data Scraper Scheduler

This module provides a background scheduler that automatically runs Reddit and Twitter scrapers every 2 minutes in parallel.

## Features

- **Parallel Execution**: Reddit and Twitter scrapers run simultaneously
- **Automatic Scheduling**: Runs every 2 minutes automatically
- **Error Handling**: Robust error handling with logging
- **API Integration**: RESTful endpoints to control and monitor the scheduler
- **Data Storage**: Maintains the latest scraped data in memory

## Architecture

### Components

1. **DataScraperScheduler Class**: Main scheduler class
2. **AsyncIOScheduler**: Uses APScheduler for job scheduling
3. **ThreadPoolExecutor**: Handles parallel execution of scrapers
4. **Global Instance**: `data_scheduler` for easy access

### Scraping Targets

**Reddit Subreddits:**
- `citydata` - General city-related discussions
- `weather` - Weather updates and alerts
- `emergency` - Emergency situations
- `traffic` - Traffic and transportation issues
- `flood` - Flooding and water-related issues

**Twitter Data:**
- Sample tweets with city-related hashtags
- Currently uses mock data (can be extended with real Twitter API)

## Installation

1. Install required dependencies:
```bash
pip install -r requirements.txt
```

2. Ensure your `config.env` file has Reddit API credentials:
```
REDDIT_CLIENT_ID=your_client_id
REDDIT_CLIENT_SECRET=your_client_secret
REDDIT_USER_AGENT=your_user_agent
```

## Usage

### Automatic Integration

The scheduler automatically starts when you run the `start.sh` script and runs in the background.

### Manual Control

```python
from scheduler import start_scheduler, stop_scheduler, get_scheduler_data, get_scheduler_status

# Start the scheduler
start_scheduler()

# Get scheduler status
status = get_scheduler_status()
print(status)

# Get scraped data
data = get_scheduler_data()
print(data)

# Stop the scheduler
stop_scheduler()
```

### Running the Scheduler

#### Using the Shell Script (Recommended)
```bash
./start.sh
```
This will start:
- Data scraper scheduler (background)
- FastAPI backend server
- Static frontend server

#### Running Scheduler Directly
```bash
python scheduler.py
```
This runs the scheduler in the foreground. Press Ctrl+C to stop.

### Background Process Management

The scheduler runs as a background process when started via `start.sh`. The script will:
- Start the scheduler with PID tracking
- Monitor the scheduler process
- Automatically clean up when stopping all services
- Show scheduler status in the startup output

## Testing

Run the test script to verify the scheduler works:

```bash
python test_scheduler.py
```

This will:
1. Start the scheduler
2. Wait for initial scraping
3. Display status and sample data
4. Wait for the next scheduled run
5. Stop the scheduler

## Logging

The scheduler logs all activities to:
- Console output
- `scheduler.log` file

Log levels:
- **INFO**: Normal operations
- **WARNING**: Non-critical issues
- **ERROR**: Critical errors

## Configuration

### Scheduler Settings

You can modify the scheduler behavior in `scheduler.py`:

```python
# Change interval (default: 2 minutes)
IntervalTrigger(minutes=2)

# Change number of worker threads (default: 4)
ThreadPoolExecutor(max_workers=4)

# Modify subreddits to scrape
subreddits = ['citydata', 'weather', 'emergency', 'traffic', 'flood']
```

### Performance Tuning

- **Worker Threads**: Increase `max_workers` for more parallel scraping
- **Interval**: Decrease interval for more frequent updates (be mindful of API limits)
- **Data Retention**: Currently stores only latest data (can be extended to store history)

## Error Handling

The scheduler includes comprehensive error handling:

- **API Failures**: Individual subreddit failures don't stop the entire process
- **Network Issues**: Automatic retry on next scheduled run
- **Resource Cleanup**: Proper cleanup of threads and resources
- **Graceful Shutdown**: Clean shutdown when stopping the scheduler

## Monitoring

Monitor the scheduler through:

1. **Logs**: Check `scheduler.log` for detailed activity
2. **API Endpoints**: Use `/api/scheduler/status` for real-time status
3. **Console Output**: Real-time logging to console

## Future Enhancements

- **Database Storage**: Store historical scraped data
- **Real Twitter API**: Replace sample data with real Twitter scraping
- **Configurable Targets**: Allow dynamic configuration of subreddits and hashtags
- **Rate Limiting**: Implement proper rate limiting for APIs
- **Data Analytics**: Add analytics on scraped data trends 