import torch
from datasets import load_from_disk
from transformers import AutoTokenizer, AutoModelForCausalLM, TrainingArguments
from peft import LoraConfig
from trl import SFTTrainer
import os
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Configuration ---
base_model_id = "google/gemma-3-270m-it"
dataset_path = "amiga_asm_dataset"
output_dir = "./amiga_gemma3-270m_finetuned"

os.makedirs(output_dir, exist_ok=True)

# --- Device Setup ---
def get_device():
    if torch.backends.mps.is_available():
        logger.info("✅ Using Apple Silicon MPS")
        return torch.device("mps")
    logger.info("Using CPU")
    return torch.device("cpu")

device = get_device()

# --- Model and Tokenizer Loading ---
logger.info(f"Loading tokenizer and model: {base_model_id}")
try:
    tokenizer = AutoTokenizer.from_pretrained(
        base_model_id,
        use_fast=False,
        trust_remote_code=True
    )
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token
        logger.info("Added padding token")

    model = AutoModelForCausalLM.from_pretrained(
        base_model_id,
        torch_dtype=torch.float32,  # Use float32 for MPS compatibility
        trust_remote_code=True,
    )
    model.to(device)
    logger.info("Model and tokenizer loaded successfully")
except Exception as e:
    logger.error(f"Error loading model: {e}")
    raise

# --- Dataset Loading ---
dataset = load_from_disk(dataset_path)
logger.info(f"Dataset loaded: {dataset}")

# Transform dataset to have a single 'text' field instead of using formatting_func
def preprocess_dataset(examples):
    texts = []
    for prompt, completion in zip(examples['prompt'], examples['completion']):
        text = f"### Prompt:\n{prompt}\n\n### Code:\n{completion}"
        texts.append(text)
    return {"text": texts}

# Apply preprocessing
train_dataset = dataset["train"].map(preprocess_dataset, batched=True, remove_columns=['prompt', 'completion'])
test_dataset = dataset["test"].map(preprocess_dataset, batched=True, remove_columns=['prompt', 'completion'])

# --- LoRA Configuration ---
lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q_proj", "o_proj", "k_proj", "v_proj", "gate_proj", "up_proj", "down_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM",
)

# --- Training Arguments ---
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
    fp16=False,  # Disable fp16 for MPS
    bf16=False,  # Keep bf16 disabled
    gradient_checkpointing=True,
)

# --- Trainer Setup ---
trainer = SFTTrainer(
    model=model,
    args=training_args,
    peft_config=lora_config,
    train_dataset=train_dataset,
    eval_dataset=test_dataset,
)
logger.info("Trainer initialized successfully")

# --- Start Training ---
logger.info(f"Starting fine-tuning with base model: {base_model_id}")
try:
    trainer.train()
    logger.info("✅ Training completed successfully!")

    # --- Save Final Model ---
    final_model_path = f"{output_dir}/final_checkpoint"
    trainer.save_model(final_model_path)
    tokenizer.save_pretrained(final_model_path)
    logger.info(f"Final fine-tuned model saved to {final_model_path}")
except Exception as e:
    logger.error(f"❌ Training failed: {e}")
    raise

logger.info("Fine-tuning process finished!")