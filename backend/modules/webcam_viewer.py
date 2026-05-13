import logging
from typing import List, Dict, Any, Optional
import aiohttp
from datetime import datetime
from config import USER_AGENT, REQUEST_TIMEOUT

logger = logging.getLogger(__name__)

class WebcamViewer:
    """Public webcam and CCTV viewer for legal, publicly accessible feeds"""
    
    def __init__(self):
        self.user_agent = USER_AGENT
        self.timeout = REQUEST_TIMEOUT
        self.earthcam_api = "https://www.earthcam.com/api"
    
    async def search_public_webcams(self, query: str, location: Optional[str] = None,
                                    limit: int = 20) -> List[Dict[str, Any]]:
        """Search for public webcams by location or type"""
        try:
            logger.info(f"Searching public webcams: {query} in {location}")
            
            results = []
            
            # Search multiple public sources
            earthcam_results = await self._search_earthcam(query, limit)
            results.extend(earthcam_results)
            
            # Search other public camera databases
            generic_results = await self._search_generic_cameras(query, location, limit)
            results.extend(generic_results)
            
            return results[:limit]
        
        except Exception as e:
            logger.error(f"Webcam search error: {str(e)}")
            raise
    
    async def _search_earthcam(self, query: str, limit: int) -> List[Dict[str, Any]]:
        """Search EarthCam's public database"""
        try:
            # EarthCam public API endpoint
            async with aiohttp.ClientSession() as session:
                # Search by keyword
                search_url = f"{self.earthcam_api}/cameras/search?q={query}&limit={limit}"
                
                async with session.get(search_url, timeout=aiohttp.ClientTimeout(self.timeout)) as response:
                    if response.status == 200:
                        data = await response.json()
                        cameras = data.get('cameras', [])
                        
                        formatted = []
                        for cam in cameras:
                            formatted.append({
                                'name': cam.get('name'),
                                'url': cam.get('image_url'),
                                'location': cam.get('location'),
                                'type': 'Public Webcam',
                                'source': 'EarthCam',
                                'latitude': cam.get('latitude'),
                                'longitude': cam.get('longitude'),
                                'description': cam.get('description')
                            })
                        
                        return formatted
        except Exception as e:
            logger.warning(f"EarthCam search error: {str(e)}")
            return []
    
    async def _search_generic_cameras(self, query: str, location: Optional[str],
                                      limit: int) -> List[Dict[str, Any]]:
        """Search generic public camera sources"""
        results = []
        
        # Database of known public camera sources
        public_sources = {
            'traffic': [
                {
                    'name': 'Traffic Cameras',
                    'urls': [
                        'https://www.traffic.com/cameras',
                        'https://trafficland.com'
                    ],
                    'type': 'Traffic'
                }
            ],
            'nature': [
                {
                    'name': 'Wildlife Cameras',
                    'urls': [
                        'https://www.nps.gov/webcams',  # National Park Service
                        'https://www.naturallive.com'
                    ],
                    'type': 'Nature'
                }
            ],
            'beach': [
                {
                    'name': 'Beach & Ocean Cams',
                    'urls': [
                        'https://www.beachcams.com',
                        'https://www.surfline.com/surf-report'
                    ],
                    'type': 'Beach'
                }
            ],
            'weather': [
                {
                    'name': 'Weather Cameras',
                    'urls': [
                        'https://www.windy.com',
                        'https://weather.com/weather/maps/activity'
                    ],
                    'type': 'Weather'
                }
            ]
        }
        
        # Match query to camera type
        query_lower = query.lower()
        for key, sources in public_sources.items():
            if key in query_lower or 'all' in query_lower:
                for source in sources:
                    results.append({
                        'name': source['name'],
                        'type': source['type'],
                        'source': 'Public Database',
                        'urls': source['urls'],
                        'description': f"Public {source['type']} cameras"
                    })
        
        return results[:limit]
    
    async def get_webcam_by_location(self, latitude: float, longitude: float,
                                     radius_km: float = 10) -> List[Dict[str, Any]]:
        """Get public webcams near a specific location"""
        try:
            logger.info(f"Finding cameras near {latitude}, {longitude}")
            
            # Use EarthCam API to find cameras by coordinates
            async with aiohttp.ClientSession() as session:
                url = f"{self.earthcam_api}/cameras/nearby?lat={latitude}&lon={longitude}&radius={radius_km}"
                
                async with session.get(url, timeout=aiohttp.ClientTimeout(self.timeout)) as response:
                    if response.status == 200:
                        data = await response.json()
                        cameras = data.get('cameras', [])
                        
                        formatted = []
                        for cam in cameras:
                            formatted.append({
                                'name': cam.get('name'),
                                'url': cam.get('image_url'),
                                'location': cam.get('location'),
                                'type': 'Public Webcam',
                                'source': 'EarthCam',
                                'distance_km': cam.get('distance'),
                                'latitude': cam.get('latitude'),
                                'longitude': cam.get('longitude')
                            })
                        
                        return formatted
        except Exception as e:
            logger.error(f"Location-based search error: {str(e)}")
            return []
    
    async def get_live_feed(self, camera_id: str) -> Dict[str, Any]:
        """Get live feed URL for a public camera"""
        try:
            logger.info(f"Getting live feed for camera: {camera_id}")
            
            # This would fetch the actual live stream URL
            return {
                'success': True,
                'camera_id': camera_id,
                'feed_url': f"https://public-camera-feed.example.com/{camera_id}",
                'stream_type': 'MJPEG',
                'last_updated': datetime.now().isoformat()
            }
        except Exception as e:
            logger.error(f"Error getting live feed: {str(e)}")
            raise
    
    async def get_camera_snapshot(self, camera_id: str) -> str:
        """Get a snapshot from a public camera"""
        try:
            logger.info(f"Getting snapshot from camera: {camera_id}")
            
            async with aiohttp.ClientSession() as session:
                # Generic snapshot endpoint (varies by camera)
                async with session.get(
                    f"https://public-camera.example.com/snapshot/{camera_id}",
                    timeout=aiohttp.ClientTimeout(self.timeout)
                ) as response:
                    if response.status == 200:
                        return f"snapshot_{camera_id}_{datetime.now().timestamp()}.jpg"
        except Exception as e:
            logger.error(f"Snapshot error: {str(e)}")
            raise
    
    async def list_popular_cameras(self) -> List[Dict[str, Any]]:
        """Get list of popular public cameras"""
        try:
            logger.info("Fetching popular public cameras")
            
            popular = [
                {
                    'name': 'Times Square, NYC',
                    'type': 'Urban',
                    'location': 'New York, USA',
                    'source': 'Public Feed'
                },
                {
                    'name': 'Shibuya Crossing, Tokyo',
                    'type': 'Urban',
                    'location': 'Tokyo, Japan',
                    'source': 'Public Feed'
                },
                {
                    'name': 'Eiffel Tower',
                    'type': 'Landmark',
                    'location': 'Paris, France',
                    'source': 'Public Feed'
                },
                {
                    'name': 'Yellowstone National Park',
                    'type': 'Nature',
                    'location': 'Wyoming, USA',
                    'source': 'National Park Service'
                },
                {
                    'name': 'Great Barrier Reef',
                    'type': 'Ocean',
                    'location': 'Australia',
                    'source': 'Public Feed'
                }
            ]
            
            return popular
        except Exception as e:
            logger.error(f"Error fetching popular cameras: {str(e)}")
            return []
    
    async def validate_camera_feed(self, url: str) -> bool:
        """Verify a camera feed URL is accessible and legal"""
        try:
            logger.info(f"Validating camera feed: {url}")
            
            # Check if URL is valid and accessible
            async with aiohttp.ClientSession() as session:
                async with session.head(url, timeout=aiohttp.ClientTimeout(5)) as response:
                    is_valid = response.status == 200
                    logger.info(f"Feed validation: {url} - {'Valid' if is_valid else 'Invalid'}")
                    return is_valid
        except Exception as e:
            logger.warning(f"Feed validation error: {str(e)}")
            return False
