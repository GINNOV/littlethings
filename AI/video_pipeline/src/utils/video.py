import os

import cv2
from scenedetect import SceneManager, open_video
from scenedetect.detectors import ContentDetector

def detect_scenes(video_path: str, threshold=27.0):
    """
    Detects scenes in a video file.
    Returns a list of tuples: [(start_time_sec, end_time_sec), ...]
    """
    scene_manager = SceneManager()
    scene_manager.add_detector(ContentDetector(threshold=threshold))

    # Use open_video (modern API) instead of VideoManager
    video = open_video(video_path)
    scene_manager.detect_scenes(video)
    
    scene_list = scene_manager.get_scene_list()

    results = []
    for scene in scene_list:
        start, end = scene
        results.append((start.get_seconds(), end.get_seconds()))

    # If no scenes were detected, treat the entire video as one scene
    if not results:
        cap = cv2.VideoCapture(video_path)
        fps = cap.get(cv2.CAP_PROP_FPS)
        frame_count = cap.get(cv2.CAP_PROP_FRAME_COUNT)
        duration = frame_count / fps if fps > 0 else 0.0
        cap.release()
        if duration > 0:
            results.append((0.0, duration))

    return results

def extract_frame(video_path: str, timestamp: float, output_path: str):
    """Extracts a single frame at the specific timestamp and resizes it to 768px for AI compatibility."""
    cap = cv2.VideoCapture(video_path)
    # Set position
    cap.set(cv2.CAP_PROP_POS_MSEC, timestamp * 1000)
    success, image = cap.read()
    if success:
        # Resize to 768px for AI compatibility and to prevent 500 errors
        height, width = image.shape[:2]
        max_dim = 768
        if width > max_dim or height > max_dim:
            scale = max_dim / max(width, height)
            new_width = int(width * scale)
            new_height = int(height * scale)
            image = cv2.resize(image, (new_width, new_height), interpolation=cv2.INTER_AREA)
        
        cv2.imwrite(output_path, image)
    cap.release()
    return success
