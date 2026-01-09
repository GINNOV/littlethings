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
from database import engine, init_db
from models import ProcessingStatus, Scene, Video
from ingest import add_video_to_db
from worker import VideoProcessor
from sqlmodel import SQLModel

embedder = SentenceTransformer("all-MiniLM-L6-v2")

# Global Background Worker
processor = VideoProcessor()

def wipe_database():
    """Drops all tables and recreates them."""
    try:
        # Stop worker if running to prevent errors during drop
        was_running = processor.running
        if was_running:
            processor.stop()
            
        SQLModel.metadata.drop_all(engine)
        init_db()
        
        if was_running:
            processor.start()
            
        return "✅ Database completely wiped and reset."
    except Exception as e:
        return f"❌ Error wiping database: {e}"

def format_timestamp(seconds: float) -> str:
    minutes = int(seconds // 60)
    secs = seconds % 60
    return f"{minutes:02d}:{secs:05.2f}"


def search_scenes(query_text, limit=20):
    """Performs semantic search using pgvector. If query is empty, returns latest scenes."""
    
    with Session(engine) as session:
        if not query_text:
            # Return latest scenes if no query (Feed Mode)
            statement = (
                select(Scene, Video)
                .join(Video)
                .where(Scene.status == ProcessingStatus.COMPLETED)
                .order_by(Scene.id.desc())
                .limit(limit)
            )
            results = session.exec(statement).all()
        else:
            # Semantic search with Threshold
            query_vector = embedder.encode(query_text).tolist()
            
            # Note: cosine_distance returns 0.0 for exact match, 1.0 for opposite.
            # We want small distances.
            # For MiniLM, < 0.6 is usually relevant. < 0.4 is strong.
            threshold = 0.55 
            
            statement = (
                select(Scene, Video, Scene.embedding.cosine_distance(query_vector).label("distance"))
                .join(Video)
                .where(Scene.status == ProcessingStatus.COMPLETED)
                .where(Scene.embedding.cosine_distance(query_vector) < threshold)
                .order_by(Scene.embedding.cosine_distance(query_vector))
                .limit(limit)
            )
            
            # Execute with distance
            results_with_dist = session.exec(statement).all()
            
            # Unpack format to match expected output
            results = [(r[0], r[1]) for r in results_with_dist]

        output_data = []
        for scene, video in results:
            output_data.append(
                [
                    scene.id,
                    os.path.splitext(video.filename)[0],
                    scene.scene_index,
                    f"{format_timestamp(scene.start_time)} - {format_timestamp(scene.end_time)}",
                    scene.description,
                ]
            )
            
        return output_data

def get_video_clip(scene_id):
    """Fetches video details for playback."""
    if not scene_id:
        return None, "", "", "", None
    
    try:
        scene_id = int(scene_id)
    except:
        return None, "", "", ""

    with Session(engine) as session:
        scene = session.get(Scene, scene_id)
        if not scene:
            return None, "Error", "Scene not found", "", None

        video = session.get(Video, scene.video_id)
        summary_text = f"### Video Summary\n{video.summary}" if video.summary else "_No summary available_"

        return (
            gr.update(value=video.path, playback_position=scene.start_time),
            scene.description,
            f"Start: {format_timestamp(scene.start_time)} | End: {format_timestamp(scene.end_time)}",
            summary_text,
            scene.start_time,
        )

def get_video_at_scene_start(scene_id):
    """Seeks the video player to the scene start time."""
    if not scene_id:
        return None

    try:
        scene_id = int(scene_id)
    except:
        return None

    with Session(engine) as session:
        scene = session.get(Scene, scene_id)
        if not scene:
            return None
        video = session.get(Video, scene.video_id)
        if not video:
            return None
        return gr.update(value=video.path, playback_position=scene.start_time)

def clear_video_player():
    return gr.update(value=None)

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

def update_settings(prompt, frames):
    processor.update_config(prompt, frames)
    return f"✅ Settings Updated! Frames: {frames}"

import subprocess

def get_git_hash():
    try:
        return subprocess.check_output(["git", "rev-parse", "--short", "HEAD"]).decode("utf-8").strip()
    except Exception:
        return "dev"

# --- UI Layout ---

with gr.Blocks(title="Sentinel: Video Intelligence") as app:
    gr.HTML(
        """
        <style>
          .gr-dataframe table tr:nth-child(even) {
            background-color: #f4f2ed;
          }
          .gr-dataframe table tr:nth-child(odd) {
            background-color: #ffffff;
          }
        </style>
        """
    )
    # Polling Timer for notifications (every 2 seconds)
    gr.Timer(2, active=True).tick(check_notifications)

    gr.Markdown("# 👁️ Sentinel: AI Video Surveillance Pipeline")
    
    with gr.Tabs():
        
        # TAB 1: SEARCH
        with gr.Tab("🔍 Search & Review"):
            with gr.Row():
                with gr.Column():
                    search_box = gr.Textbox(label="Semantic Search", placeholder="e.g., 'white van parking'")
                    search_btn = gr.Button("Search", variant="primary")
                    results_table = gr.Dataframe(
                        headers=["ID", "Video", "Scene", "Timestamp", "Description"],
                        datatype=["number", "str", "number", "str", "str"],
                        interactive=False,
                        wrap=True
                    )

            with gr.Row():
                with gr.Column():
                    video_player = gr.Video(label="Playback", elem_id="scene-player")

            with gr.Row():
                with gr.Column():
                    scene_info = gr.Markdown("Select a scene...")
                    video_summary = gr.Markdown(visible=True)
                    sync_btn = gr.Button("⏱️ Sync to Scene Start")
                    with gr.Group():
                        desc_editor = gr.TextArea(label="Edit Description")
                        scene_id_hidden = gr.Number(visible=False)
                        scene_start_hidden = gr.Number(visible=False)
                        save_btn = gr.Button("Save Correction")
                        status_msg = gr.Label(label="Status")
            
            search_btn.click(search_scenes, search_box, results_table)
            search_box.submit(search_scenes, search_box, results_table)
            
            def on_search_select(evt: gr.SelectData, data):
                row_index = evt.index[0]
                scene_id = data.iloc[row_index, 0]
                return (*get_video_clip(scene_id), scene_id)

            results_table.select(
                on_search_select,
                results_table,
                [video_player, desc_editor, scene_info, video_summary, scene_start_hidden, scene_id_hidden],
            )
            save_btn.click(update_description, [scene_id_hidden, desc_editor], status_msg)
            sync_btn.click(clear_video_player, outputs=video_player).then(
                get_video_at_scene_start, scene_id_hidden, video_player
            ).then(
                None,
                inputs=scene_start_hidden,
                outputs=None,
                _js="""
                (start_time) => {
                  const video = document.querySelector('#scene-player video');
                  if (!video || start_time == null) return;
                  video.currentTime = start_time;
                  video.play();
                }
                """,
            )

        # TAB 2: LIBRARY
        with gr.Tab("📂 Library Status"):
            with gr.Row():
                with gr.Column(scale=2):
                    with gr.Row():
                        refresh_btn = gr.Button("🔄 Refresh List")
                        delete_btn = gr.Button("🗑️ Delete Selected", variant="stop")
                        reset_btn = gr.Button("Rw Reset Selected", variant="secondary")
                        wipe_btn = gr.Button("⚠️ Wipe Database", variant="stop")
                    
                    library_table = gr.Dataframe(
                        headers=["ID", "Filename", "Status", "Duration", "Path"],
                        datatype=["number", "str", "str", "str", "str"],
                        value=get_library_data, # Load initial data
                        interactive=False
                    )
                
                with gr.Column(scale=1):
                    gr.Markdown("### Preview Video")
                    lib_player = gr.Video(label="Full Video Playback")
                    lib_details = gr.Markdown("Select a video to preview...")

            library_msg = gr.Textbox(label="System Message", interactive=False)
            selected_video_id = gr.Number(visible=False)

            def on_library_select(evt: gr.SelectData, data):
                row_index = evt.index[0]
                video_id = data.iloc[row_index, 0]
                video_path = data.iloc[row_index, 4] # Path is at index 4
                
                details = f"**Filename:** {data.iloc[row_index, 1]}\n**Status:** {data.iloc[row_index, 2]}\n**Duration:** {data.iloc[row_index, 3]}"
                return video_id, video_path, details

            library_table.select(on_library_select, library_table, [selected_video_id, lib_player, lib_details])
            
            refresh_btn.click(get_library_data, outputs=library_table)
            delete_btn.click(delete_video, selected_video_id, library_msg).success(get_library_data, outputs=library_table)
            reset_btn.click(reset_video, selected_video_id, library_msg).success(get_library_data, outputs=library_table)
            wipe_btn.click(wipe_database, outputs=library_msg).success(get_library_data, outputs=library_table)

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
                    with gr.Accordion("⚙️ Advanced Detection Settings", open=False):
                        prompt_input = gr.TextArea(
                            label="AI Prompt Template", 
                            value=(
                                "Describe this surveillance scene. CRITICAL: Identify every person. "
                                "For each person, describe their gender, clothing colors (top and bottom), "
                                "and any accessories (bags, hats). Look specifically for a woman in a "
                                "pink or red shirt. Describe actions like walking or carrying items. "
                                "If you see a vehicle, mention its type and color."
                            ),
                            lines=4
                        )
                        frames_slider = gr.Slider(
                            minimum=1, maximum=10, value=processor.config.frame_count, step=1, 
                            label="Frames per Scene (More = Slower but more accurate)"
                        )
                        update_settings_btn = gr.Button("Update Settings")
                        settings_msg = gr.Label(label="Settings Status")

                    update_settings_btn.click(update_settings, [prompt_input, frames_slider], settings_msg)

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
    version = get_git_hash()
    gr.Markdown(
        f"""
        <div style="text-align: center; margin-top: 20px; color: #666;">
            <p>Sentinel Video Intelligence | Version: <b>{version}</b> | Updated: 2026-01-03</p>
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
