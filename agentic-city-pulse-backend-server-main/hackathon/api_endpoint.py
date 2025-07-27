import os
import tempfile
import mimetypes
import logging
from datetime import datetime
from fastapi import FastAPI, File, UploadFile, HTTPException, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
import uvicorn
from agent_garden import CivicIssueReporting
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

def log_error(message):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] [ERROR] {message}")
    logger.error(message)

def log_warning(message):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] [WARNING] {message}")
    logger.warning(message)

app = FastAPI(title="Civic Issue Analysis API", version="1.0.0")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.on_event("startup")
async def startup_event():
    log_warning("API server starting up")

@app.on_event("shutdown")
async def shutdown_event():
    log_warning("API server shutting down")

@app.get("/", response_class=HTMLResponse)
async def read_root():
    with open("static/index.html", "r") as f:
        return HTMLResponse(content=f.read())

@app.post("/api/agent/civic")
async def civic_issue(file: UploadFile = File(None), text: str = Form(None)):
    session_id = datetime.now().strftime("%Y%m%d_%H%M%S_%f")[:-3]
    
    try:
        if file is not None:
            return await process_file_upload(file, session_id)
        elif text is not None and text.strip():
            return await process_text_input(text, session_id)
        else:
            log_error("No file or text input provided")
            raise HTTPException(status_code=400, detail="Either file or text input is required")
        
    except Exception as e:
        log_error(f"Request failed with error: {str(e)}")
        log_warning(f"Error type: {type(e).__name__}")
        log_warning(f"Error details: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

async def process_file_upload(file: UploadFile, session_id: str):
    """Process file upload and analyze based on file type"""
    try:
        temp_dir = tempfile.mkdtemp(prefix="CIVIC_ISSUES")
        
        temp_file_path = os.path.join(temp_dir, file.filename)
        content = await file.read()
        
        with open(temp_file_path, "wb") as f:
            f.write(content)
        
        file_type, _ = mimetypes.guess_type(file.filename)
        
        civic_agent = CivicIssueReporting(temp_file_path, file_type)
        
        if file_type and file_type.startswith('image/'):
            analysis_type = 'IMAGE'
        elif file_type and file_type.startswith('audio/'):
            analysis_type = 'SPEECH'
        else:
            analysis_type = 'TEXT'
        
        result = civic_agent.analyze_input(analysis_type)
        
        try:
            os.remove(temp_file_path)
            os.rmdir(temp_dir)
        except Exception as e:
            log_error(f"Cleanup error: {str(e)}")
        
        return {"result": result, "analysis_type": analysis_type, "input_type": "file", "filename": file.filename}
        
    except Exception as e:
        try:
            if 'temp_file_path' in locals():
                os.remove(temp_file_path)
            if 'temp_dir' in locals():
                os.rmdir(temp_dir)
        except Exception as cleanup_error:
            log_error(f"Cleanup error after exception: {str(cleanup_error)}")
        raise e

async def process_text_input(text: str, session_id: str):
    """Process text input directly"""
    try:
        civic_agent = CivicIssueReporting(None, "text/plain")
        result = civic_agent.analyze_input('TEXT', text)
        
        return {"result": result, "analysis_type": "TEXT", "input_type": "text", "text_length": len(text)}
        
    except Exception as e:
        raise e

@app.post("/api/city-pulse/analyze")
async def analyze_city_pulse(query: str = Form(...), include_reddit: bool = Form(True), include_twitter: bool = Form(True)):
    """
    Analyze city issues using Reddit and Twitter data
    """
    try:
        result = city_pulse_agent.analyze_city_issues(query, include_reddit, include_twitter)
        return {"result": result}
    except Exception as e:
        log_error(f"City pulse analysis failed: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/city-pulse/reddit/{subreddit}")
async def get_reddit_news(subreddit: str, limit: int = 5):
    """
    Get Reddit news from a specific subreddit
    """
    try:
        result = city_pulse_agent.get_reddit_news(subreddit, limit)
        return {"result": result}
    except Exception as e:
        log_error(f"Reddit news fetch failed: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/city-pulse/twitter")
async def get_twitter_data(max_results: int = 20):
    """
    Get Twitter data (currently sample data)
    """
    try:
        result = city_pulse_agent.get_twitter_data(max_results)
        return {"result": result}
    except Exception as e:
        log_error(f"Twitter data fetch failed: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    log_warning("Starting uvicorn server")
    uvicorn.run(app, host="0.0.0.0", port=8000)