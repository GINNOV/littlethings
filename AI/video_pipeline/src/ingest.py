import argparse
import hashlib
import os
import sys

# Add src to path for imports
sys.path.append(os.path.join(os.path.dirname(__file__)))

import cv2
from rich.console import Console
from sqlmodel import Session, select

from database import engine, init_db
from models import Video

console = Console()


def get_file_hash(path: str):
    """Calculates SHA-256 of the first 10MB to be fast but relatively unique."""
    sha256 = hashlib.sha256()
    with open(path, "rb") as f:
        # Read first 10MB
        chunk = f.read(10 * 1024 * 1024)
        sha256.update(chunk)
    return sha256.hexdigest()


def get_video_metadata(path):
    cap = cv2.VideoCapture(path)
    if not cap.isOpened():
        return 0, 0, 0.0
    
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = cap.get(cv2.CAP_PROP_FPS)
    frame_count = cap.get(cv2.CAP_PROP_FRAME_COUNT)
    duration = frame_count / fps if fps > 0 else 0.0
    
    cap.release()
    return width, height, duration


def add_video_to_db(full_path: str, session: Session) -> str:
    """
    Tries to add a video to the database.
    Returns: 'added', 'exists_path', 'exists_hash', or 'error'
    """
    try:
        # 1. Quick check: Path exists?
        existing_path = session.exec(
            select(Video).where(Video.path == full_path)
        ).first()
        if existing_path:
            return "exists_path"

        # 2. Stronger check: Hash exists? (Prevents moved files)
        file_hash = get_file_hash(full_path)
        existing_hash = session.exec(
            select(Video).where(Video.hash == file_hash)
        ).first()
        if existing_hash:
            return "exists_hash"

        # Extract metadata
        width, height, duration = get_video_metadata(full_path)

        # Add new video
        video = Video(
            path=full_path, 
            hash=file_hash,
            filename=os.path.basename(full_path), 
            width=width, 
            height=height, 
            duration=duration
        )
        session.add(video)
        return "added"
    except Exception as e:
        # verify this print for errors
        console.print(f"[red]Error adding video {full_path}: {e}[/red]") 
        return "error"

def scan_directory(root_path: str):
    supported_exts = {".mp4", ".mkv", ".avi", ".mov"}
    new_count = 0

    console.print(f"[bold blue]Scanning {root_path}...[/bold blue]")

    with Session(engine) as session:
        for root, _, files in os.walk(root_path):
            for file in files:
                ext = os.path.splitext(file)[1].lower()
                if ext in supported_exts:
                    full_path = os.path.normpath(os.path.join(root, file))
                    
                    result = add_video_to_db(full_path, session)
                    
                    if result == "added":
                        new_count += 1
                        if new_count % 100 == 0:
                            session.commit()
                            console.print(f"  Queued {new_count} files...")
                    elif result == "exists_hash":
                         console.print(f"  [yellow]Skipping {file} (Duplicate content)[/yellow]")

        session.commit()

    console.print(
        f"[bold green]Done! Added {new_count} new videos to the pipeline.[/bold green]"
    )


if __name__ == "__main__":
    init_db()  # Ensure tables exist
    parser = argparse.ArgumentParser()
    parser.add_argument("path", help="Path to video folder")
    args = parser.parse_args()

    if not os.path.exists(args.path):
        console.print("[red]Error: Path does not exist.[/red]")
    else:
        scan_directory(args.path)
