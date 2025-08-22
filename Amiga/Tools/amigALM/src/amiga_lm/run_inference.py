import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
import os
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Configuration ---
# Point to the directory where your fine-tuned model was saved
model_path = "./amiga_gemma3-270m_finetuned/final_checkpoint"

# --- Device Setup ---
device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
logger.info(f"Using device: {device}")

# --- Load Fine-Tuned Model ---
logger.info(f"Loading fine-tuned model from: {model_path}")
try:
    tokenizer = AutoTokenizer.from_pretrained(model_path, use_fast=False)
    
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        torch_dtype=torch.float32 if device.type == "mps" else torch.float16,
        trust_remote_code=True
    )
    model.to(device)
    logger.info("Model loaded successfully!")
except Exception as e:
    logger.error(f"Error loading model: {e}")
    raise

# --- Create Inference Pipeline ---
# The pipeline handles tokenizing and generation for you
generator = pipeline(
    "text-generation",
    model=model,
    tokenizer=tokenizer,
    device=device,
)

# --- Test Prompts ---
prompts = [
    "### Prompt:\nGenerate Amiga assembly code for the task 'set_background_color'.",
    "### Prompt:\nGenerate Amiga assembly code for the task 'play_a_sample_via_paula'.",
    "### Prompt:\nGenerate Amiga assembly code for the task 'blink_a_sprite'."
]

logger.info("\n--- Generating Amiga Assembly Code ---")
for prompt in prompts:
    logger.info("-" * 50)
    logger.info(f"Prompt:\n{prompt}")

    # Generate the code
    output = generator(
        prompt,
        max_new_tokens=256,
        do_sample=True,
        temperature=0.7,
        top_p=0.9,
    )
    
    generated_text = output[0]['generated_text']
    
    # Extract just the generated code part
    try:
        code_part = generated_text.split("### Code:\n")[1].strip()
        logger.info(f"Generated Code:\n{code_part}")
    except IndexError:
        logger.warning("Could not find a valid code block in the output.")
        logger.info(f"Full output:\n{generated_text}")

logger.info("\nInference process finished!")