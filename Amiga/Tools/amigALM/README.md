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

*Make sure to login into Huggingface first!*
huggingface login
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


### Test it

### Convert from LoRA Adapter to Combined model
No, you can't use Jan, LM Studio, or Ollama to chat with the model directly in its current state. I know you were going to ask that!

These platforms are designed to run full, standalone models, but your fine-tuned model is a LoRA adapter. This means it's a small set of extra weights that sit on top of the original base model (gemma-3-270m-it). It's not a complete model on its own.

The Solution: Merging and Converting the Model
To use your model with these tools, you need to first merge the LoRA adapter into the base model to create a single, combined model file. Once merged, you can convert it to a format like .gguf that these platforms understand.

*Step 1*: Merge the LoRA Adapter
`merge_model.py` script will load your fine-tuned adapter, apply its weights to the base model, and save the result as a new, single model directory.

*Step 2*: Convert to a Compatible Format (.gguf)
Once you have the merged model in the amiga_gemma3-270m_merged directory, you need to convert it to a .gguf file using a tool like llama.cpp.

### Clone or Download llama.cpp:

git clone https://github.com/ggerganov/llama.cpp.git

`cd llama.cpp
mkdir build
cd build
cmake ..
cmake --build .`

After the build is complete, the convert.py script and the necessary executables will be located in the build/bin/ directory. You can then proceed with the model conversion.

Convert the Model:

Use the convert.py script from llama.cpp to convert your PyTorch model to a .gguf file.

python convert.py --outtype f16 /path/to/amiga_gemma3-270m_merged

The converted .gguf file can then be loaded into Ollama or LM Studio for chatting.

