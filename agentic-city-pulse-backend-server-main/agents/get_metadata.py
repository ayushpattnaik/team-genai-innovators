import os
import tempfile
import mimetypes
import logging
from datetime import datetime
import magic
from datetime import datetime
from PIL import Image
from PIL.ExifTags import TAGS, GPSTAGS
from fractions import Fraction

def extract_image_metadata(image_path):
    """Extract basic metadata from image file"""
    metadata = {}
    try:
        with Image.open(image_path) as image:
            # Basic image info
            metadata.update({
                'format': image.format,
                'mode': image.mode,
                'size': image.size,
                'width': image.width,
                'height': image.height,
                'file_size': os.path.getsize(image_path)
            })
            
            # Get basic EXIF data (without GPS - handled separately)
            exif_data = {}
            if hasattr(image, '_getexif') and image._getexif() is not None:
                exif = image._getexif()
                for tag_id, value in exif.items():
                    tag = TAGS.get(tag_id, tag_id)
                    # Skip GPS data (handled separately) and convert complex types
                    if tag not in ['GPSInfo']:
                        if isinstance(value, (bytes, tuple)):
                            value = str(value)
                        exif_data[tag] = value
            
            metadata['exif'] = exif_data
            
    except Exception as e:
        log_error(f"Failed to extract image metadata: {str(e)}")
        metadata['error'] = str(e)
    
    return metadata

def extract_gps_location(image_path):
    """Extract GPS location (latitude, longitude) from image EXIF data"""
    location_data = {
        "latitude": None,
        "longitude": None,
        "has_location": False
    }
    
    try:
        with Image.open(image_path) as image:
            if hasattr(image, '_getexif') and image._getexif() is not None:
                exif = image._getexif()
                
                # Look for GPS info
                gps_info = None
                for tag_id, value in exif.items():
                    tag = TAGS.get(tag_id, tag_id)
                    if tag == 'GPSInfo':
                        gps_info = value
                        break
                
                if gps_info:
                    # Parse GPS coordinates
                    gps_data = {}
                    for key, value in gps_info.items():
                        gps_tag = GPSTAGS.get(key, key)
                        gps_data[gps_tag] = value
                    
                    # Extract latitude
                    if 'GPSLatitude' in gps_data and 'GPSLatitudeRef' in gps_data:
                        lat = convert_gps_coordinate(gps_data['GPSLatitude'])
                        if gps_data['GPSLatitudeRef'] == 'S':
                            lat = -lat
                        location_data['latitude'] = lat
                    
                    # Extract longitude
                    if 'GPSLongitude' in gps_data and 'GPSLongitudeRef' in gps_data:
                        lon = convert_gps_coordinate(gps_data['GPSLongitude'])
                        if gps_data['GPSLongitudeRef'] == 'W':
                            lon = -lon
                        location_data['longitude'] = lon
                    
                    # Mark as having location if both coordinates are present
                    if location_data['latitude'] is not None and location_data['longitude'] is not None:
                        location_data['has_location'] = True
                        log_info(f"GPS location found: {location_data['latitude']}, {location_data['longitude']}")
                
    except Exception as e:
        log_error(f"Failed to extract GPS location: {str(e)}")
        location_data['error'] = str(e)
    
    return location_data

def convert_gps_coordinate(coordinate):
    """Convert GPS coordinate from EXIF format to decimal degrees"""
    try:
        if isinstance(coordinate, (list, tuple)) and len(coordinate) == 3:
            degrees, minutes, seconds = coordinate
            
            # Convert to float if they're fractions
            if hasattr(degrees, 'numerator'):
                degrees = float(degrees)
            if hasattr(minutes, 'numerator'):
                minutes = float(minutes)
            if hasattr(seconds, 'numerator'):
                seconds = float(seconds)
            
            # Convert to decimal degrees
            decimal = degrees + (minutes / 60.0) + (seconds / 3600.0)
            return round(decimal, 6)  # Round to 6 decimal places for precision
        
        return None
    except Exception as e:
        log_error(f"Failed to convert GPS coordinate: {str(e)}")
        return None

def extract_audio_metadata(audio_path):
    """Extract metadata from audio file"""
    metadata = {}
    try:
        try:
            from mutagen import File as MutagenFile
            
            audio_file = MutagenFile(audio_path)
            if audio_file is not None:
                # Convert tags to serializable format
                if audio_file.tags:
                    for key, value in audio_file.tags.items():
                        if isinstance(value, list):
                            metadata[str(key)] = [str(v) for v in value]
                        else:
                            metadata[str(key)] = str(value)
                
                # Extract audio info
                if hasattr(audio_file, 'info'):
                    metadata.update({
                        'duration': getattr(audio_file.info, 'length', None),
                        'bitrate': getattr(audio_file.info, 'bitrate', None),
                        'sample_rate': getattr(audio_file.info, 'sample_rate', None),
                        'channels': getattr(audio_file.info, 'channels', None)
                    })
        
        except ImportError:
            log_warning("mutagen library not available for audio metadata extraction")
        
        # Add file size
        metadata['file_size'] = os.path.getsize(audio_path)
        
    except Exception as e:
        log_error(f"Failed to extract audio metadata: {str(e)}")
        metadata['error'] = str(e)
        metadata['file_size'] = os.path.getsize(audio_path) if os.path.exists(audio_path) else 0
    
    return metadata
