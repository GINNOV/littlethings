import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
import os
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Configuration ---
model_path = "./amiga_gemma3-270m_finetuned/final_checkpoint"
output_dir = "model_answers"

# Create the output directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

# --- Device Setup ---
device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
logger.info(f"Using device: {device}")

# --- Load Fine-Tuned Model ---
logger.info(f"Loading fine-tuned model from: {model_path}")
try:
    tokenizer = AutoTokenizer.from_pretrained(model_path, use_fast=False)
    
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        torch_dtype=torch.float32,
        trust_remote_code=True
    )
    model.to(device)
    logger.info("Model loaded successfully!")
except Exception as e:
    logger.error(f"Error loading model: {e}")
    raise

# --- Create Inference Pipeline ---
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
    
    # Extract the code and save to a file
    try:
        code_part = generated_text.split("### Code:\n")[1].strip()
        
        # Create a clean filename from the prompt
        filename = prompt.split("'")[1].replace(" ", "_") + ".s"
        file_path = os.path.join(output_dir, filename)
        
        with open(file_path, "w") as f:
            f.write(code_part)
            
        logger.info(f"Generated code saved to: {file_path}")
        logger.info("-" * 50)
        
    except IndexError:
        logger.warning("Could not find a valid code block in the output.")
        logger.info(f"Full output:\n{generated_text}")
        logger.info("-" * 50)

logger.info("\nInference process finished!")