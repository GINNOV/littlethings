import torch
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import PeftModel
import os
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Configuration ---
# The original base model you started with
base_model_id = "google/gemma-3-270m-it"
# The path to your fine-tuned LoRA adapter
lora_adapter_path = "./amiga_gemma3-270m_finetuned/final_checkpoint"
# The directory to save the final merged model
merged_model_path = "./amiga_gemma3-270m_merged"

# --- Main Script ---
logger.info(f"Loading base model from the Hub: {base_model_id}")
try:
    # Load the base model in float32 for merging on MPS
    base_model = AutoModelForCausalLM.from_pretrained(
        base_model_id,
        torch_dtype=torch.float32,
        trust_remote_code=True
    )
    tokenizer = AutoTokenizer.from_pretrained(base_model_id, use_fast=False)
    
    logger.info(f"Loading fine-tuned adapter from: {lora_adapter_path}")
    # Load the LoRA adapter weights
    model = PeftModel.from_pretrained(base_model, lora_adapter_path)
    
    logger.info("Merging adapter into the base model...")
    # Merge the weights and remove the adapter from the model
    merged_model = model.merge_and_unload()
    
    # Save the final merged model and its tokenizer
    os.makedirs(merged_model_path, exist_ok=True)
    merged_model.save_pretrained(merged_model_path)
    tokenizer.save_pretrained(merged_model_path)
    
    logger.info(f"✅ Merged model saved to: {merged_model_path}")
    logger.info("The model is now a single, ready-to-use file.")
    
except Exception as e:
    logger.error(f"❌ An error occurred during merging: {e}")
    raise