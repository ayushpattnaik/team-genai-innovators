import os
import tempfile
import mimetypes
import logging
from datetime import datetime
from fastapi import FastAPI, File, UploadFile, HTTPException, Form, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
import uvicorn
from agent_garden import CivicIssueReporting
import magic
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
from PIL.ExifTags import TAGS, GPSTAGS
from fractions import Fraction
from get_metadata import extract_image_metadata, extract_audio_metadata, extract_gps_location

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
    """
    Main endpoint for civic issue reporting from Flutter UI
    Accepts either a file (image/audio) or text input
    """
    session_id = datetime.now().strftime("%Y%m%d_%H%M%S_%f")[:-3]
    
    try:
        if file is not None:
            return await process_file_upload(file, session_id)
        else:
            logger.error("No file or text input provided")
            raise HTTPException(status_code=400, detail="Either file or text input is required")
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Request failed with error: {str(e)}")
        logger.warning(f"Error type: {type(e).__name__}")
        logger.warning(f"Error details: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

async def process_file_upload(file: UploadFile, session_id: str):
    """Process file upload from Flutter UI and analyze based on file type"""
    try:
        # Validate file upload
        if not file.filename:
            raise HTTPException(status_code=400, detail="No filename provided")
        
        # Read file content
        content = await file.read()
        if not content:
            raise HTTPException(status_code=400, detail="Empty file uploaded")
        
        logger.info(f"Received file: {file.filename}, size: {len(content)} bytes")
        
        # Create temporary directory and file
        temp_dir = tempfile.mkdtemp(prefix="CIVIC_ISSUES_")
        temp_file_path = os.path.join(temp_dir, file.filename)
        
        # Write file content to temporary file
        with open(temp_file_path, "wb") as f:
            f.write(content)
        
        # Get MIME type using python-magic for better accuracy
        try:
            mime_type = magic.from_file(temp_file_path, mime=True)
        except Exception:
            # Fallback to mimetypes if magic fails
            mime_type, _ = mimetypes.guess_type(file.filename)
        
        if not mime_type:
            raise HTTPException(status_code=400, detail="Could not determine file type")
        
        file_metadata = {}
        location_metadata = {}
        
        # Extract metadata based on file type
        if mime_type and mime_type.startswith('image/'):
            analysis_type = 'IMAGE'
            file_metadata = extract_image_metadata(temp_file_path)
            location_metadata = extract_gps_location(temp_file_path)
            logger.info(f"Processing image: {file.filename}, GPS: {location_metadata}")
            
        elif mime_type and mime_type.startswith('audio/'):
            analysis_type = 'SPEECH'
            file_metadata = extract_audio_metadata(temp_file_path)
            logger.info(f"Processing audio: {file.filename}")
            
        else:
            # Clean up before raising error
            try:
                os.remove(temp_file_path)
                os.rmdir(temp_dir)
            except Exception:
                pass
            raise HTTPException(
                status_code=400, 
                detail=f"Unsupported file type: {mime_type}. Only image and audio files are supported."
            )
        
        # Combine all metadata
        combined_metadata = {
            **file_metadata,
            "location": location_metadata,
            "file_info": {
                "filename": file.filename,
                "mime_type": mime_type,
                "size_bytes": len(content),
                "size_mb": round(len(content) / (1024 * 1024), 2)
            }
        }
        
        # Initialize civic agent with file path, MIME type, and metadata
        civic_agent = CivicIssueReporting(temp_file_path, mime_type, str(combined_metadata))
        
        # Analyze input based on type, passing metadata
        logger.info(f"Starting {analysis_type} analysis for session {session_id}")
        result = await civic_agent.analyze_input(analysis_type, combined_metadata)
        logger.info(f"Analysis completed for session {session_id}")
        
        # Cleanup temporary files
        try:
            os.remove(temp_file_path)
            os.rmdir(temp_dir)
            logger.info(f"Cleaned up temporary files for session {session_id}")
        except Exception as e:
            log_error(f"Cleanup error: {str(e)}")
        
        # Return response optimized for Flutter UI
        return {
            "success": True,
            "session_id": session_id,
            "analysis_type": analysis_type,
            "input_type": "file",
            "result": result,
            "metadata": combined_metadata,
            "timestamp": datetime.now().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        # Cleanup on error
        try:
            if 'temp_file_path' in locals() and os.path.exists(temp_file_path):
                os.remove(temp_file_path)
            if 'temp_dir' in locals() and os.path.exists(temp_dir):
                os.rmdir(temp_dir)
        except Exception as cleanup_error:
            log_error(f"Cleanup error after exception: {str(cleanup_error)}")
        
        log_error(f"File processing failed: {str(e)}")
        raise HTTPException(status_code=500, detail=f"File processing failed: {str(e)}")


if __name__ == "__main__":
    log_warning("Starting uvicorn server")
    uvicorn.run(app, host="0.0.0.0", port=8000)