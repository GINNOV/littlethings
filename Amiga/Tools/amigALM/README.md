# Install uv if you don't have it yet
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create and activate a new project environment
uv venv amiga-finetune
source amiga-finetune/bin/activate

# Install all the necessary libraries
uv pip install torch torchvision torchaudio
uv pip install transformers datasets accelerate peft trl bitsandbytes sentencepiece

# Test Environment Setup
`uv run check_gpu.py`

