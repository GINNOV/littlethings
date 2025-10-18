# 📖 Model Card Explainer
A little helper for those who are new to these AI shenanigans!

## 🔹 Model Summary

### **Base Model**
- **What it is:** The foundation model on which fine-tuning is applied (here: Gemma 3, 270M parameters).
- **Why it matters:** Determines vocabulary, architecture, and initial knowledge.
- **Example:** If the base is `google/gemma-3-270m-it`, then the fine-tuned model will inherit Gemma’s tokenizer and general language capabilities, and you add Amiga Assembly expertise.

---

### **Dataset Size**
- **What it is:** Number of training examples used for fine-tuning.
- **Why it matters:** More examples usually improve generalization, but small datasets can still yield strong domain adaptation.
- **Example:** `2,000 examples` means 2,000 prompt→completion pairs (like Amiga assembly tasks and their solutions).

---

### **Total Epochs**
- **What it is:** The number of full passes over the training dataset.
- **Why it matters:** Controls how thoroughly the model “sees” the data. Too few → underfitting. Too many → overfitting.
- **Example:** `3 epochs` means every sample was used three times in training.

---

### **Final Training Loss**
- **What it is:** The last reported loss value from training. Lower = better fit to the dataset.
- **Why it matters:** Gives a rough idea of convergence. Should be compared against evaluation loss.
- **Example:** A final training loss of `0.78` means predictions were quite close to the dataset completions on average.

---

## 🔹 Training Performance (Chart)

### **Train Loss Curve**
- **What it is:** Loss values over time on training batches.
- **Why it matters:** Shows whether the model is still learning or plateauing.
- **Example:** A curve going down and flattening at ~0.7 means the model stabilized there.

### **Eval Loss Curve**
- **What it is:** Loss values on a held-out validation set.
- **Why it matters:** Indicates generalization. If eval loss diverges upward while train loss goes down, that’s overfitting.
- **Example:** Eval loss stabilizing close to train loss is healthy.

### **SMA Smoothing**
- **What it is:** A simple moving average (sliding-window smoothing).
- **Why it matters:** Makes trends visible when raw logging is noisy.
- **Example:** With SMA=5, each point is the average of itself and the 4 surrounding points.

---

## 🔹 Training Arguments (Curated)

Each hyperparameter shapes how training behaves.

- **`per_device_train_batch_size`:** Number of examples processed at once per GPU/CPU.
  - Small batch = less memory, noisier updates.
  - Example: `1` means each gradient step sees one prompt→completion pair.

- **`gradient_accumulation_steps`:** Accumulates gradients before updating weights.
  - Simulates larger batch sizes without more memory.
  - Example: With batch=1 and grad_accum=4, effective batch = 4.

- **`learning_rate`:** Step size for optimizer updates.
  - Too high → divergence. Too low → slow training.
  - Example: `0.0002` is common for LoRA fine-tuning.

- **`warmup_ratio`:** Fraction of training used to gradually ramp up LR.
  - Prevents unstable early updates.
  - Example: `0.0` = no warmup, start at full learning rate immediately.

- **`lr_scheduler_type`:** How learning rate decays over time.
  - Example: `"linear"` means LR decreases linearly to 0.

- **`weight_decay`:** Regularization factor to prevent overfitting.
  - Penalizes large weights.
  - Example: `0.0` disables it.

- **`adam_beta1` and `adam_beta2`:** Momentum terms for Adam optimizer.
  - β1 controls smoothing of gradients, β2 of squared gradients.
  - Example: `0.9` and `0.999` are the defaults and work well in most cases.

- **`bf16` / `fp16`:** Whether mixed precision is used.
  - Reduces memory & speeds up training at some precision cost.
  - Example: `false` = full 32-bit precision used.

- **`num_train_epochs`:** Full dataset passes.
  - Example: `3` means each sample contributes three times.

- **`logging_steps`:** How often metrics are logged.
  - Example: `10` logs every 10 steps.

- **`save_steps`:** How often checkpoints are saved.
  - Example: `500` saves every 500 steps.

---

## 🔹 LoRA Hyperparameters

- **`r` (Rank):** Size of the low-rank decomposition.
  - Example: `8` means the LoRA adapter uses rank-8 matrices.

- **`lora_alpha`:** Scaling factor applied to updates.
  - Example: `16` amplifies adapter weights.

- **`lora_dropout`:** Dropout applied to LoRA layers.
  - Example: `0.05` randomly drops 5% of updates to reduce overfitting.

- **`task_type`:** Which task LoRA is adapting for (e.g. causal LM).
  - Example: `"CAUSAL_LM"` means left-to-right prediction.

- **`target_modules`:** Specific layers adapted.
  - Example: `["q_proj", "v_proj"]` means only query/value projections are adapted.

---

## 🔹 Artifact Integrity (SHA256)

- **What it is:** Cryptographic fingerprints of key files.
- **Why it matters:** Ensures reproducibility — if hashes match, files are identical.
- **Example:** SHA256 of `adapter_model.safetensors` can be published with the card so others verify they got the same weights.

---

## 🔹 Training History Log

- **What it is:** Raw JSON log from Hugging Face `Trainer`.
- **Why it matters:** Full transparency — every logged metric, step, and eval.
- **Example Entry:**
  ```json
  {
    "loss": 0.8214,
    "grad_norm": 0.77,
    "learning_rate": 0.00018,
    "epoch": 1.2,
    "step": 600
  }
  ```

---

## 🔹 Data Preview

- **What it is:** Sample prompt→completion pairs from the dataset.
- **Why it matters:** Gives a feel for the style and difficulty of tasks.
- **Example:**
  ```
  Prompt:
  "Write an Amiga 68k subroutine to clear memory at address 0x2000 for 64 bytes"

  Completion:
  "CLR.L D0
   MOVE.L #64,D1
   MOVEA.L #$2000,A0
   LOOP: CLR.B (A0)+
         SUBQ.L #1,D1
         BNE LOOP
   RTS"
  ```

---

## ⚠️ Good vs Bad Values (Troubleshooting)

- **Learning Rate too high:** Training loss may bounce up and down, eval loss spikes → model fails to converge.  
  *Fix:* Lower LR (e.g. 0.0002 → 0.00005).

- **Too few epochs:** Both train and eval loss remain high.  
  *Fix:* Increase `num_train_epochs` or dataset size.

- **Too many epochs (overfitting):** Train loss keeps dropping, eval loss rises.  
  *Fix:* Use early stopping or dropout.

- **Batch size too small:** Training loss very noisy, curve jagged.  
  *Fix:* Increase `per_device_train_batch_size` or use gradient accumulation.

- **No warmup:** Sudden initial spike in loss at step 0.  
  *Fix:* Set `warmup_ratio` to 0.05 or similar.

- **Dropout too high:** Loss decreases very slowly.  
  *Fix:* Lower `lora_dropout` (e.g. 0.05 → 0.01).

---

# ✅ In Summary

The card gives **end-to-end reproducibility**:
- Model lineage (base + dataset)
- Training dynamics (loss curves)
- Configs that matter (hyperparameters)
- Integrity proofs (SHA256)
- Dataset insight (sample preview)