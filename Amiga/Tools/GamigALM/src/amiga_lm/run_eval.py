import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline
import os
import glob
import logging
from colorama import Fore, Style, init

# Initialize Colorama for colored output
init(autoreset=True)

# --- Setup ---
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Configuration ---
model_path = "./amiga_gemma3-270m_finetuned/final_checkpoint"
output_dir = "model_answers"
SETTINGS_DIR = "model_settings"
PARAMS_FILE = os.path.join(SETTINGS_DIR, "fine_params.txt")

os.makedirs(output_dir, exist_ok=True)

# --- Helper Functions ---
def _get_inference_params_from_file(filename):
    """Retrieves inference generation parameters from the fine_params.txt file."""
    params = {}
    if not os.path.exists(filename):
        raise FileNotFoundError(f"Parameter file '{filename}' not found.")
    
    with open(filename, 'r', encoding='utf-8') as f:
        for line in f:
            if ':' in line and not line.strip().startswith('#'):
                key, value = line.split(':', 1)
                params[key.strip()] = value.strip()
    
    try:
        return {
            "max_new_tokens": int(params['max_new_tokens']),
            "do_sample": params['do_sample'].lower() in ('true', '1', 't'),
            "temperature": float(params['temperature']),
            "top_p": float(params['top_p'])
        }
    except (KeyError, ValueError) as e:
        raise ValueError(f"Missing or invalid inference parameter in '{filename}': {e}")

def _get_prompts_from_folder(folder_path):
    """Retrieves prompts from 'eval_prompt_*.txt' files, returning content and filenames."""
    prompts_with_filenames = []
    prompt_files = sorted(glob.glob(os.path.join(folder_path, "eval_prompt_*.txt")))
    if not prompt_files:
        raise FileNotFoundError(f"No prompt files matching 'eval_prompt_*.txt' found in '{folder_path}'.")
    
    for file_path in prompt_files:
        with open(file_path, 'r', encoding='utf-8') as f:
            prompts_with_filenames.append({
                "filename": os.path.basename(file_path),
                "content": f.read().strip()
            })
    return prompts_with_filenames

# --- Main Script ---
try:
    inference_params = _get_inference_params_from_file(PARAMS_FILE)
    prompts = _get_prompts_from_folder(SETTINGS_DIR)
    
    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    logger.info(f"Using device: {Fore.CYAN}{device}{Style.RESET_ALL}")

    logger.info(f"Loading fine-tuned model from: {model_path}")
    tokenizer = AutoTokenizer.from_pretrained(model_path, use_fast=False)
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        torch_dtype=torch.float32,
        trust_remote_code=True,
        attn_implementation='eager'
    )
    model.to(device)
    logger.info(f"{Fore.GREEN}Model loaded successfully!{Style.RESET_ALL}")

    generator = pipeline(
        "text-generation",
        model=model,
        tokenizer=tokenizer,
        device=device,
    )

    logger.info(f"\n{Fore.CYAN}--- Generating Amiga Assembly Code for {len(prompts)} prompts ---{Style.RESET_ALL}")
    for i, prompt_data in enumerate(prompts, 1):
        prompt_filename = prompt_data["filename"]
        prompt_content = prompt_data["content"]
        
        print("-" * 50)
        logger.info(f"Processing Prompt #{i} (from: {Fore.YELLOW}{prompt_filename}{Style.RESET_ALL})...")
        
        output = generator(prompt_content, **inference_params)
        generated_text = output[0]['generated_text']
        
        # Find the end of the original prompt and extract the rest of the text
        try:
            # Find the position of the prompt's end, so we can slice out the completion
            prompt_end_pos = generated_text.rfind(prompt_content) + len(prompt_content)
            code_part = generated_text[prompt_end_pos:].strip()
            
            # Use a slightly more robust check in case of unexpected output
            if not code_part or code_part == prompt_content:
                raise IndexError
            
            base_name = os.path.splitext(prompt_filename)[0].replace("eval_prompt_", "")
            output_filename = f"answer_{base_name}.s"
            file_path = os.path.join(output_dir, output_filename)
            
            with open(file_path, "w", encoding='utf-8') as f:
                f.write(code_part)
                
            logger.info(f"Generated code saved to: {Fore.GREEN}{file_path}{Style.RESET_ALL}")
            
        except IndexError:
            logger.warning(f"{Fore.YELLOW}Could not find valid code output for {prompt_filename}. Full output might be corrupted.{Style.RESET_ALL}")
            logger.info(f"Full model output was:\n{generated_text}")

    logger.info(f"\n{Fore.GREEN}Inference process finished!{Style.RESET_ALL}")

except (FileNotFoundError, ValueError) as e:
    logger.error(f"{Fore.RED}Configuration error: {e}{Style.RESET_ALL}")
    exit(1)
except Exception as e:
    logger.error(f"{Fore.RED}An unexpected error occurred: {e}{Style.RESET_ALL}")
    exit(1)