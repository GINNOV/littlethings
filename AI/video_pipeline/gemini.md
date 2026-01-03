# Sentinel: AI Video Surveillance Pipeline (Context)

## 📂 Project Structure

The project follows a modular **Producer-Consumer** architecture designed for scalability on NVIDIA DGX hardware.

```text
/
├── docker-compose.yml    # Postgres + pgvector container
├── pyproject.toml        # Dependencies (uv managed)
├── src/
│   ├── app.py            # Gradio Dashboard (UI)
│   ├── worker.py         # AI Processing Logic (Scene Detect -> Ollama -> Embed)
│   ├── ingest.py         # Directory Scanner & File Registration
│   ├── database.py       # DB Connection & Session Management
│   ├── models.py         # SQLModel Schemas (Video, Scene)
│   ├── config.py         # Configuration & Env Vars
│   ├── reset_db.py       # Utility to wipe/init DB
│   └── utils/
│       └── video.py      # OpenCV/PySceneDetect wrappers
└── videoclips/           # Default storage for video files
```

## 🛠 Architecture & Workflow

### 1. Data Layer (PostgreSQL + pgvector)
*   **Containerized:** Runs via `docker-compose up -d`.
*   **Schema:** 
    *   `Video`: Tracks file metadata (`path`, `hash`, `status`).
    *   `Scene`: Tracks temporal segments (`start`, `end`, `description`, `embedding`).
*   **State:** The DB acts as the "Queue". Workers poll for `status='pending'` videos.

### 2. Operational Modes

#### A. Production (Headless / High Scale)
Run services independently to maximize stability and utilize multiple GPUs.
*   **Ingest:** `uv run src/ingest.py /path/to/videos` (Scans & registers files).
*   **Worker:** `uv run src/worker.py` (Polls DB, processes videos). *Run multiple instances for parallelism.*
*   **Web UI:** `uv run src/app.py` (Search & Review interface).

#### B. Development / Unified
The Gradio App (`src/app.py`) includes a background thread capable of running the worker logic.
*   Run `uv run src/app.py`.
*   Use the "Ingest & Processing" tab to upload files and toggle the "Enable AI Worker" switch.

## 🤖 Tech Stack
*   **Language:** Python 3.10+
*   **Database:** PostgreSQL (pgvector)
*   **ORM:** SQLModel (SQLAlchemy + Pydantic)
*   **AI Inference:** Ollama (`qwen2.5-vl:7b`)
*   **Embeddings:** `sentence-transformers/all-MiniLM-L6-v2`
*   **UI:** Gradio
*   **Video:** PySceneDetect, OpenCV

## 🔑 Key Commands
*   **Start DB:** `docker compose up -d`
*   **Install Deps:** `uv sync`
*   **Reset DB:** `uv run src/reset_db.py`