import random
import os
from typing import List, Dict           
from google.adk.agents import Agent

from dotenv import load_dotenv
load_dotenv()

import praw
from praw.exceptions import PRAWException

def get_reddit_citydev_news(subreddit: str, limit: int = 5) -> dict[str, list[str]]:
    """
    Fetches top post titles from a specified subreddit using the Reddit API.

    Args:
        subreddit: The name of the subreddit to fetch news from (e.g., 'citydata','flood', 'rain', 'weather', 'emergency', 'storm', 'alert', 'evacuation', 'cyclone', 'disaster').
        cities (list): List of city names (e.g., ['bangalore']).
        limit: The maximum number of top posts to fetch.

    Returns:
        A dictionary with the subreddit name as key and a list of
        post titles as value. Returns an error message if credentials are
        missing, the subreddit is invalid, or an API error occurs.
    """
    print(f"--- Tool called: Fetching from r/{subreddit} via Reddit API ---")
    client_id = os.getenv("REDDIT_CLIENT_ID")
    client_secret = os.getenv("REDDIT_CLIENT_SECRET")
    user_agent = os.getenv("REDDIT_USER_AGENT")

    if not all([client_id, client_secret, user_agent]):
        print("--- Tool error: Reddit API credentials missing in .env file. ---")
        return {subreddit: ["Error: Reddit API credentials not configured."]}

    try:
        reddit = praw.Reddit(
            client_id=client_id,
            client_secret=client_secret,
            user_agent=user_agent,
        )
        # Check if subreddit exists and is accessible
        reddit.subreddits.search_by_name(subreddit, exact=True)
        sub = reddit.subreddit(subreddit)
        top_posts = list(sub.hot(limit=limit)) # Fetch hot posts
        titles = [post.title for post in top_posts]
        if not titles:
             return {subreddit: [f"No recent hot posts found in r/{subreddit}."]}
        return {subreddit: titles}
    except PRAWException as e:
        print(f"--- Tool error: Reddit API error for r/{subreddit}: {e} ---")
        # More specific error handling could be added here (e.g., 404 for invalid sub)
        return {subreddit: [f"Error accessing r/{subreddit}. It might be private, banned, or non-existent. Details: {e}"]}
    except Exception as e: # Catch other potential errors
        print(f"--- Tool error: Unexpected error for r/{subreddit}: {e} ---")
        return {subreddit: [f"An unexpected error occurred while fetching from r/{subreddit}."]}

sample_tweets = [
        {
            "id": 1,
            "date": "2024-06-01T12:00:00",
            "content": "Heavy rain causing flooding on Main St #flood #rainyday",
            "username": "cityresident",
            "hashtag": "#flood"
        },
        {
            "id": 2,
            "date": "2024-06-01T13:00:00",
            "content": "Major traffic jam downtown due to road construction #traffic #construction",
            "username": "commuter123",
            "hashtag": "#traffic"
        },
        {
            "id": 3,
            "date": "2024-06-01T14:00:00",
            "content": "Power outage in several neighborhoods #poweroutage",
            "username": "localnews",
            "hashtag": "#poweroutage"
        },
        {
            "id": 4,
            "date": "2024-06-01T15:00:00",
            "content": "Waterlogging reported near Central Park after continuous rain #flood #rainyday",
            "username": "urbanwatch",
            "hashtag": "#flood"
        },
        {
            "id": 5,
            "date": "2024-06-01T15:30:00",
            "content": "Accident on 5th Avenue causing major delays #accident #traffic",
            "username": "cityalerts",
            "hashtag": "#accident"
        },
        {
            "id": 6,
            "date": "2024-06-01T16:00:00",
            "content": "Air quality dropping fast due to nearby construction and traffic #airquality #pollution",
            "username": "greenwatch",
            "hashtag": "#airquality"
        },
        {
            "id": 7,
            "date": "2024-06-01T16:30:00",
            "content": "Power outage affecting downtown area, estimated restoration by 8 PM #poweroutage",
            "username": "energyupdates",
            "hashtag": "#poweroutage"
        },
        {
            "id": 8,
            "date": "2024-06-01T17:00:00",
            "content": "Metro services disrupted due to signal failure #metro #transport",
            "username": "citycommute",
            "hashtag": "#metro"
        },
        {
            "id": 9,
            "date": "2024-06-01T17:30:00",
            "content": "Garbage piling up in Sector 9 – no pickups for 3 days now #garbage #health",
            "username": "residentsvoice",
            "hashtag": "#garbage"
        },
        {
            "id": 10,
            "date": "2024-06-01T18:00:00",
            "content": "Sudden c warning issued – stay indoors if possible #weather #storm",
            "username": "weathernow",
            "hashtag": "#storm"
        }
    ]

def scrape_city_tweets(max_results_per_hashtag: int = 20) -> List[Dict]:
    return sample_tweets

root_agent = Agent(
    name="agents",
    description="Agent to process city problem reports from Twitter and Reddit.",
    model="gemini-1.5-flash-latest",
    instruction=(
        "You are the City Issues Scout Agent. Your task is to fetch and summarize city-specific problems like floods, traffic, weather disruptions, and emergencies using both **Twitter** and **Reddit** data sources.\n\n"

        "🔍 **1. Identify Intent:**\n"
        "- Determine whether the user is asking about urban issues such as flooding, weather, traffic, construction, emergencies, or city infrastructure.\n"
        "- Based on intent, decide whether to call Twitter, Reddit, or both data sources.\n\n"

        "🧭 **2. Extract Location Context:**\n"
        "- Extract any mentioned cities or locations from the user query.\n"
        "- For Twitter: Use predefined hashtags like #flood, #storm, #traffic.\n"
        "- For Reddit: Identify relevant subreddits like 'r/<city>', 'r/weather', 'r/flood', or use 'CityData' if not specified.\n\n"

        "🛠️ **3. MUST CALL TOOLS:**\n"
        "- Use `scrape_city_tweets` to fetch tweets based on hashtags.\n"
        "- Use `get_reddit_citydev_news` to fetch Reddit posts from relevant subreddits.\n"
        "- Do NOT fabricate summaries. Always use actual data from the tools.\n\n"

        "🧠 **4. Synthesize Output:**\n"
        "- Use the exact data returned by the tools.\n"
        "- Include tweet content (Twitter) and post title + link (Reddit).\n\n"

        "📝 **5. Format Response:**\n"
        "- Group findings by platform and then by hashtag or subreddit/city.\n"
        "- Present results as concise, bulleted lists.\n"
        "- If no relevant results are found, mention that clearly."
    ),
    tools=[scrape_city_tweets, get_reddit_citydev_news]
)

