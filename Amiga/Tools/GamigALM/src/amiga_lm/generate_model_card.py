import os
import json
import logging
import torch
import glob
import math
import hashlib
from jinja2 import Environment, BaseLoader, select_autoescape
from datasets import load_from_disk
from transformers import TrainingArguments  # noqa: F401 (kept for torch fallback)
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
    """Prefer JSON over .bin; fallback to torch.load for older runs."""
    args_json_path = os.path.join(final_checkpoint_dir, "training_args.json")
    if os.path.exists(args_json_path):
        logger.info(f"Loading training args from JSON: {args_json_path}")
        with open(args_json_path, "r", encoding="utf-8") as f:
            return json.load(f), "json"
    logger.info("training_args.json not found; falling back to training_args.bin")
    ta = torch.load(training_args_bin_path, weights_only=False)
    if hasattr(ta, "to_dict"):
        return ta.to_dict(), "bin"
    return ta, "bin"

def curate_args(args_obj):
    """Return a curated subset of arguments for the card."""
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

def truncate(s, n=200):
    if s is None:
        return ""
    s = str(s)
    return s if len(s) <= n else s[:n] + "…"

def sample_dataset_rows(dataset, k=5):
    """Return up to k samples with prompt/completion fields if present."""
    out = []
    try:
        train = dataset["train"]
        for i in range(min(k, len(train))):
            row = train[i]
            prompt = truncate(row.get("prompt", ""))
            completion = truncate(row.get("completion", ""))
            if prompt or completion:
                out.append({"prompt": prompt, "completion": completion})
            if len(out) >= k:
                break
    except Exception:
        pass
    return out

def generate_model_card(main_output_dir):
    """
    Generates a professional model card in a single HTML file.
    Adds:
      - eval_loss line
      - dataset preview
      - SMA smoothing toggle & window slider
      - integrity hashes, curated args, robust charting & exports
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

        # Load training args with JSON-first approach
        training_args, args_source = load_training_args(final_checkpoint_dir, training_args_bin_path)

        # LoRA config
        lora_config = PeftConfig.from_pretrained(final_checkpoint_dir)

        with open(trainer_state_path, 'r', encoding="utf-8") as f:
            trainer_state = json.load(f)

    except Exception as e:
        logger.error(f"❌ Error loading training artifacts for model card: {e}")
        raise SystemExit(1)

    # Build loss series (defensive checks)
    log_history = trainer_state.get('log_history', [])
    final_train_loss = 'N/A'

    train_points = []  # [{x: epoch, y: loss, step}]
    eval_points = []   # [{x: epoch, y: eval_loss, step}]

    if log_history:
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
            ep = entry.get('epoch', None)
            step = entry.get('step', None)

            # training
            val = entry.get('loss', entry.get('train_loss'))
            try:
                if val is not None:
                    fval = float(val)
                    if math.isfinite(fval) and ep is not None:
                        train_points.append({"x": float(ep), "y": round(fval, 4), "step": step})
            except Exception:
                pass

            # eval
            eval_val = entry.get('eval_loss', None)
            try:
                if eval_val is not None:
                    fe = float(eval_val)
                    if math.isfinite(fe) and ep is not None:
                        eval_points.append({"x": float(ep), "y": round(fe, 4), "step": step})
            except Exception:
                pass

    # Serialize for injection
    train_points_json = json.dumps(train_points, ensure_ascii=False)
    eval_points_json  = json.dumps(eval_points, ensure_ascii=False)

    # Integrity hashes
    adapter_model_path = os.path.join(final_checkpoint_dir, "adapter_model.safetensors")
    adapter_config_path = os.path.join(final_checkpoint_dir, "adapter_config.json")
    training_args_json_path = os.path.join(final_checkpoint_dir, "training_args.json")

    hash_adapter_model = sha256_file(adapter_model_path)
    hash_adapter_config = sha256_file(adapter_config_path)
    hash_training_args = sha256_file(training_args_json_path) if os.path.exists(training_args_json_path) else "N/A"

    # Curated args view
    curated = curate_args(training_args)
    curated_json = json.dumps(curated, indent=2, ensure_ascii=False)

    base_model_id = get_attr(lora_config, "base_model_name_or_path", "N/A")
    preview_rows = sample_dataset_rows(dataset, k=5)

    # Template with SMA controls
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
        #chartWrap { position: relative; width: 100%; height: 380px; margin-top: 16px; }
        #lossChart { display:block; width:100%; height:100%; }
        .actions { display:flex; gap:10px; margin-top: 12px; flex-wrap: wrap; align-items: center; }
        .btn { background: var(--accent); color:#fff; border:none; padding:10px 14px; border-radius:8px; cursor:pointer; font-weight:600; }
        .btn:disabled { opacity: 0.6; cursor: not-allowed; }
        .muted { color:#c0392b; margin-top:10px; font-weight:600; display:none; }
        .kv { display:inline-block; min-width: 220px; }
        .card { border:1px solid var(--border); border-radius:10px; padding:12px; margin:10px 0; background: rgba(0,0,0,0.02); }
        .mono { font-family: ui-monospace, "SF Mono", Menlo, Monaco, Consolas, "Liberation Mono", monospace; }
        .sma-controls { display:flex; gap:12px; flex-wrap: wrap; align-items:center; }
        .sma-controls label { display:flex; align-items:center; gap:6px; }
        .range { display:flex; align-items:center; gap:8px; }
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
    <p>Training and evaluation loss over epochs (linear X-axis).</p>

    <div class="sma-controls">
        <label><input type="checkbox" id="smoothTrain"> Smooth Train</label>
        <label><input type="checkbox" id="smoothEval"> Smooth Eval</label>
        <div class="range">
            <label for="smaWindow">Window</label>
            <input type="range" id="smaWindow" min="1" max="15" step="1" value="5">
            <span id="smaVal" class="mono">5</span>
        </div>
    </div>

    <div id="chartWrap"><canvas id="lossChart"></canvas></div>
    <div id="chartWarning" class="muted">No points found to plot or Chart.js unavailable.</div>
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

    <button type="button" class="collapsible">Data Preview (train)</button>
    <div class="content">
        {% if preview_rows and preview_rows|length > 0 %}
            {% for row in preview_rows %}
            <div class="card">
                <div><strong>Prompt</strong></div>
                <div class="mono">{{ row.prompt }}</div>
                <div style="height:8px"></div>
                <div><strong>Completion</strong></div>
                <div class="mono">{{ row.completion }}</div>
            </div>
            {% endfor %}
        {% else %}
            <p class="muted" style="display:block">No previewable samples found.</p>
        {% endif %}
        <p style="margin-top:8px">Preview is truncated to 200 characters per field.</p>
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

    // Raw series data: arrays of {x, y, step}
    const rawTrain = {{ train_points_json | safe }};
    const rawEval  = {{ eval_points_json  | safe }};

    const warn = (msg) => {
        const el = document.getElementById('chartWarning');
        el.style.display = 'block';
        if (msg) el.textContent = msg;
        console.warn(msg || 'Chart warning');
    };

    // SMA helper (simple moving average on y, preserving x)
    function sma(points, windowSize){
        if (!Array.isArray(points) || points.length === 0) return [];
        const w = Math.max(1, Math.floor(windowSize || 1));
        // Sort by x to ensure order
        const sorted = points.slice().sort((a,b)=> (a.x||0) - (b.x||0));
        const acc = [];
        let sum = 0;
        let q = [];
        for (let i=0;i<sorted.length;i++){
            const y = Number(sorted[i].y);
            if (!Number.isFinite(y)) continue;
            q.push(y);
            sum += y;
            if (q.length > w) sum -= q.shift();
            const avg = sum / q.length;
            acc.push({ x: sorted[i].x, y: Math.round(avg*10000)/10000, step: sorted[i].step });
        }
        return acc;
    }

    // Chart state
    let chart = null;
    let useSmoothTrain = false;
    let useSmoothEval  = false;
    let windowSize = 5;

    function getDisplayedSeries(){
        const train = useSmoothTrain ? sma(rawTrain, windowSize) : rawTrain;
        const evalS = useSmoothEval  ? sma(rawEval,  windowSize) : rawEval;
        return { train, evalS };
    }

    function renderChart(){
        const haveTrain = Array.isArray(rawTrain) && rawTrain.length > 0;
        const haveEval  = Array.isArray(rawEval)  && rawEval.length  > 0;

        if ((!haveTrain && !haveEval) || typeof Chart === 'undefined') {
            warn(!haveTrain && !haveEval ? 'No points found to plot.' : 'Chart.js unavailable.');
            return;
        }
        const { train, evalS } = getDisplayedSeries();
        const ctx = document.getElementById('lossChart').getContext('2d');

        const datasets = [];
        if (haveTrain && train.length){
            datasets.push({
                label: 'Train Loss' + (useSmoothTrain ? ` (SMA ${windowSize})` : ''),
                data: train,
                parsing: false,
                borderColor: '#3498db',
                backgroundColor: 'rgba(52, 152, 219, 0.1)',
                fill: true,
                tension: 0.1,
                pointRadius: 2
            });
        }
        if (haveEval && evalS.length){
            datasets.push({
                label: 'Eval Loss' + (useSmoothEval ? ` (SMA ${windowSize})` : ''),
                data: evalS,
                parsing: false,
                borderColor: '#e67e22',
                backgroundColor: 'rgba(230, 126, 34, 0.08)',
                fill: false,
                tension: 0.1,
                pointRadius: 2,
                borderDash: [4,3]
            });
        }

        if (chart) { chart.destroy(); }
        chart = new Chart(ctx, {
            type: 'line',
            data: { datasets },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: true },
                    tooltip: {
                        callbacks: {
                            label: (ctx) => {
                                const p = ctx.raw || {};
                                const y = typeof ctx.parsed?.y === 'number' ? ctx.parsed.y : p.y;
                                const ep = typeof ctx.parsed?.x === 'number' ? ctx.parsed.x : p.x;
                                const step = p.step != null ? `, step ${p.step}` : '';
                                return `${ctx.dataset.label}: ${y} (epoch ${ep}${step})`;
                            }
                        }
                    }
                },
                scales: {
                    x: { type: 'linear', title: { display: true, text: 'Epoch' } },
                    y: { title: { display: true, text: 'Loss' } }
                }
            }
        });
    }

    // Initial render
    try { renderChart(); } catch(e){ console.error(e); warn('Failed to render chart: ' + (e?.message || e)); }

    // Controls
    const chkTrain = document.getElementById('smoothTrain');
    const chkEval  = document.getElementById('smoothEval');
    const rngWin   = document.getElementById('smaWindow');
    const lblWin   = document.getElementById('smaVal');

    chkTrain.addEventListener('change', ()=>{ useSmoothTrain = chkTrain.checked; renderChart(); });
    chkEval .addEventListener('change', ()=>{ useSmoothEval  = chkEval.checked;  renderChart(); });
    rngWin  .addEventListener('input',  ()=>{
        windowSize = Math.max(1, parseInt(rngWin.value || '5', 10));
        lblWin.textContent = String(windowSize);
        renderChart();
    });

    // Export buttons reflect *displayed* data
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
        const { train, evalS } = getDisplayedSeries();
        const payload = { train: train || [], eval: evalS || [], smoothing: { train: useSmoothTrain, eval: useSmoothEval, window: windowSize } };
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

    env = Environment(loader=BaseLoader(), autoescape=select_autoescape(['html', 'xml']))
    template = env.from_string(html_template)

    try:
        if isinstance(training_args, dict):
            num_train_epochs = training_args.get("num_train_epochs", "N/A")
        else:
            num_train_epochs = getattr(training_args, "num_train_epochs", "N/A")
    except Exception:
        num_train_epochs = "N/A"

    rendered_html = template.render(
        base_model_id=base_model_id,
        dataset_size=dataset_size,
        num_train_epochs=num_train_epochs,
        final_train_loss=final_train_loss,
        args_source=("json" if isinstance(training_args, dict) else "bin"),

        curated_args_json=curated_json,
        training_args_str=json.dumps(training_args, indent=2, ensure_ascii=False) if isinstance(training_args, dict) else str(training_args),

        lora_r=get_attr(lora_config, "r"),
        lora_alpha=get_attr(lora_config, "lora_alpha"),
        lora_dropout=get_attr(lora_config, "lora_dropout"),
        lora_task_type=get_attr(lora_config, "task_type"),
        lora_target_modules=get_attr(lora_config, "target_modules"),

        log_history_pretty=json.dumps(trainer_state.get('log_history', []), indent=2, ensure_ascii=False),

        # Series
        train_points_json=train_points_json,
        eval_points_json=eval_points_json,

        # Integrity
        hash_adapter_model=hash_adapter_model,
        hash_adapter_config=hash_adapter_config,
        hash_training_args=hash_training_args,

        # Data preview
        preview_rows=preview_rows
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