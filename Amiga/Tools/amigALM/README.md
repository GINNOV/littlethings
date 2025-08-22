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


# Build Dataset
You can build the dataset using as much code as you can find. The sources I used in the first commit are here hardcoded.
`uv run src/amiga_lm/prepare_dataset.py`


### \#\# Next Step: Train the Model 🚀

Make sure to login into Huggingface first!

You're all set to begin the fine-tuning process. This is the most computationally intensive part, where the model will learn from the Amiga assembly data you've just collected.

**1. Run the Training Script**

Execute the `train_model.py` script from your terminal:

```bash
uv run src/amiga_lm/train_model.py
```

**2. Monitor the Progress (if you want)**

While the model is training, you can open a **new, separate terminal window** and launch TensorBoard to watch the training loss decrease in real-time. This helps you see if the model is learning effectively.

In the new terminal, navigate to your project folder and run:

```bash
tensorboard --logdir amiga_codegemma_finetuned
```

This will give you a local web address to open in your browser.

