import random
import os
from typing import List, Dict           
from google.adk.agents import Agent

from dotenv import load_dotenv
load_dotenv('.env')

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

adk_agent = Agent(
    name="city_pulse_agent",
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

# Create a wrapper class to maintain compatibility with existing API
class CityPulseAgentWrapper:
    """
    Wrapper class to maintain compatibility with existing API while using ADK agent.
    """
    
    def __init__(self, agent):
        self.agent = agent
    
    def analyze_city_issues(self, query: str, include_reddit: bool = True, include_twitter: bool = True) -> dict:
        """
        Analyze city issues using the ADK agent.
        """
        from datetime import datetime
        
        # Build the query based on include flags
        if not include_reddit and not include_twitter:
            return {
                "query": query,
                "timestamp": datetime.now().isoformat(),
                "reddit_data": {},
                "twitter_data": [],
                "summary": "No data sources selected."
            }
        
        try:
            # Try to run the ADK agent
            if hasattr(self.agent, 'run'):
                result = self.agent.run(query)
            elif hasattr(self.agent, 'invoke'):
                result = self.agent.invoke(query)
            elif hasattr(self.agent, 'call'):
                result = self.agent.call(query)
            else:
                # Fallback: manually collect data
                reddit_data = {}
                twitter_data = []
                
                if include_reddit:
                    reddit_data = get_reddit_citydev_news("citydata", 5)
                
                if include_twitter:
                    twitter_data = scrape_city_tweets(20)
                
                result = f"Query: {query}\nReddit data: {reddit_data}\nTwitter data: {twitter_data}"
            
            # Format the result to match the expected structure
            return {
                "query": query,
                "timestamp": datetime.now().isoformat(),
                "reddit_data": {},  # ADK agent handles this internally
                "twitter_data": [],  # ADK agent handles this internally
                "summary": str(result)
            }
        except Exception as e:
            # Fallback to manual data collection if ADK agent fails
            reddit_data = {}
            twitter_data = []
            
            if include_reddit:
                reddit_data = get_reddit_citydev_news("citydata", 5)
            
            if include_twitter:
                twitter_data = scrape_city_tweets(20)
            
            return {
                "query": query,
                "timestamp": datetime.now().isoformat(),
                "reddit_data": reddit_data,
                "twitter_data": twitter_data,
                "summary": f"Analysis completed with fallback method. Error: {str(e)}"
            }
    
    def get_reddit_news(self, subreddit: str, limit: int = 5) -> dict:
        """
        Get Reddit news from a specific subreddit.
        """
        return get_reddit_citydev_news(subreddit, limit)
    
    def get_twitter_data(self, max_results: int = 20) -> List[Dict]:
        """
        Get Twitter data (currently sample data).
        """
        return scrape_city_tweets(max_results)
    
    def run(self, query: str):
        """
        Direct access to the ADK agent's run method.
        """
        try:
            if hasattr(self.agent, 'run'):
                return self.agent.run(query)
            elif hasattr(self.agent, 'invoke'):
                return self.agent.invoke(query)
            elif hasattr(self.agent, 'call'):
                return self.agent.call(query)
            else:
                # Fallback: manually collect data
                reddit_data = get_reddit_citydev_news("citydata", 5)
                twitter_data = scrape_city_tweets(20)
                return f"Query: {query}\nReddit data: {reddit_data}\nTwitter data: {twitter_data}"
        except Exception as e:
            # Fallback to manual data collection if ADK agent fails
            reddit_data = get_reddit_citydev_news("citydata", 5)
            twitter_data = scrape_city_tweets(20)
            return f"Query: {query}\nReddit data: {reddit_data}\nTwitter data: {twitter_data}\nError: {str(e)}"

# Create the wrapper instance
city_pulse_agent = CityPulseAgentWrapper(adk_agent)

if __name__ == "__main__":
    # Test the agent
    result = city_pulse_agent.run("flooding in downtown area")
    print("Analysis Result:")
    print(result) 