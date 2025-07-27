import base64
import os
import logging
from datetime import datetime
import google.generativeai as genai
import json
import speech_recognition as sr 
from pydub import AudioSegment
from pydub.silence import split_on_silence
from dotenv import load_dotenv

# Load environment variables
load_dotenv('.env')

API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-pro-vision")

CIVIC_IMAGE_PROMPT = """
You are an AI assistant specializing in civic issue analyzing. For the given image and associated metadata, determine the situation.

Metadata: {metadata}

Respond in JSON format only:
- Extract all civic issue-related information from the image.
- In the description, explain what's happening.
- If the situation is normal, return eventName as 'NORMAL_IMAGE'.
- Use one of these categories: ['TRAFFIC_CONGESTION', 'DRAINAGE_ISSUE', 'FLOOD', 'WATER_LOGGING', 'ROAD_BLOCK', 'TREE_IN_BETWEEN', 'ELECTRICITY_ISSUE']
- Return as: [{
    eventName: <SITUATION_NAME>,
    location_coordinates: <coordinates if visible>,
    areaName: <Area name if found>,
    roadName: <Road name if found>,
    cityName: <City name if found>,
    description: <Describe the situation>,
    timeStamp: <Current timestamp>
}]
"""


CIVIC_TEXT_PROMPT_TEMPLATE = """
You are an AI assistant specializing in civic issue analyzing.
Analyze the following textual civic complaint or audio transcript, along with its metadata.

Metadata: {metadata}

Respond in JSON format only:
- Extract all relevant civic issue information.
- If situation is normal, return eventName as 'NORMAL_IMAGE'.
- Use categories: ['TRAFFIC_CONGESTION', 'DRAINAGE_ISSUE', 'FLOOD', 'WATER_LOGGING', 'ROAD_BLOCK', 'TREE_IN_BETWEEN', 'ELECTRICITY_ISSUE']
- Return as a list:
[{
    eventName: <SITUATION_NAME>,
    location_coordinates: <if mentioned>,
    areaName: <Area>,
    roadName: <Road>,
    cityName: <City>,
    description: <Description>
}]

Text:
{text_data}
"""

# Configure Gemini
genai.configure(api_key=API_KEY)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler()]
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

class CivicIssueReporting:
    def __init__(self, file_path, mime_type, file_metadata):
        self.file = file_path
        self.mime_type = mime_type
        self.file_metadata = file_metadata

    async def analyze_input(self, analysis_type, metadata):
        """Analyze input based on MIME type and analysis type"""
        self.file_metadata = metadata
        try:
            if analysis_type == 'IMAGE':
                result = await self.process_image()
            elif analysis_type == 'SPEECH':
                result = await self.process_audio()
            else:
                raise ValueError(f"Unsupported analysis type: {analysis_type}")
            return result
        except Exception as e:
            log_error(f"Analysis failed: {str(e)}")
            raise

    async def process_image(self):
        """Process image file - convert to base64 and analyze with Gemini"""
        try:
            image_parts = self.image_file_to_base64(self.file)
            model = genai.GenerativeModel(GEMINI_MODEL)

            prompt = CIVIC_IMAGE_PROMPT.replace("{metadata}", json.dumps(self.file_metadata))
            response = model.generate_content([
                prompt,
                {"mime_type": "image/jpeg", "data" : image_parts[0]}
            ])
            json_text = response.text.strip().lstrip("```json").rstrip("```")
            print(f"respose: {json_text}")
            return response.text

        except Exception as e:
            log_error(f"Image processing failed: {str(e)}")
            raise

    async def process_audio(self):
        """Convert speech to text and analyze using Gemini"""
        try:
            transcription = self.get_text()
            model = genai.GenerativeModel("gemini-pro")
            prompt = CIVIC_TEXT_PROMPT_TEMPLATE.replace("{metadata}", json.dumps(self.file_metadata)).replace("{text_data}", transcription)
            response = model.generate_content(
                prompt
            )
            json_text = response.text.strip().lstrip("```json").rstrip("```")
            print(f"respose: {json_text}")
            return response.text

        except Exception as e:
            log_error(f"Audio processing failed: {str(e)}")
            raise

    def get_text(self):
        """Convert audio file to text using speech recognition"""
        r = sr.Recognizer()
        try:
            sound = AudioSegment.from_file(self.file)
        except Exception as e:
            log_error(f"Failed to load audio file: {str(e)}")
            return ""

        chunks = split_on_silence(sound, min_silence_len=500, silence_thresh=sound.dBFS-14, keep_silence=500)

        folder_name = "audio-chunks"
        os.makedirs(folder_name, exist_ok=True)
        whole_text = ""

        try:
            for i, audio_chunk in enumerate(chunks, start=1):
                chunk_filename = os.path.join(folder_name, f"chunk{i}.wav")
                try:
                    audio_chunk.export(chunk_filename, format="wav")
                    with sr.AudioFile(chunk_filename) as source:
                        r.adjust_for_ambient_noise(source)
                        audio = r.record(source)
                        text = r.recognize_google(audio)
                except sr.UnknownValueError:
                    log_warning(f"Could not recognize speech in chunk {i}")
                    continue
                except sr.RequestError as e:
                    log_error(f"Google Speech Recognition service error in chunk {i}: {str(e)}")
                    continue
                except Exception as e:
                    log_error(f"Error processing chunk {i}: {str(e)}")
                    continue
                else:
                    text = f"{text.capitalize()}. "
                    whole_text += text
                finally:
                    if os.path.exists(chunk_filename):
                        os.remove(chunk_filename)
        finally:
            try:
                os.rmdir(folder_name)
            except Exception as e:
                log_warning(f"Failed to clean up chunks folder: {str(e)}")

        return whole_text.strip()

    def image_file_to_base64(self, image_path):
        """Convert image file to base64 string"""
        try:
            with open(image_path, "rb") as img_file:
                image_data = img_file.read()
                encoded_string = base64.b64encode(image_data).decode('utf-8')
                return [encoded_string]
        except Exception as e:
            log_error(f"Failed to convert image to base64: {str(e)}")
            raise
