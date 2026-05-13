from fastapi import FastAPI, File, UploadFile, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional
import uvicorn
import logging

from config import API_HOST, API_PORT, DEBUG
from modules.image_generation import ImageGenerator
from modules.web_scraper import WebScraper
from modules.data_intelligence import DataIntelligence
from modules.voice_processor import VoiceProcessor
from modules.webcam_viewer import WebcamViewer

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI
app = FastAPI(
    title="T's Mental Foundry API",
    description="AI Assistant for image generation, web scraping, data intelligence, and public webcams",
    version="1.0.0"
)

# Add CORS middleware for mobile app and bots
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize modules
image_gen = ImageGenerator()
web_scraper = WebScraper()
data_intel = DataIntelligence()
voice_processor = VoiceProcessor()
webcam_viewer = WebcamViewer()

# Pydantic Models
class ImageGenerationRequest(BaseModel):
    prompt: str
    num_images: int = 1
    height: int = 512
    width: int = 512
    guidance_scale: float = 7.5

class WebScrapingRequest(BaseModel):
    url: str
    selector: Optional[str] = None
    extract_images: bool = False

class DataIntelligenceRequest(BaseModel):
    query: str
    search_type: str = "general"
    limit: int = 10

class VoiceRequest(BaseModel):
    text: str
    language: str = "en-US"

class WebcamSearchRequest(BaseModel):
    query: str
    location: Optional[str] = None
    limit: int = 20

class LocationSearchRequest(BaseModel):
    latitude: float
    longitude: float
    radius_km: float = 10

# Health Check
@app.get("/health")
async def health_check():
    """Check if API is running"""
    return {"status": "online", "version": "1.0.0"}

# Image Generation Endpoints
@app.post("/api/image/generate")
async def generate_image(request: ImageGenerationRequest):
    """Generate images from text prompts"""
    try:
        logger.info(f"Generating image: {request.prompt}")
        images = await image_gen.generate(
            prompt=request.prompt,
            num_images=request.num_images,
            height=request.height,
            width=request.width,
            guidance_scale=request.guidance_scale
        )
        return {"success": True, "images": images, "prompt": request.prompt}
    except Exception as e:
        logger.error(f"Image generation error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Web Scraping Endpoints
@app.post("/api/scrape")
async def scrape_website(request: WebScrapingRequest):
    """Scrape data from a website"""
    try:
        logger.info(f"Scraping: {request.url}")
        data = await web_scraper.scrape(
            url=request.url,
            selector=request.selector,
            extract_images=request.extract_images
        )
        return {"success": True, "data": data, "url": request.url}
    except Exception as e:
        logger.error(f"Scraping error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Data Intelligence Endpoints
@app.post("/api/intelligence/search")
async def search_intelligence(request: DataIntelligenceRequest):
    """Search for public information about topics or people"""
    try:
        logger.info(f"Intelligence search: {request.query}")
        results = await data_intel.search(
            query=request.query,
            search_type=request.search_type,
            limit=request.limit
        )
        return {"success": True, "results": results, "query": request.query}
    except Exception as e:
        logger.error(f"Intelligence search error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Voice Processing Endpoints
@app.post("/api/voice/transcribe")
async def transcribe_voice(file: UploadFile = File(...)):
    """Convert voice to text"""
    try:
        logger.info("Transcribing voice...")
        text = await voice_processor.transcribe(file)
        return {"success": True, "text": text}
    except Exception as e:
        logger.error(f"Transcription error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/voice/synthesize")
async def synthesize_voice(request: VoiceRequest):
    """Convert text to voice using your ElevenLabs custom voice"""
    try:
        logger.info(f"Synthesizing voice: {request.text}")
        audio_file = await voice_processor.synthesize(
            text=request.text,
            language=request.language
        )
        return {"success": True, "audio_file": audio_file}
    except Exception as e:
        logger.error(f"Synthesis error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Public Webcam Endpoints
@app.post("/api/webcam/search")
async def search_webcams(request: WebcamSearchRequest):
    """Search for public webcams by location or type"""
    try:
        logger.info(f"Searching webcams: {request.query}")
        cameras = await webcam_viewer.search_public_webcams(
            query=request.query,
            location=request.location,
            limit=request.limit
        )
        return {"success": True, "cameras": cameras, "query": request.query}
    except Exception as e:
        logger.error(f"Webcam search error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/webcam/popular")
async def get_popular_webcams():
    """Get list of popular public webcams"""
    try:
        logger.info("Fetching popular webcams")
        cameras = await webcam_viewer.list_popular_cameras()
        return {"success": True, "cameras": cameras}
    except Exception as e:
        logger.error(f"Popular webcams error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/webcam/location")
async def find_webcams_by_location(request: LocationSearchRequest):
    """Find public webcams near a specific location"""
    try:
        logger.info(f"Finding cameras near {request.latitude}, {request.longitude}")
        cameras = await webcam_viewer.get_webcam_by_location(
            latitude=request.latitude,
            longitude=request.longitude,
            radius_km=request.radius_km
        )
        return {"success": True, "cameras": cameras}
    except Exception as e:
        logger.error(f"Location search error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/webcam/feed/{camera_id}")
async def get_webcam_feed(camera_id: str):
    """Get live feed URL for a public camera"""
    try:
        logger.info(f"Getting feed for camera: {camera_id}")
        feed = await webcam_viewer.get_live_feed(camera_id)
        return {"success": True, "feed": feed}
    except Exception as e:
        logger.error(f"Feed retrieval error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/webcam/snapshot/{camera_id}")
async def get_webcam_snapshot(camera_id: str):
    """Get a snapshot from a public camera"""
    try:
        logger.info(f"Getting snapshot from camera: {camera_id}")
        snapshot = await webcam_viewer.get_camera_snapshot(camera_id)
        return {"success": True, "snapshot": snapshot}
    except Exception as e:
        logger.error(f"Snapshot error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# Root endpoint
@app.get("/")
async def root():
    """API Information"""
    return {
        "name": "T's Mental Foundry API",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "image_generation": "/api/image/generate",
            "web_scraping": "/api/scrape",
            "data_intelligence": "/api/intelligence/search",
            "voice_transcribe": "/api/voice/transcribe",
            "voice_synthesize": "/api/voice/synthesize",
            "webcam_search": "/api/webcam/search",
            "webcam_popular": "/api/webcam/popular",
            "webcam_location": "/api/webcam/location",
            "webcam_feed": "/api/webcam/feed/{camera_id}",
            "webcam_snapshot": "/api/webcam/snapshot/{camera_id}"
        }
    }

if __name__ == "__main__":
    uvicorn.run(
        "app:app",
        host=API_HOST,
        port=API_PORT,
        reload=DEBUG,
        log_level="info"
    )
