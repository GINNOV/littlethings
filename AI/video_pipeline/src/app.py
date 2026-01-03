import os
import shutil
import sys
import threading
import time
import requests

# Add src to path for imports
sys.path.append(os.path.join(os.path.dirname(__file__)))

import gradio as gr
from sentence_transformers import SentenceTransformer
from sqlmodel import Session, select, col

from config import BASE_DIR, OLLAMA_URL
from database import engine
from models import ProcessingStatus, Scene, Video
from ingest import add_video_to_db
from worker import VideoProcessor

embedder = SentenceTransformer("all-MiniLM-L6-v2")

# Global Background Worker
processor = VideoProcessor()

def search_scenes(query_text, limit=10):
    """Performs semantic search using pgvector."""
    if not query_text:
        return []

    query_vector = embedder.encode(query_text).tolist()

    with Session(engine) as session:
        statement = (
            select(Scene, Video)
            .join(Video)
            .where(Scene.status == ProcessingStatus.COMPLETED)
            .order_by(Scene.embedding.cosine_distance(query_vector))
            .limit(limit)
        )
        results = session.exec(statement).all()

        output_data = []
        for scene, video in results:
            output_data.append(
                [
                    scene.id,
                    f"{video.filename} (Scene {scene.scene_index})",
                    f"{scene.start_time:.2f} - {scene.end_time:.2f}",
                    scene.description,
                ]
            )
        return output_data

def get_video_clip(scene_id):
    """Fetches video details for playback."""
    if not scene_id:
        return None, "", "", ""
    
    try:
        scene_id = int(scene_id)
    except:
        return None, "", "", ""

    with Session(engine) as session:
        scene = session.get(Scene, scene_id)
        if not scene:
            return None, "Error", "Scene not found", ""

        video = session.get(Video, scene.video_id)
        summary_text = f"### Video Summary\n{video.summary}" if video.summary else "_No summary available_"

        return (
            video.path,
            scene.description,
            f"Start: {scene.start_time}s | End: {scene.end_time}s",
            summary_text
        )

def update_description(scene_id, new_text):
    try:
        scene_id = int(scene_id)
    except:
        return "❌ Error: Invalid Scene ID"

    with Session(engine) as session:
        scene = session.get(Scene, scene_id)
        if scene:
            scene.description = new_text
            scene.embedding = embedder.encode(new_text).tolist()
            session.add(scene)
            session.commit()
            return "✅ Updated & Re-indexed!"
        return "❌ Error: Scene not found"

# --- Library Management ---

def get_library_data():
    """Returns all videos and their status for the dashboard."""
    with Session(engine) as session:
        videos = session.exec(select(Video).order_by(Video.id.desc())).all()
        data = []
        for v in videos:
            data.append([
                v.id,
                v.filename,
                v.status.value,
                f"{v.duration:.1f}s",
                v.path
            ])
        return data

def delete_video(video_id):
    """Deletes a video from the database."""
    if not video_id:
        return "Please select a video first."
    
    with Session(engine) as session:
        video = session.get(Video, video_id)
        if video:
            session.delete(video)
            session.commit()
            return f"Deleted {video.filename}"
        return "Video not found."

def reset_video(video_id):
    """Resets a video status to PENDING."""
    if not video_id:
        return "Please select a video first."
    
    with Session(engine) as session:
        video = session.get(Video, video_id)
        if video:
            video.status = ProcessingStatus.PENDING
            session.add(video)
            session.commit()
            return f"Reset {video.filename} to Pending"
        return "Video not found."

def reset_all_videos():
    """Resets ALL videos in the database to PENDING."""
    try:
        with Session(engine) as session:
            videos = session.exec(select(Video)).all()
            count = 0
            for v in videos:
                v.status = ProcessingStatus.PENDING
                v.summary = None
                session.add(v)
                count += 1
            session.commit()
        return f"✅ Successfully reset {count} videos to PENDING."
    except Exception as e:
        return f"❌ Error resetting videos: {e}"

# --- Ingestion ---

def ingest_uploaded_files(files):
    if not files:
        return "No files uploaded."
    
    # Ensure ingest directory exists
    upload_dir = os.path.join(BASE_DIR, "videoclips")
    os.makedirs(upload_dir, exist_ok=True)
    
    count = 0
    with Session(engine) as session:
        for file_obj in files:
            # Move file to videoclips/ folder
            dest_path = os.path.join(upload_dir, os.path.basename(file_obj.name))
            shutil.copy(file_obj.name, dest_path)
            
            result = add_video_to_db(dest_path, session)
            if result == "added":
                count += 1
        session.commit()
    
    return f"✅ Successfully added {count} videos."

def scan_local_folder(path):
    if not os.path.exists(path):
        return f"❌ Path not found: {path}"
    
    count = 0
    with Session(engine) as session:
        for root, _, files in os.walk(path):
            for file in files:
                if file.lower().endswith(('.mp4', '.mkv', '.avi', '.mov')):
                    full_path = os.path.join(root, file)
                    result = add_video_to_db(full_path, session)
                    if result == "added":
                        count += 1
        session.commit()
    return f"✅ Scanned and added {count} new videos."

def toggle_worker(is_active):
    if is_active:
        processor.start()
        return "🟢 Worker is RUNNING"
    else:
        processor.stop()
        return "🔴 Worker is STOPPED"

def check_notifications():
    """Polls the worker for completed tasks and sends toast notifications."""
    completed = processor.get_recent_completed()
    for filename in completed:
        gr.Info(f"✅ Processing Complete: {filename}")

def check_system_health():
    """Checks connection status of key components."""
    health_status = []
    
    # 1. Database Check
    try:
        with Session(engine) as session:
            session.exec(select(Video).limit(1))
        health_status.append(["Database (PostgreSQL)", "✅ Connected", "Queries responding"])
    except Exception as e:
        health_status.append(["Database (PostgreSQL)", "❌ Error", str(e)])

    # 2. Ollama Check
    try:
        # Remove /api/generate from URL to check root or /api/tags
        base_url = OLLAMA_URL.replace("/api/generate", "")
        resp = requests.get(base_url, timeout=2)
        if resp.status_code == 200:
            health_status.append(["Ollama (AI Model)", "✅ Connected", "Service is running"])
        else:
            health_status.append(["Ollama (AI Model)", "⚠️ Issue", f"Status: {resp.status_code}"])
    except Exception as e:
        health_status.append(["Ollama (AI Model)", "❌ Error", "Is Ollama running?"])

    # 3. Worker Check
    if processor.running:
        health_status.append(["Background Worker", "🟢 Active", "Processing queue"])
    else:
        health_status.append(["Background Worker", "⚪ Stopped", "Enable in Ingest tab"])

    return health_status

# --- UI Layout ---

with gr.Blocks(title="Sentinel: Video Intelligence") as app:
    # Polling Timer for notifications (every 2 seconds)
    gr.Timer(2, active=True).tick(check_notifications)

    gr.Markdown("# 👁️ Sentinel: AI Video Surveillance Pipeline")
    
    with gr.Tabs():
        
        # TAB 1: SEARCH
        with gr.Tab("🔍 Search & Review"):
            with gr.Row():
                with gr.Column(scale=1):
                    search_box = gr.Textbox(label="Semantic Search", placeholder="e.g., 'white van parking'")
                    search_btn = gr.Button("Search", variant="primary")
                    results_table = gr.Dataframe(
                        headers=["ID", "Video", "Timestamp", "Description"],
                        datatype=["number", "str", "str", "str"],
                        interactive=False,
                        wrap=True
                    )
                with gr.Column(scale=1):
                    video_player = gr.Video(label="Playback")
                    scene_info = gr.Markdown("Select a scene...")
                    video_summary = gr.Markdown(visible=True)
                    with gr.Group():
                        desc_editor = gr.TextArea(label="Edit Description")
                        scene_id_hidden = gr.Number(visible=False)
                        save_btn = gr.Button("Save Correction")
                        status_msg = gr.Label(label="Status")
            
            search_btn.click(search_scenes, search_box, results_table)
            search_box.submit(search_scenes, search_box, results_table)
            
            def on_search_select(evt: gr.SelectData, data):
                row_index = evt.index[0]
                scene_id = data.iloc[row_index, 0]
                return (*get_video_clip(scene_id), scene_id)

            results_table.select(on_search_select, results_table, [video_player, desc_editor, scene_info, video_summary, scene_id_hidden])
            save_btn.click(update_description, [scene_id_hidden, desc_editor], status_msg)

        # TAB 2: LIBRARY
        with gr.Tab("📂 Library Status"):
            with gr.Row():
                refresh_btn = gr.Button("🔄 Refresh List")
                delete_btn = gr.Button("🗑️ Delete Selected", variant="stop")
                reset_btn = gr.Button("Rw Reset Selected", variant="secondary")
            
            library_table = gr.Dataframe(
                headers=["ID", "Filename", "Status", "Duration", "Path"],
                datatype=["number", "str", "str", "str", "str"],
                value=get_library_data, # Load initial data
                interactive=False
            )
            library_msg = gr.Textbox(label="System Message", interactive=False)
            selected_video_id = gr.Number(visible=False)

            def on_lib_select(evt: gr.SelectData, data):
                row_index = evt.index[0]
                return data.iloc[row_index, 0] # Return ID

            library_table.select(on_lib_select, library_table, selected_video_id)
            
            refresh_btn.click(get_library_data, outputs=library_table)
            delete_btn.click(delete_video, selected_video_id, library_msg).success(get_library_data, outputs=library_table)
            reset_btn.click(reset_video, selected_video_id, library_msg).success(get_library_data, outputs=library_table)

            # Auto-refresh every 5 seconds
            gr.Timer(5, active=True).tick(get_library_data, outputs=library_table)

        # TAB 3: INGEST & SETTINGS
        with gr.Tab("📥 Ingest & Processing"):
            with gr.Row():
                with gr.Column():
                    gr.Markdown("### 1. Ingest Videos")
                    upload_files = gr.File(file_count="multiple", label="Upload Video Files")
                    upload_btn = gr.Button("Ingest Uploaded Files")
                    
                    gr.Markdown("---")
                    local_path = gr.Textbox(label="Or Scan Local Folder", value="videoclips/")
                    scan_btn = gr.Button("Scan Folder")
                    ingest_output = gr.Textbox(label="Ingest Result")
                
                with gr.Column():
                    gr.Markdown("### 2. Background Processing")
                    gr.Markdown("Control the AI Worker thread directly from here.")
                    worker_toggle = gr.Checkbox(label="Enable AI Worker", value=False)
                    worker_status = gr.Label(value="🔴 Worker is STOPPED")
                    
                    gr.Markdown("---")
                    gr.Markdown("### 3. Maintenance")
                    reset_all_btn = gr.Button("⚠️ Reset ALL Videos", variant="stop")
            
            upload_btn.click(ingest_uploaded_files, upload_files, ingest_output)
            scan_btn.click(scan_local_folder, local_path, ingest_output)
            worker_toggle.change(toggle_worker, worker_toggle, worker_status)
            reset_all_btn.click(reset_all_videos, outputs=ingest_output)

        # TAB 4: SYSTEM HEALTH
        with gr.Tab("❤️ System Health"):
            gr.Markdown("### Component Status")
            health_btn = gr.Button("🔄 Refresh Status")
            health_table = gr.Dataframe(
                headers=["Component", "Status", "Details"],
                datatype=["str", "str", "str"],
                value=check_system_health,
                interactive=False
            )
            health_btn.click(check_system_health, outputs=health_table)
            
            # Auto-refresh health every 10s
            gr.Timer(10, active=True).tick(check_system_health, outputs=health_table)

        # TAB 5: INSTRUCTIONS
        with gr.Tab("📖 Instructions"):
            gr.Markdown("""
            ### 🚀 How to use Sentinel
            Follow these steps to process and search your video footage:

            #### 1. Ingest Videos 📥
            Go to the **Ingest & Processing** tab. You can either:
            - **Upload** files directly from your computer.
            - **Scan** a folder already on the server (default: `videoclips/`).
            *New videos will appear in the Library as 'Pending'.*

            #### 2. Start the AI Worker ⚙️
            In the **Ingest & Processing** tab, check the **Enable AI Worker** box. 
            - This starts a background process that uses the GPU to detect scenes and generate AI descriptions.
            - You can see the status change to 'Processing' in the Library.

            #### 3. Monitor Progress 📂
            Check the **Library Status** tab. 
            - This table auto-refreshes every 5 seconds.
            - Once a video is marked as **'Completed'**, it is ready for searching.

            #### 4. Search & Review 🔍
            Go to the **Search & Review** tab.
            - Type a description of what you are looking for (e.g., *"person in a blue shirt"*).
            - Click a result to watch the clip.
            - If the AI made a mistake, you can **edit the description** and save it to improve future searches!
            """)

    # Footer
    gr.Markdown(
        """
        <div style="text-align: center; margin-top: 20px; color: #666;">
            <p>Sentinel Video Intelligence | Version: <b>v1.0.0</b> | Updated: 2026-01-03</p>
        </div>
        """
    )

if __name__ == "__main__":
    app.launch(
        server_name="0.0.0.0", 
        server_port=7860, 
        allowed_paths=["/"],
        theme=gr.themes.Soft()
    )