import os
import base64
import tempfile
import speech_recognition as sr
from pydub import AudioSegment
from pydub.silence import split_on_silence
from datetime import datetime
from google.adk.agents import Agent
from google.adk.sessions import InMemorySessionService
from google.adk.runners import Runner
from google.adk.tools.tool_context import ToolContext # For accessing session state in tools
from google.genai import types as genai_types # For formatting messages for ADK
from dotenv import load_dotenv

load_dotenv('.env')
GEMINI_MODEL = os.getenv("GEMINI_MODEL")

# Image processing agent
multimodel_incident_report_agent = Agent(
    name="multimodel_incident_report_agent",
    description="Agent to process visual data and extract meaningful civic issue information from images.",
    model=GEMINI_MODEL,
    instruction=(
        """
        You are an AI assistant specializing in analyzing civic issues based on visual inputs (images).

        For the given image, determine the situation depicted and extract relevant civic issue information.        

        Respond ONLY in JSON format as a list of detected civic events.     

        Instructions:
        - Extract all relevant information from the image regarding the civic issue.
        - In the "description", clearly explain what is happening in the image.
        - If the image shows no abnormality, return a single object with "eventName": "NORMAL_IMAGE".
        - Categorize the situation using one of the following event names:
          ['TRAFFIC_CONGESTION', 'DRAINAGE_ISSUE', 'FLOOD', 'WATER_LOGGING', 'ROAD_BLOCK', 'TREE_IN_BETWEEN', 'ELECTRICITY_ISSUE']
        - The "location_coordinates" field must be an object with "latitude" and "longitude" fields (as floats).        

        Expected JSON format:
        [
          {
            "eventName": "<SITUATION_NAME or 'NORMAL_IMAGE'>",
            "location_coordinates": {
              "latitude": <float>,
              "longitude": <float>
            },
            "areaName": "<Area name if available, else null>",
            "roadName": "<Road name if available, else null>",
            "cityName": "<City name if available, else null>",
            "description": "<Detailed description of the observed situation>",
            "timeStamp": "<ISO 8601 formatted timestamp>"
          }
        ]
        """
    )
)

# Audio processing agent
audio_incident_report_agent = Agent(
    name="audio_incident_report_agent",
    description="Agent to process audio/speech data and extract meaningful civic issue information from transcribed text.",
    model=GEMINI_MODEL,
    instruction=(
        """
        You are an AI assistant specializing in analyzing civic issues based on speech/audio inputs.

        For the given transcribed text from audio, determine the civic issue being reported.        

        Respond ONLY in JSON format as a list of detected civic events.     

        Instructions:
        - Extract all relevant information from the transcribed text regarding the civic issue.
        - In the "description", clearly explain the civic issue being reported.
        - If the text contains no civic issue, return a single object with "eventName": "NO_ISSUE_REPORTED".
        - Categorize the situation using one of the following event names:
          ['TRAFFIC_CONGESTION', 'DRAINAGE_ISSUE', 'FLOOD', 'WATER_LOGGING', 'ROAD_BLOCK', 'TREE_IN_BETWEEN', 'ELECTRICITY_ISSUE', 'NOISE_POLLUTION', 'WASTE_MANAGEMENT']
        - The "location_coordinates" field must be an object with "latitude" and "longitude" fields (as floats). If location is not mentioned, use null values.        

        Expected JSON format:
        [
          {
            "eventName": "<SITUATION_NAME or 'NO_ISSUE_REPORTED'>",
            "location_coordinates": {
              "latitude": <float or null>,
              "longitude": <float or null>
            },
            "areaName": "<Area name if mentioned, else null>",
            "roadName": "<Road name if mentioned, else null>",
            "cityName": "<City name if mentioned, else null>",
            "description": "<Detailed description of the reported civic issue>",
            "timeStamp": "<ISO 8601 formatted timestamp>"
          }
        ]
        """
    )
)

