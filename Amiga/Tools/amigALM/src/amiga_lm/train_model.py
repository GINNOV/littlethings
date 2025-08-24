import torch
from datasets import load_from_disk
from transformers import AutoTokenizer, AutoModelForCausalLM, TrainingArguments
from peft import LoraConfig
from trl import SFTTrainer
import os
import logging
from colorama import Fore, Style, init

# Initialize Colorama for colored output
init(autoreset=True)

# Set up logging to show INFO level messages with timestamps
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Configuration ---
# The base model ID from Hugging Face to be fine-tuned
base_model_id = "google/gemma-3-270m-it"
# Path to the pre-processed dataset
dataset_path = "amiga_asm_dataset"
# The directory where the final fine-tuned model and checkpoints will be saved
output_dir = "./amiga_gemma3-270m_finetuned"

# Create the output directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

# --- Device Setup ---
def get_device():
    """
    Determines and returns the best available device for training (MPS or CPU).
    """
    if torch.backends.mps.is_available():
        logger.info(f"{Fore.GREEN}✅ Using Apple Silicon MPS{Style.RESET_ALL}")
        return torch.device("mps")
    logger.info(f"{Fore.YELLOW}Using CPU{Style.RESET_ALL}")
    return torch.device("cpu")

device = get_device()

# --- Model and Tokenizer Loading ---
logger.info(f"Loading tokenizer and model: {Fore.CYAN}{base_model_id}{Style.RESET_ALL}")
try:
    # Load the tokenizer, using use_fast=False to avoid known issues with new models
    tokenizer = AutoTokenizer.from_pretrained(
        base_model_id,
        use_fast=False,
        trust_remote_code=True
    )
    # Ensure a padding token is set for batched training
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token
        logger.info("Added padding token")

    # Load the base model, specifying float32 and eager attention for MPS compatibility
    model = AutoModelForCausalLM.from_pretrained(
        base_model_id,
        torch_dtype=torch.float32,
        trust_remote_code=True,
        attn_implementation='eager'
    )
    # Manually move the model to the correct device
    model.to(device)
    logger.info(f"{Fore.GREEN}Model and tokenizer loaded successfully!{Style.RESET_ALL}")
except Exception as e:
    logger.error(f"{Fore.RED}Error loading model: {e}{Style.RESET_ALL}")
    raise

# --- Dataset Loading and Preprocessing ---
logger.info(f"Loading dataset from: {dataset_path}")
dataset = load_from_disk(dataset_path)
logger.info(f"Dataset loaded: {Fore.CYAN}{dataset}{Style.RESET_ALL}")

# This function formats the prompt and completion into a single 'text' field
def preprocess_dataset(examples):
    texts = []
    for prompt, completion in zip(examples['prompt'], examples['completion']):
        text = f"### Prompt:\n{prompt}\n\n### Code:\n{completion}"
        texts.append(text)
    return {"text": texts}

# Apply the preprocessing function to the training and testing datasets
train_dataset = dataset["train"].map(preprocess_dataset, batched=True, remove_columns=['prompt', 'completion'])
test_dataset = dataset["test"].map(preprocess_dataset, batched=True, remove_columns=['prompt', 'completion'])

# --- LoRA Configuration ---
# These are the parameters for the LoRA adapter
lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q_proj", "o_proj", "k_proj", "v_proj", "gate_proj", "up_proj", "down_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM",
)

# --- Training Arguments ---
# This class defines all the training hyperparameters and settings
training_args = TrainingArguments(
    output_dir=output_dir,
    per_device_train_batch_size=1,
    gradient_accumulation_steps=4,
    learning_rate=2e-4,
    num_train_epochs=3,
    logging_steps=10,
    save_strategy="epoch",
    save_total_limit=2,
    report_to="tensorboard",
    logging_dir=f"{output_dir}/logs",
    remove_unused_columns=False,
    fp16=False,
    bf16=False,
    gradient_checkpointing=True,
)

# --- Trainer Setup ---
# The SFTTrainer is a wrapper for the Trainer class, specialized for Supervised Fine-Tuning
trainer = SFTTrainer(
    model=model,
    args=training_args,
    peft_config=lora_config,
    train_dataset=train_dataset,
    eval_dataset=test_dataset,
    # The 'dataset_text_field' argument is not used in this version of TRL.
    # The trainer will automatically use the 'text' column from the preprocessed dataset.
)
logger.info(f"{Fore.GREEN}Trainer initialized successfully!{Style.RESET_ALL}")

# --- Start Training ---
logger.info(f"Starting fine-tuning with base model: {Fore.CYAN}{base_model_id}{Style.RESET_ALL}")
try:
    trainer.train()
    logger.info(f"{Fore.GREEN}✅ Training completed successfully!{Style.RESET_ALL}")

    # --- Save Final Model ---
    final_model_path = f"{output_dir}/final_checkpoint"
    trainer.save_model(final_model_path)
    tokenizer.save_pretrained(final_model_path)
    logger.info(f"Final fine-tuned model saved to {Fore.GREEN}{final_model_path}{Style.RESET_ALL}")
except Exception as e:
    logger.error(f"{Fore.RED}❌ Training failed: {e}{Style.RESET_ALL}")
    raise

logger.info(f"{Fore.GREEN}Fine-tuning process finished!{Style.RESET_ALL}")