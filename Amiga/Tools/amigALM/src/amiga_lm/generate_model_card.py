import os
import json
import logging
import torch
import glob
from jinja2 import Template
from datasets import load_from_disk
from transformers import TrainingArguments
from peft import PeftConfig
from trl import SFTConfig

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# --- Configuration ---
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FINE_TUNED_DIR = os.path.join(PROJECT_ROOT, "amiga_gemma3-270m_finetuned")
DATASET_DIR = os.path.join(PROJECT_ROOT, "amiga_asm_dataset")

def find_latest_checkpoint(output_dir):
    """Finds the checkpoint directory with the highest step number."""
    checkpoints = glob.glob(os.path.join(output_dir, "checkpoint-*"))
    if not checkpoints:
        return None
    latest_checkpoint = max(checkpoints, key=lambda p: int(p.split('-')[-1]))
    return latest_checkpoint

def generate_model_card(main_output_dir):
    """
    Generates a professional model card in a single HTML file.
    """
    final_checkpoint_dir = os.path.join(main_output_dir, "final_checkpoint")
    logger.info(f"Generating model card for checkpoint: {final_checkpoint_dir}")
    model_card_path = os.path.join(final_checkpoint_dir, "model_card.html")

    try:
        latest_checkpoint_dir = find_latest_checkpoint(main_output_dir)
        if not latest_checkpoint_dir:
            raise FileNotFoundError("No checkpoint directories found to load trainer_state.json from.")

        logger.info(f"Loading trainer state from latest checkpoint: {latest_checkpoint_dir}")
        
        training_args_path = os.path.join(final_checkpoint_dir, "training_args.bin")
        trainer_state_path = os.path.join(latest_checkpoint_dir, "trainer_state.json")
        
        dataset = load_from_disk(DATASET_DIR)
        dataset_size = len(dataset["train"])
        training_args = torch.load(training_args_path, weights_only=False)
        # CORRECTED: Use PeftConfig.from_pretrained to correctly load the adapter config
        lora_config = PeftConfig.from_pretrained(final_checkpoint_dir)
        with open(trainer_state_path, 'r') as f:
            trainer_state = json.load(f)

    except Exception as e:
        logger.error(f"❌ Error loading training artifacts for model card: {e}")
        exit(1)

    # HTML template with embedded CSS and JavaScript
    html_template = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Amiga Assembly Model Card</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; max-width: 900px; margin: 20px auto; padding: 20px; color: #333; background-color: #f9f9f9; }
        .container { background-color: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        h1, h2 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        h1 { text-align: center; border-bottom: none; color: #fff; background-color: #3498db; margin: -30px -30px 20px -30px; padding: 20px 30px; border-radius: 8px 8px 0 0; }
        p { color: #555; }
        pre, code { background-color: #ecf0f1; border: 1px solid #ddd; border-radius: 4px; padding: 2px 5px; font-family: "Courier New", Courier, monospace; white-space: pre-wrap; word-wrap: break-word; }
        pre { padding: 15px; }
        .info-table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .info-table th, .info-table td { text-align: left; padding: 12px; border-bottom: 1px solid #eee; }
        .info-table th { background-color: #f7f7f7; font-weight: 600; width: 30%; }
        .success { color: #27ae60; font-weight: bold; }
        .collapsible { background-color: #3498db; color: white; cursor: pointer; padding: 15px; width: 100%; border: none; text-align: left; outline: none; font-size: 18px; transition: background-color 0.3s; border-radius: 5px; margin-top: 20px; }
        .collapsible:hover { background-color: #2980b9; }
        .collapsible:after { content: '+'; font-size: 20px; color: white; float: right; }
        .active:after { content: "−"; }
        .content { padding: 0 18px; max-height: 0; overflow: hidden; transition: max-height 0.3s ease-out; background-color: #fdfdfd; border: 1px solid #eee; border-top: none; border-radius: 0 0 5px 5px; }
    </style>
</head>
<body>
<div class="container">
    <h1>Amiga Assembly Model Card</h1>
    <p>This document details the specifications and performance of a model fine-tuned for generating functional Amiga 68k assembly code.</p>
    <h2>Model Summary</h2>
    <p>A quick overview of the model's core configuration and final training results.</p>
    <table class="info-table">
        <tr><th>Base Model</th><td><code>{{ base_model_id }}</code></td></tr>
        <tr><th>Dataset Size</th><td>{{ dataset_size }} examples</td></tr>
        <tr><th>Total Epochs</th><td>{{ num_train_epochs }}</td></tr>
        <tr><th>Final Training Loss</th><td class="success">{{ final_train_loss }}</td></tr>
    </table>
    <h2>Training Performance</h2>
    <p>This chart visualizes the training loss over epochs, showing how the model learned and improved over time.</p>
    <canvas id="lossChart" style="margin-top: 20px; max-height: 400px;"></canvas>
    <button type="button" class="collapsible">Training Arguments</button>
    <div class="content">
        <p>These are the hyperparameters and settings used to train the model, defining the environment and learning strategy.</p>
        <pre><code>{{ training_args_str }}</code></pre>
        <h3>LoRA Hyperparameters</h3>
        <p>The specific settings for the LoRA (Low-Rank Adaptation) adapter that was trained.</p>
        <table class="info-table">
            <tr><th>LoRA Rank (r)</th><td><code>{{ lora_config.r }}</code></td></tr>
            <tr><th>LoRA Alpha</th><td><code>{{ lora_config.lora_alpha }}</code></td></tr>
            <tr><th>LoRA Dropout</th><td><code>{{ lora_config.lora_dropout }}</code></td></tr>
        </table>
    </div>
    <button type="button" class="collapsible">Training History Log</button>
    <div class="content">
        <p>A detailed log of the model's performance at each logging step during the fine-tuning process.</p>
        <pre><code>{{ log_history_pretty }}</code></pre>
    </div>
</div>
<script>
    document.querySelectorAll('.collapsible').forEach(button => {
        button.addEventListener('click', () => {
            button.classList.toggle('active');
            const content = button.nextElementSibling;
            if (content.style.maxHeight) { content.style.maxHeight = null; } else { content.style.maxHeight = content.scrollHeight + 'px'; }
        });
    });
    const ctx = document.getElementById('lossChart');
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: {{ epoch_history | tojson }},
            datasets: [{
                label: 'Training Loss',
                data: {{ loss_history | tojson }},
                borderColor: '#3498db',
                backgroundColor: 'rgba(52, 152, 219, 0.1)',
                fill: true,
                tension: 0.1
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { display: false } },
            scales: { x: { title: { display: true, text: 'Epoch' } }, y: { title: { display: true, text: 'Loss' } } }
        }
    });
</script>
</body>
</html>
    """
    
    log_history = trainer_state.get('log_history', [])
    final_train_loss = 'N/A'
    if log_history:
        for entry in reversed(log_history):
            if 'train_loss' in entry:
                final_train_loss = round(entry['train_loss'], 4)
                break
            elif 'loss' in entry:
                final_train_loss = round(entry['loss'], 4)

    epoch_history = [round(entry.get('epoch', 0), 2) for entry in log_history if 'loss' in entry or 'train_loss' in entry]
    loss_history = [round(entry.get('loss', entry.get('train_loss')), 4) for entry in log_history if 'loss' in entry or 'train_loss' in entry]

    template = Template(html_template)
    rendered_html = template.render(
        base_model_id=lora_config.base_model_name_or_path,
        dataset_size=dataset_size,
        num_train_epochs=getattr(training_args, 'num_train_epochs', 'N/A'),
        training_args_str=str(training_args),
        lora_config=lora_config,
        final_train_loss=final_train_loss,
        log_history_pretty=json.dumps(log_history, indent=2),
        epoch_history=epoch_history,
        loss_history=loss_history
    )
    
    with open(model_card_path, "w", encoding='utf-8') as f:
        f.write(rendered_html)
    logger.info(f"✅ Model card saved to: {model_card_path}")


if __name__ == "__main__":
    if os.path.isdir(FINE_TUNED_DIR):
        generate_model_card(FINE_TUNED_DIR)
    else:
        logger.error(f"❌ Fine-tuned directory not found at {FINE_TUNED_DIR}. Cannot generate model card.")
        logger.error("Please ensure the training step has completed successfully.")
        exit(1)