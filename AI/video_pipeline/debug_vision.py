import sys
import os
import cv2
import requests
import base64
import time
from rich.console import Console

console = Console()

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "qwen2.5vl:7b"

def extract_debug_frames(video_path):
    cap = cv2.VideoCapture(video_path)
    fps = cap.get(cv2.CAP_PROP_FPS)
    count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    duration = count / fps
    
    console.print(f"[bold]Analyzing {video_path}[/bold]")
    console.print(f"Duration: {duration:.2f}s | FPS: {fps:.2f}")

    # Extract 4 evenly spaced frames
    timestamps = [duration * 0.2, duration * 0.4, duration * 0.6, duration * 0.8]
    
    frames = []
    os.makedirs("debug_frames", exist_ok=True)
    
    for i, ts in enumerate(timestamps):
        cap.set(cv2.CAP_PROP_POS_MSEC, ts * 1000)
        success, image = cap.read()
        if success:
            # Resize for compatibility/VRAM (max 768)
            h, w = image.shape[:2]
            max_dim = 768
            if max(h, w) > max_dim:
                scale = max_dim / max(h, w)
                image = cv2.resize(image, (int(w * scale), int(h * scale)), interpolation=cv2.INTER_AREA)
                
            path = f"debug_frames/frame_{i}.jpg"
            cv2.imwrite(path, image)
            frames.append(path)
            console.print(f"Saved {path} (Timestamp: {ts:.2f}s) - Size: {image.shape[1]}x{image.shape[0]}")
    
    cap.release()
    return frames

def ask_ollama(frame_paths, single_mode=True):
    if single_mode:
        frame_paths = [frame_paths[0]]
        console.print("[yellow]Testing with a SINGLE image...[/yellow]")
    else:
        console.print(f"[yellow]Testing with {len(frame_paths)} images...[/yellow]")

    images_payload = []
    for path in frame_paths:
        with open(path, "rb") as f:
            images_payload.append(base64.b64encode(f.read()).decode("utf-8"))

    prompt = (
        "Describe this surveillance image. "
        "Are there ANY people visible? If yes, describe exactly what they are wearing. "
        "If you see a woman or a pink shirt, say it explicitly."
    )
    
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "images": images_payload,
        "stream": False,
    }
    
    console.print(f"\n[bold blue]Sending to {MODEL}...[/bold blue]")
    try:
        start_time = time.time()
        resp = requests.post(OLLAMA_URL, json=payload, timeout=60)
        resp.raise_for_status()
        console.print(f"Response time: {time.time() - start_time:.2f}s")
        return resp.json().get("response", "")
    except Exception as e:
        return f"Error: {e}"

if __name__ == "__main__":
    video = "videoclips/clip_2.mp4"
    if not os.path.exists(video):
        files = [f for f in os.listdir("videoclips") if f.endswith(".mp4")]
        if files:
            video = os.path.join("videoclips", files[0])
    
    if not os.path.exists(video):
        console.print(f"[red]Error: No video found.[/red]")
        sys.exit(1)

    frames = extract_debug_frames(video)
    
    # Attempt 1: Single image
    result = ask_ollama(frames, single_mode=True)
    console.print("\n[bold green]AI Output (Single Image):[/bold green]")
    console.print(result)

    if "Error" not in result:
        # Attempt 2: All images
        result_multi = ask_ollama(frames, single_mode=False)
        console.print("\n[bold green]AI Output (Multi Image):[/bold green]")
        console.print(result_multi)

