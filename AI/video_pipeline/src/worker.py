import argparse
import json
import os
import sys
import time
import traceback

# Add src to path for imports
sys.path.append(os.path.join(os.path.dirname(__file__)))

import requests
from rich.console import Console
from sentence_transformers import SentenceTransformer
from sqlmodel import Session, select

from config import DEFAULT_MODEL, OLLAMA_URL, FRAME_INTERVAL, MAX_FRAMES_PER_SCENE
from database import engine
from models import ProcessingStatus, Scene, Video
from utils.video import detect_scenes, extract_frame
from utils.sampling import compute_scene_timestamps

embedder = SentenceTransformer("all-MiniLM-L6-v2")
console = Console()


from dataclasses import dataclass

@dataclass
class ProcessingConfig:
    prompt_template: str = (
        "Describe this surveillance scene in high detail. Focus on identifying every person "
        "and vehicle. For each person, describe their gender (if possible), clothing colors "
        "(top and bottom), and any accessories (hats, bags, masks). For vehicles, specify type "
        "and color. Describe specific actions like walking, carrying items, or interacting "
        "with objects. Be precise about colors (e.g., 'pink shirt', 'navy blue jacket')."
    )
    frame_count: int = 5
    frame_interval: float = FRAME_INTERVAL
    max_frames_per_scene: int = MAX_FRAMES_PER_SCENE

def generate_description(image_paths, model, prompt_template):
    """Sends images to Ollama for description."""
    import base64

    # Ensure input is a list
    if isinstance(image_paths, str):
        image_paths = [image_paths]

    images_payload = []
    for path in image_paths:
        try:
            with open(path, "rb") as f:
                images_payload.append(base64.b64encode(f.read()).decode("utf-8"))
        except Exception as e:
            console.print(f"[red]Error reading image {path}: {e}[/red]")

    if not images_payload:
        return None

    payload = {
        "model": model,
        "prompt": prompt_template,
        "images": images_payload,
        "stream": False,
    }

    try:
        resp = requests.post(OLLAMA_URL, json=payload)
        resp.raise_for_status()
        return resp.json().get("response", "")
    except Exception as e:
        console.print(f"[red]Ollama Error: {e}[/red]")
        return None


def generate_summary(descriptions, model):
    """Generates a summary of the video based on scene descriptions."""
    if not descriptions:
        return None
    
    joined_desc = "\n".join(f"- {d}" for d in descriptions)
    prompt = (
        f"Here are chronological descriptions of scenes from a surveillance video:\n"
        f"{joined_desc}\n\n"
        f"Provide a concise summary of the entire event captured in the video. "
        f"Focus on the main subjects and actions."
    )
    
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False,
    }
    
    try:
        resp = requests.post(OLLAMA_URL, json=payload)
        resp.raise_for_status()
        return resp.json().get("response", "")
    except Exception as e:
        console.print(f"[red]Ollama Summary Error: {e}[/red]")
        return None


def process_video(video_id: int, model_name: str, config: ProcessingConfig):
    # Ensure temp directory exists
    temp_dir = "temp_analysis"
    os.makedirs(temp_dir, exist_ok=True)

    with Session(engine) as session:
        video = session.get(Video, video_id)
        if not video:
            return

        video.status = ProcessingStatus.PROCESSING
        session.add(video)
        session.commit()

        console.print(f"Processing Video: [cyan]{video.filename}[/cyan]")

        # 1. Detect Scenes
        try:
            scenes_times = detect_scenes(video.path)
            console.print(f"  Found {len(scenes_times)} scenes.")

            # Create Scene records
            for idx, (start, end) in enumerate(scenes_times):
                scene = Scene(
                    video_id=video.id,
                    scene_index=idx,
                    start_time=start,
                    end_time=end,
                    status=ProcessingStatus.PENDING,
                )
                session.add(scene)
            session.commit()

        except Exception as e:
            console.print(f"[red]Scene Detection Failed: {e}[/red]")
            video.status = ProcessingStatus.FAILED
            session.add(video)
            session.commit()
            return

        # 2. Process Scenes (AI Description)
        # We re-fetch scenes to ensure we have IDs
        scenes = session.exec(select(Scene).where(Scene.video_id == video.id)).all()

        for scene in scenes:
            # Dynamic frame sampling based on scene duration
            duration = scene.end_time - scene.start_time
            buffer = min(0.3, duration * 0.05)
            
            # Density: 1 frame every 10 seconds, but min 5 and max 15
            target_count = int(duration / 10)
            count = max(5, min(15, target_count))
            
            # Generate evenly spaced timestamps
            timestamps = []
            if count == 1:
                timestamps = [scene.start_time + (duration / 2)]
            else:
                step = (duration - 2 * buffer) / (count - 1)
                for i in range(count):
                    timestamps.append(scene.start_time + buffer + (i * step))
            
            # Deduplicate and sort timestamps
            timestamps = sorted(list(set(timestamps)))

            frame_paths = []
            for i, ts in enumerate(timestamps):
                temp_img = os.path.join(temp_dir, f"frame_{scene.id}_{i}.jpg")
                if extract_frame(video.path, ts, temp_img):
                    frame_paths.append(temp_img)

            if frame_paths:
                # Generate Description from multiple frames
                desc = generate_description(frame_paths, model_name, config.prompt_template)

                if desc:
                    scene.description = desc
                    # Generate Vector Embedding
                    scene.embedding = embedder.encode(desc).tolist()
                    scene.status = ProcessingStatus.COMPLETED
                else:
                    scene.status = ProcessingStatus.FAILED
                    scene.error_message = "Ollama returned no description"

                # Cleanup temp images
                for p in frame_paths:
                    if os.path.exists(p):
                        os.remove(p)
            else:
                 scene.status = ProcessingStatus.FAILED
                 scene.error_message = "Failed to extract frames"

            session.add(scene)
            session.commit()
            console.print(f"  Scene {scene.scene_index}: [green]Done[/green]")

        # 3. Generate Video Summary
        all_descriptions = [s.description for s in scenes if s.description]
        if all_descriptions:
            console.print("  Generating video summary...")
            summary = generate_summary(all_descriptions, model_name)
            if summary:
                video.summary = summary
                console.print(f"  [green]Summary generated[/green]")

        video.status = ProcessingStatus.COMPLETED
        session.add(video)
        session.commit()


import threading

class VideoProcessor:
    def __init__(self, model_name=DEFAULT_MODEL):
        self.model_name = model_name
        self.running = False
        self.thread = None
        self.completed_queue = []
        self.config = ProcessingConfig() # Default Config

    def update_config(self, prompt, frame_count):
        self.config.prompt_template = prompt
        self.config.frame_count = int(frame_count)
        console.print(f"[bold blue]Config Updated:[/bold blue] Frames={frame_count}")

    def start(self):
        if not self.running:
            self.running = True
            self.thread = threading.Thread(target=self._run_loop, daemon=True)
            self.thread.start()
            console.print("[bold green]Background Worker Started[/bold green]")

    def stop(self):
        self.running = False
        if self.thread:
            self.thread.join(timeout=2)
            console.print("[bold red]Background Worker Stopped[/bold red]")
            
    def get_recent_completed(self):
        """Returns a list of filenames that recently finished processing."""
        recent = list(self.completed_queue)
        self.completed_queue.clear()
        return recent

    def _run_loop(self):
        console.print(f"[bold yellow]Worker Loop Active. Listening for jobs...[/bold yellow]")
        while self.running:
            try:
                with Session(engine) as session:
                    # Find a video that is PENDING and lock it so others skip it
                    statement = (
                        select(Video)
                        .where(Video.status == ProcessingStatus.PENDING)
                        .with_for_update(skip_locked=True)
                        .limit(1)
                    )
                    target_video = session.exec(statement).first()

                    if target_video:
                        vid_id = target_video.id
                        target_video.status = ProcessingStatus.PROCESSING
                        session.add(target_video)
                        session.commit()
                        
                        # Process the video (blocking call)
                        # PASS THE CURRENT CONFIG HERE
                        process_video(vid_id, self.model_name, self.config)
                        
                        # Check if it completed successfully to notify UI
                        with Session(engine) as check_session:
                            v = check_session.get(Video, vid_id)
                            if v and v.status == ProcessingStatus.COMPLETED:
                                self.completed_queue.append(v.filename)
                    else:
                        time.sleep(2)  # Wait before checking again
            except Exception as e:
                console.print(f"[red]Worker Loop Error: {e}[/red]")
                time.sleep(5)

def worker_loop(model_name):
    # Backward compatibility for CLI
    processor = VideoProcessor(model_name)
    processor.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        processor.stop()

if __name__ == "__main__":
    # Ensure Ollama is running first!
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default=DEFAULT_MODEL)
    args = parser.parse_args()

    worker_loop(args.model)
