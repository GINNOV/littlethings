import os
import json
import random

dataset_path = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/fine_tuning/dataset.jsonl"
data_dir = "/Users/megov/code/GitHub/littlethings/Amiga/aMiLa/fine_tuning/data"
os.makedirs(data_dir, exist_ok=True)

with open(dataset_path, "r", encoding="utf-8") as f:
    records = [json.loads(line) for line in f if line.strip()]

# Shuffle records
random.seed(42)
random.shuffle(records)

# 90% train, 10% valid
split_idx = int(len(records) * 0.9)
train_records = records[:split_idx]
valid_records = records[split_idx:]

with open(os.path.join(data_dir, "train.jsonl"), "w", encoding="utf-8") as f:
    for rec in train_records:
        f.write(json.dumps(rec) + "\n")

with open(os.path.join(data_dir, "valid.jsonl"), "w", encoding="utf-8") as f:
    for rec in valid_records:
        f.write(json.dumps(rec) + "\n")

print(f"Split completed! Total records: {len(records)}")
print(f"Train records saved: {len(train_records)} -> {os.path.join(data_dir, 'train.jsonl')}")
print(f"Valid records saved: {len(valid_records)} -> {os.path.join(data_dir, 'valid.jsonl')}")
