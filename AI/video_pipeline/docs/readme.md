Here is the updated, practical `README.md`. I have condensed the architecture into a concise summary and integrated `tmux` commands directly into the workflow so you (or anyone else) can copy-paste to get things running on the headless DGX immediately.

---

# Sentinel: AI-Powered Surveillance Search Engine

**Sentinel** is a high-performance video analysis pipeline designed to process terabytes of surveillance footage on NVIDIA DGX hardware. It leverages **Qwen2.5-VL** to automatically detect scenes, generate detailed descriptions, and enable **semantic search** (e.g., *"Show me a white van parking"*) across your entire archive.

## 🏗 Architecture

Sentinel is built on a robust Producer-Consumer model designed for scale. A **Dockerized PostgreSQL** database (with `pgvector`) acts as the central state manager, storing video metadata and vector embeddings.

The pipeline consists of three decoupled services: an **Ingestor** that recursively scans and registers files, a **Worker** that utilizes local GPUs to detect scenes and generate AI descriptions, and a **Gradio Dashboard** that provides a web-based interface for semantic search and video review. This architecture ensures that a crash in one worker does not stop the entire pipeline.

## ⚡ Tech Stack

* **Core:** Python 3.10+ (managed by `uv`)
* **Database:** PostgreSQL + `pgvector` (Docker)
* **AI Inference:** Ollama (Local GPU) running `qwen2.5-vl:7b`
* **Search:** `sentence-transformers` (Embeddings)
* **Interface:** Gradio

---

## 🚀 Setup & Installation

### 1. Prerequisites

* **Hardware:** NVIDIA GPU (DGX recommended).
* **Software:** Docker, `uv`, and Ollama installed.

### 2. Installation

```bash
git clone https://github.com/your-repo/sentinel.git
cd sentinel

# Install Python dependencies
uv sync

# Pull the Vision Model (in a separate terminal)
ollama pull qwen2.5-vl:7b

```

### 3. Start Database

Spin up the vector database container:

```bash
docker compose up -d

```

*(Check status with `docker ps` to ensure `sentinel_db` is healthy)*

---

## 🛠 Operational Workflow (TMUX)

Since this runs on a headless server, use `tmux` to keep processes running persistently.

### Phase 1: Ingest Video Files

Scan your storage to register videos in the database.

```bash
# 1. Start a session
tmux new -s ingest

# 2. Run the scanner
uv run src/ingest.py /path/to/your/videos

# 3. Detach (keep running in background)
# Press: Ctrl+B, then D

```

### Phase 2: Start the AI Worker

The worker processes the queue. You can run multiple workers in separate windows (or in the background) to utilize all available GPUs.

```bash
# 1. Start a session
tmux new -s worker

# 2. Run the processor (or multiple)
uv run src/worker.py &
uv run src/worker.py & # Run as many as you have GPUs

# 3. Detach
# Press: Ctrl+B, then D
```

### Phase 3: Launch Dashboard

Start the web interface.

```bash
# 1. Start a session
tmux new -s app

# 2. Launch the server
uv run src/app.py

# 3. Detach
# Press: Ctrl+B, then D
```

**Access the UI:** `http://<DGX_IP_ADDRESS>:7860`

---

## 📋 Monitoring & Management

To check on your processes later, re-attach to the tmux sessions:

```bash
# Check the Worker logs
tmux attach -t worker

# Check the Dashboard logs
tmux attach -t app

```

*To kill a session:* `tmux kill-session -t worker`

## ⚙️ Configuration

Settings are managed in `src/config.py` or via Environment Variables:

| Variable | Default | Description |
| --- | --- | --- |
| `DATABASE_URL` | `postgresql://user:password@localhost...` | DB Connection string |
| `OLLAMA_URL` | `http://localhost:11434/api/generate` | AI Server URL |
| `FRAME_INTERVAL` | `1.0` | Seconds between analysis frames |
| `MAX_FRAMES_PER_SCENE` | `24` | Cap on frames sampled per scene |

## 🧪 Tests

Run unit tests:

```bash
pytest -q
```

Run database integration tests (uses a temporary schema):

```bash
TEST_DATABASE_URL=postgresql://user:password@localhost:5432/video_test pytest -q
```
