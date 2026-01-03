import os
from pathlib import Path

# Base directory
BASE_DIR = Path(__file__).resolve().parent.parent

# Database
DATABASE_URL = os.getenv(
    "DATABASE_URL", "postgresql://user:password@localhost:5432/video_db"
)

# Model Settings
# We use the 'minilm' model for embeddings because it's fast and standard
EMBEDDING_MODEL_NAME = "all-MiniLM-L6-v2"
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434/api/generate")

# Processing Defaults
DEFAULT_MODEL = "qwen2.5vl:7b"
FRAME_INTERVAL = float(os.getenv("FRAME_INTERVAL", "1.0"))  # Seconds between analysis frames
MAX_FRAMES_PER_SCENE = int(os.getenv("MAX_FRAMES_PER_SCENE", "24"))
MIN_SCENE_LENGTH = 2.0  # Ignore scenes shorter than 2 seconds
