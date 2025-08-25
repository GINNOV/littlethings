import os
import json
import logging
import torch
import glob
import math
import hashlib
from jinja2 import Environment, BaseLoader, select_autoescape
from datasets import load_from_disk
from transformers import TrainingArguments  # noqa: F401 (kept for torch fallback shape-compat)
from peft import PeftConfig
from trl import SFTConfig  # noqa: F401 (kept for env consistency)

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

def sha256_file(path):
    """Compute SHA256 of a file; return 'N/A' if missing."""
    try:
        h = hashlib.sha256()
        with open(path, "rb") as f:
            for chunk in iter(lambda: f.read(1024 * 1024), b""):
                h.update(chunk)
        return h.hexdigest()
    except Exception:
        return "N/A"

def get_attr(obj, name, default="N/A"):
    """Safely get attribute across PEFT versions."""
    try:
        return getattr(obj, name)
    except Exception:
        return default

def load_training_args(final_checkpoint_dir, training_args_bin_path):
    """(1) Prefer JSON over .bin; fallback to torch.load for older runs."""
    # Common HF save path for args
    args_json_path = os.path.join(final_checkpoint_dir, "training_args.json")
    if os.path.exists(args_json_path):
        logger.info(f"Loading training args from JSON: {args_json_path}")
        with open(args_json_path, "r", encoding="utf-8") as f:
            return json.load(f), "json"
    logger.info("training_args.json not found; falling back to training_args.bin")
    ta = torch.load(training_args_bin_path, weights_only=False)
    # Convert TrainingArguments to a dict-like for rendering where possible
    if hasattr(ta, "to_dict"):
        return ta.to_dict(), "bin"
    return ta, "bin"

def curate_args(args_obj):
    """Return a curated subset of arguments for the card."""
    # Works whether args_obj is dict-like or TrainingArguments
    def get(k, default="N/A"):
        try:
            if isinstance(args_obj, dict):
                return args_obj.get(k, default)
            return getattr(args_obj, k, default)
        except Exception:
            return default
    return {
        "per_device_train_batch_size": get("per_device_train_batch_size"),
        "gradient_accumulation_steps": get("gradient_accumulation_steps"),
        "learning_rate": get("learning_rate"),
        "warmup_ratio": get("warmup_ratio"),
        "lr_scheduler_type": str(get("lr_scheduler_type")),
        "weight_decay": get("weight_decay"),
        "adam_beta1": get("adam_beta1"),
        "adam_beta2": get("adam_beta2"),
        "bf16": get("bf16"),
        "fp16": get("fp16"),
        "num_train_epochs": get("num_train_epochs"),
        "logging_steps": get("logging_steps"),
        "save_steps": get("save_steps"),
    }

def generate_model_card(main_output_dir):
    """
    Generates a professional model card in a single HTML file.
    Implements:
      1) JSON-first args load with torch fallback
      2) Jinja Environment with auto-escape
      6) NaN/missing-value handling for logs
      8) Export buttons (chart PNG & metrics JSON)
      9) SHA256 integrity for key artifacts
      12) Safer LoRA config attribute access
    """
    final_checkpoint_dir = os.path.join(main_output_dir, "final_checkpoint")
    logger.info(f"Generating model card for checkpoint: {final_checkpoint_dir}")
    model_card_path = os.path.join(final_checkpoint_dir, "model_card.html")

    try:
        latest_checkpoint_dir = find_latest_checkpoint(main_output_dir)
        if not latest_checkpoint_dir:
            raise FileNotFoundError("No checkpoint directories found to load trainer_state.json from.")

        logger.info(f"Loading trainer state from latest checkpoint: {latest_checkpoint_dir}")

        training_args_bin_path = os.path.join(final_checkpoint_dir, "training_args.bin")
        trainer_state_path = os.path.join(latest_checkpoint_dir, "trainer_state.json")

        dataset = load_from_disk(DATASET_DIR)
        dataset_size = len(dataset["train"])

        # (1) Load training args with JSON-first approach
        training_args, args_source = load_training_args(final_checkpoint_dir, training_args_bin_path)

        # (12) Safer LoRA config load & attribute access
        lora_config = PeftConfig.from_pretrained(final_checkpoint_dir)

        with open(trainer_state_path, 'r', encoding="utf-8") as f:
            trainer_state = json.load(f)

    except Exception as e:
        logger.error(f"❌ Error loading training artifacts for model card: {e}")
        raise SystemExit(1)

    # Build loss series with (6) defensive checks
    log_history = trainer_state.get('log_history', [])
    final_train_loss = 'N/A'
    epochs, losses = [], []

    if log_history:
        # Determine final train loss (train_loss preferred; else loss)
        for entry in reversed(log_history):
            if 'train_loss' in entry and entry['train_loss'] is not None:
                try:
                    final_train_loss = round(float(entry['train_loss']), 4)
                except Exception:
                    pass
                break
            if 'loss' in entry and entry['loss'] is not None:
                try:
                    final_train_loss = round(float(entry['loss']), 4)
                except Exception:
                    pass
                break

        for entry in log_history:
            val = entry.get('loss', entry.get('train_loss'))
            ep = entry.get('epoch', 0)
            try:
                if val is None:
                    continue
                fval = float(val)
                if not math.isfinite(fval):
                    continue
                epochs.append(round(float(ep or 0), 2))
                losses.append(round(fval, 4))
            except Exception:
                # Skip bad points silently
                continue

    # Serialize series for safe injection (avoid relying on |tojson)
    epoch_history_json = json.dumps(epochs, ensure_ascii=False)
    loss_history_json = json.dumps(losses, ensure_ascii=False)

    # (9) Integrity: compute SHA256 for key artifacts if present
    adapter_model_path = os.path.join(final_checkpoint_dir, "adapter_model.safetensors")
    adapter_config_path = os.path.join(final_checkpoint_dir, "adapter_config.json")
    training_args_json_path = os.path.join(final_checkpoint_dir, "training_args.json")

    hash_adapter_model = sha256_file(adapter_model_path)
    hash_adapter_config = sha256_file(adapter_config_path)
    hash_training_args = sha256_file(training_args_json_path) if os.path.exists(training_args_json_path) else "N/A"

    # Curated args view
    curated = curate_args(training_args)
    curated_json = json.dumps(curated, indent=2, ensure_ascii=False)

    # Try to show base model id from lora_config, fallback if absent
    base_model_id = get_attr(lora_config, "base_model_name_or_path", "N/A")

    # HTML template (2) real Jinja environment with auto-escape
    html_template = r"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Amiga Assembly Model Card</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root { --bg:#f9f9f9; --fg:#333; --card:#fff; --border:#eee; --accent:#3498db; --muted:#555; --ok:#27ae60; }
        @media (prefers-color-scheme: dark) {
            :root { --bg:#0f141a; --fg:#e6edf3; --card:#151b23; --border:#263242; --accent:#2f7abf; --muted:#a9b1ba; --ok:#2ecc71;}
        }
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; max-width: 900px; margin: 20px auto; padding: 20px; color: var(--fg); background-color: var(--bg); }
        .container { background-color: var(--card); padding: 30px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.08); border: 1px solid var(--border); }
        h1, h2 { color: var(--fg); border-bottom: 2px solid var(--accent); padding-bottom: 10px; }
        h1 { text-align: center; border-bottom: none; color: #fff; background-color: var(--accent); margin: -30px -30px 20px -30px; padding: 20px 30px; border-radius: 8px 8px 0 0; }
        p { color: var(--muted); }
        pre, code { background-color: rgba(236,240,241,0.12); border: 1px solid var(--border); border-radius: 6px; padding: 2px 5px; font-family: ui-monospace, "SF Mono", Menlo, Monaco, Consolas, "Liberation Mono", monospace; white-space: pre-wrap; word-wrap: break-word; }
        pre { padding: 15px; }
        .info-table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .info-table th, .info-table td { text-align: left; padding: 12px; border-bottom: 1px solid var(--border); vertical-align: top; }
        .info-table th { background-color: rgba(0,0,0,0.03); font-weight: 600; width: 32%; }
        .success { color: var(--ok); font-weight: bold; }
        .collapsible { background-color: var(--accent); color: white; cursor: pointer; padding: 15px; width: 100%; border: none; text-align: left; outline: none; font-size: 18px; transition: background-color 0.25s; border-radius: 5px; margin-top: 20px; }
        .collapsible:hover { filter: brightness(0.95); }
        .collapsible:after { content: '+'; font-size: 20px; color: white; float: right; }
        .active:after { content: "−"; }
        .content { padding: 0 18px; max-height: 0; overflow: hidden; transition: max-height 0.25s ease-out; background-color: rgba(0,0,0,0.02); border: 1px solid var(--border); border-top: none; border-radius: 0 0 5px 5px; }
        /* Ensure the chart has an explicit height for consistent rendering */
        #chartWrap { position: relative; width: 100%; height: 360px; margin-top: 16px; }
        #lossChart { display:block; width:100%; height:100%; }
        .actions { display:flex; gap:10px; margin-top: 12px; }
        .btn { background: var(--accent); color:#fff; border:none; padding:10px 14px; border-radius:8px; cursor:pointer; font-weight:600; }
        .btn:disabled { opacity: 0.6; cursor: not-allowed; }
        .muted { color:#c0392b; margin-top:10px; font-weight:600; display:none; }
        code.kv { display:inline-block; min-width: 220px; }
    </style>
</head>
<body>
<div class="container">
    <h1>Amiga Assembly Model Card</h1>
    <p>This document details the specifications and performance of a model fine-tuned for generating functional Amiga 68k assembly code.</p>

    <h2>Model Summary</h2>
    <table class="info-table">
        <tr><th>Base Model</th><td><code>{{ base_model_id }}</code></td></tr>
        <tr><th>Dataset Size</th><td>{{ dataset_size }} examples</td></tr>
        <tr><th>Total Epochs</th><td>{{ num_train_epochs }}</td></tr>
        <tr><th>Final Training Loss</th><td class="success">{{ final_train_loss }}</td></tr>
        <tr><th>Args Source</th><td><code>{{ args_source }}</code> (JSON preferred)</td></tr>
    </table>

    <h2>Training Performance</h2>
    <p>This chart visualizes the training loss over epochs.</p>
    <div id="chartWrap"><canvas id="lossChart"></canvas></div>
    <div id="chartWarning" class="muted">No loss points found to plot or Chart.js unavailable.</div>
    <div class="actions">
        <button id="btnPng" class="btn">Download Chart PNG</button>
        <button id="btnJson" class="btn">Download Metrics JSON</button>
    </div>

    <button type="button" class="collapsible">Training Arguments (curated)</button>
    <div class="content">
        <pre><code>{{ curated_args_json }}</code></pre>
    </div>

    <button type="button" class="collapsible">All Training Arguments (raw)</button>
    <div class="content">
        <pre><code>{{ training_args_str }}</code></pre>
    </div>

    <button type="button" class="collapsible">LoRA Hyperparameters</button>
    <div class="content">
        <table class="info-table">
            <tr><th>LoRA Rank (r)</th><td><code>{{ lora_r }}</code></td></tr>
            <tr><th>LoRA Alpha</th><td><code>{{ lora_alpha }}</code></td></tr>
            <tr><th>LoRA Dropout</th><td><code>{{ lora_dropout }}</code></td></tr>
            <tr><th>Task Type</th><td><code>{{ lora_task_type }}</code></td></tr>
            <tr><th>Target Modules</th><td><code>{{ lora_target_modules }}</code></td></tr>
        </table>
    </div>

    <button type="button" class="collapsible">Artifact Integrity (SHA256)</button>
    <div class="content">
        <table class="info-table">
            <tr><th><code>adapter_model.safetensors</code></th><td><code class="kv">{{ hash_adapter_model }}</code></td></tr>
            <tr><th><code>adapter_config.json</code></th><td><code class="kv">{{ hash_adapter_config }}</code></td></tr>
            <tr><th><code>training_args.json</code></th><td><code class="kv">{{ hash_training_args }}</code></td></tr>
        </table>
        <p>Use these checksums to verify file integrity and reproducibility.</p>
    </div>

    <button type="button" class="collapsible">Training History Log</button>
    <div class="content">
        <p>A detailed log of the model's performance at each logging step during the fine-tuning process.</p>
        <pre><code>{{ log_history_pretty }}</code></pre>
    </div>
</div>

<script>
(function(){
    // Collapsibles
    document.querySelectorAll('.collapsible').forEach(button => {
        button.addEventListener('click', () => {
            button.classList.toggle('active');
            const content = button.nextElementSibling;
            if (content.style.maxHeight) content.style.maxHeight = null;
            else content.style.maxHeight = content.scrollHeight + 'px';
        });
    });

    // Series data (pre-serialized in Python)
    const labels = {{ epoch_history_json | safe }};
    const losses = {{ loss_history_json | safe }};

    const warn = (msg) => {
        const el = document.getElementById('chartWarning');
        el.style.display = 'block';
        if (msg) el.textContent = msg;
        console.warn(msg || 'Chart warning');
    };

    // Render chart if possible
    let chart = null;
    try {
        if (!Array.isArray(labels) || !Array.isArray(losses) || labels.length === 0 || losses.length === 0) {
            warn('No loss points found to plot.');
        } else if (typeof Chart === 'undefined') {
            warn('Chart.js unavailable.');
        } else {
            const ctx = document.getElementById('lossChart').getContext('2d');
            chart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Training Loss',
                        data: losses,
                        borderColor: '#3498db',
                        backgroundColor: 'rgba(52, 152, 219, 0.1)',
                        fill: true,
                        tension: 0.1,
                        pointRadius: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        x: { title: { display: true, text: 'Epoch' } },
                        y: { title: { display: true, text: 'Loss' } }
                    }
                }
            });
        }
    } catch (e) {
        console.error(e);
        warn('Failed to render chart: ' + (e?.message || e));
    }

    // (8) Export buttons
    const btnPng = document.getElementById('btnPng');
    const btnJson = document.getElementById('btnJson');

    btnPng.addEventListener('click', () => {
        if (!chart) { warn('No chart to export.'); return; }
        const a = document.createElement('a');
        a.download = 'training_loss.png';
        a.href = chart.toBase64Image();
        document.body.appendChild(a);
        a.click();
        a.remove();
    });

    btnJson.addEventListener('click', () => {
        const payload = { labels: labels || [], losses: losses || [] };
        const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.download = 'training_metrics.json';
        a.href = url;
        document.body.appendChild(a);
        a.click();
        a.remove();
        setTimeout(() => URL.revokeObjectURL(url), 1000);
    });
})();
</script>
</body>
</html>
    """

    # Real Jinja environment with auto-escape (2)
    env = Environment(loader=BaseLoader(), autoescape=select_autoescape(['html', 'xml']))
    template = env.from_string(html_template)

    # num_train_epochs (works for dict or TrainingArguments)
    num_train_epochs = None
    try:
        if isinstance(training_args, dict):
            num_train_epochs = training_args.get("num_train_epochs", "N/A")
        else:
            num_train_epochs = getattr(training_args, "num_train_epochs", "N/A")
    except Exception:
        num_train_epochs = "N/A"

    # Render
    rendered_html = template.render(
        base_model_id=base_model_id,
        dataset_size=dataset_size,
        num_train_epochs=num_train_epochs,
        final_train_loss=final_train_loss,
        args_source=("json" if isinstance(training_args, dict) else "bin"),

        # Curated & raw args
        curated_args_json=curated_json,
        training_args_str=json.dumps(training_args, indent=2, ensure_ascii=False) if isinstance(training_args, dict) else str(training_args),

        # LoRA fields (12)
        lora_r=get_attr(lora_config, "r"),
        lora_alpha=get_attr(lora_config, "lora_alpha"),
        lora_dropout=get_attr(lora_config, "lora_dropout"),
        lora_task_type=get_attr(lora_config, "task_type"),
        lora_target_modules=get_attr(lora_config, "target_modules"),

        # Log & series
        log_history_pretty=json.dumps(log_history, indent=2, ensure_ascii=False),
        epoch_history_json=epoch_history_json,
        loss_history_json=loss_history_json,

        # Integrity (9)
        hash_adapter_model=hash_adapter_model,
        hash_adapter_config=hash_adapter_config,
        hash_training_args=hash_training_args
    )

    os.makedirs(final_checkpoint_dir, exist_ok=True)
    with open(model_card_path, "w", encoding='utf-8') as f:
        f.write(rendered_html)
    logger.info(f"✅ Model card saved to: {model_card_path}")

if __name__ == "__main__":
    if os.path.isdir(FINE_TUNED_DIR):
        generate_model_card(FINE_TUNED_DIR)
    else:
        logger.error(f"❌ Fine-tuned directory not found at {FINE_TUNED_DIR}. Cannot generate model card.")
        logger.error("Please ensure the training step has completed successfully.")
        raise SystemExit(1)